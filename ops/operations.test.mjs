import assert from 'node:assert/strict';
import { test } from 'node:test';
import { createServer } from 'node:http';
import { createHash } from 'node:crypto';
import { writeFileSync } from 'node:fs';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { backup, backupConfiguration } from './backup.mjs';
import { databaseEnvironment, postgresTool } from './postgres-tools.mjs';
import { restoreTargets } from './restore-drill.mjs';
import { monitor, monitorUrl } from './monitor.mjs';

test('backup validates dedicated remote paths and retention before running commands', () => {
  const env = {
    BACKUP_SSH_TARGET: 'pos-backup@backup.example.test',
    BACKUP_REMOTE_DIR: '/backups/modern-pos',
    BACKUP_RETENTION_DAYS: '14',
    DATABASE_URL: 'postgresql://user:secret@host/source',
    BACKUP_SPOOL_DIR: '/spool',
    BACKUP_SUCCESS_FILE: '/spool/verified.json',
    BACKUP_SSH_KEY: '/key',
    BACKUP_KNOWN_HOSTS: '/hosts',
  };
  assert.equal(backupConfiguration(env).retentionDays, 14);
  for (const directory of [
    '/',
    '/tmp/../data',
    '/data;rm',
    '/data/other path',
    '/data//other',
    '-flag',
  ]) {
    assert.throws(() => backupConfiguration({ ...env, BACKUP_REMOTE_DIR: directory }));
  }
  for (const retention of ['0', '-1', '1.5', 'NaN', '3651']) {
    assert.throws(() => backupConfiguration({ ...env, BACKUP_RETENTION_DAYS: retention }));
  }
  assert.throws(() => backupConfiguration({ ...env, BACKUP_SSH_TARGET: '-oProxyCommand=bad' }));
});

test('database credentials stay in child environment and diagnostics are redacted', () => {
  const env = databaseEnvironment(
    'postgresql://user:p%40ssword@localhost:55466/source?schema=public&sslmode=require',
    {},
  );
  assert.equal(env.PGPASSWORD, 'p@ssword');
  assert.equal(env.PGDATABASE, 'source');
  assert.equal(env.PGSSLMODE, 'require');
  assert.equal(databaseEnvironment('postgresql://user@[::1]/source', {}).PGHOST, '::1');
  assert.throws(() =>
    databaseEnvironment('postgresql://user@localhost/source?constructor=bad', {}),
  );
  assert.throws(
    () =>
      postgresTool(
        process.execPath,
        ['-e', 'process.stderr.write(process.env.PGPASSWORD);process.exit(1)'],
        'postgresql://user:synthetic-secret@localhost/source',
      ),
    (error) => error.message === 'PostgreSQL operation failed',
  );
});

test('backup publishes success and retention only after remote checksum verification', async () => {
  const directory = await mkdtemp(path.join(tmpdir(), 'modern-pos-backup-'));
  const marker = path.join(directory, 'verified.json');
  const env = {
    BACKUP_SSH_TARGET: 'pos-backup@backup.example.test',
    BACKUP_REMOTE_DIR: '/backups/modern-pos',
    BACKUP_RETENTION_DAYS: '14',
    DATABASE_URL: 'postgresql://user:secret@host/source',
    BACKUP_SPOOL_DIR: directory,
    BACKUP_SUCCESS_FILE: marker,
    BACKUP_SSH_KEY: '/key',
    BACKUP_KNOWN_HOSTS: '/hosts',
  };
  const content = 'synthetic custom-format dump';
  const digest = createHash('sha256').update(content).digest('hex');
  const calls = [];
  let checksum = digest;
  let local;
  const commands = {
    postgres: (_command, args) => {
      local = args.at(-1);
      writeFileSync(local, content);
    },
    transfer: (command, args) => {
      calls.push({ command, args });
      assert.ok(args.includes('StrictHostKeyChecking=yes'));
      return args.at(-1).startsWith('sha256sum') ? `${checksum}  file.partial` : '';
    },
  };
  try {
    const record = await backup(env, commands);
    assert.equal(record.sha256, digest);
    assert.equal(calls.length, 3);
    assert.ok(calls.at(-1).args.at(-1).includes('-mmin +20160 -delete'));
    await assert.rejects(() => readFile(local), { code: 'ENOENT' });
    const previous = await readFile(marker, 'utf8');
    checksum = 'bad-checksum';
    calls.length = 0;
    await assert.rejects(() => backup(env, commands), /checksum mismatch/);
    assert.equal(calls.length, 2);
    assert.equal(await readFile(marker, 'utf8'), previous);
    await assert.rejects(() => readFile(local), { code: 'ENOENT' });
  } finally {
    await rm(directory, { recursive: true, force: true });
  }
});

test('restore drill rejects production and targets outside its synthetic namespace', () => {
  const env = {
    DRILL_DATABASE_URL: 'postgresql://user@localhost/source_transaction_test',
    RESTORE_DATABASE_URL: 'postgresql://user@localhost/target_restore_test',
  };
  assert.ok(restoreTargets(env));
  assert.throws(() => restoreTargets({ ...env, NODE_ENV: 'production' }));
  assert.throws(() => restoreTargets({ ...env, NODE_ENV: ' PRODUCTION ' }));
  assert.throws(() => restoreTargets({ ...env, RESTORE_DATABASE_URL: env.DRILL_DATABASE_URL }));
  assert.throws(() =>
    restoreTargets({ ...env, RESTORE_DATABASE_URL: 'postgresql://user@localhost/production' }),
  );
});

test('monitor requires HTTPS and explicit loopback opt-in', () => {
  assert.throws(() => monitorUrl('http://example.test/health'));
  assert.throws(() => monitorUrl('https://user:secret@example.test/health'));
  assert.throws(() => monitorUrl('http://localhost/health'));
  assert.equal(monitorUrl('http://127.0.0.1/health', true).protocol, 'http:');
});

test('controlled health failure sends redacted incident/recovery alerts and retries rejected delivery', async () => {
  const directory = await mkdtemp(path.join(tmpdir(), 'modern-pos-monitor-'));
  const alerts = [];
  let healthy = true;
  let acceptAlert = true;
  const server = createServer(async (request, response) => {
    if (request.url === '/health') {
      response.writeHead(healthy ? 200 : 503, { 'content-type': 'application/json' });
      response.end(
        JSON.stringify(
          healthy
            ? { status: 'ok', service: 'modern-pos-api', database: 'up' }
            : { secret: 'customer-sensitive-message' },
        ),
      );
      return;
    }
    let body = '';
    for await (const chunk of request) body += chunk;
    if (acceptAlert) alerts.push(JSON.parse(body));
    response.writeHead(acceptAlert ? 204 : 503);
    response.end();
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  const env = {
    MONITOR_HEALTH_URL: `${base}/health`,
    MONITOR_ALERT_URL: `${base}/alerts`,
    MONITOR_ALLOW_LOOPBACK: 'true',
    MONITOR_STATE_FILE: path.join(directory, 'state.json'),
  };
  try {
    assert.equal((await monitor(env)).healthy, true);
    assert.equal(alerts.length, 0);
    healthy = false;
    acceptAlert = false;
    await assert.rejects(() => monitor(env), /Alert delivery failed/);
    assert.equal(JSON.parse(await readFile(env.MONITOR_STATE_FILE, 'utf8')).healthy, true);
    acceptAlert = true;
    assert.equal((await monitor(env)).healthy, false);
    await monitor(env);
    assert.equal(alerts.length, 1);
    healthy = true;
    assert.equal((await monitor(env)).healthy, true);
    assert.deepEqual(
      alerts.map((alert) => alert.event),
      ['incident', 'recovered'],
    );
    assert.ok(!JSON.stringify(alerts).includes('customer-sensitive-message'));
    const marker = path.join(directory, 'backup.json');
    await writeFile(marker, JSON.stringify({ completedAt: '2020-01-01T00:00:00Z' }));
    assert.equal(
      (
        await monitor({
          ...env,
          BACKUP_SUCCESS_FILE: marker,
          MONITOR_BACKUP_MAX_AGE_SECONDS: '3600',
        })
      ).healthy,
      false,
    );
    assert.deepEqual(alerts.at(-1).reasons, ['verified_backup_stale']);
    console.log(
      JSON.stringify({
        scenario: 'loopback-notification-drill',
        events: alerts.map((alert) => alert.event),
        alertFailureRetry: 'passed',
        redaction: 'passed',
      }),
    );
  } finally {
    await new Promise((resolve) => server.close(resolve));
    await rm(directory, { recursive: true, force: true });
  }
});
