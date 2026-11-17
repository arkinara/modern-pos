import { createHash, randomUUID } from 'node:crypto';
import { createReadStream } from 'node:fs';
import { mkdir, unlink, writeFile, rename } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { postgresTool } from './postgres-tools.mjs';

export function backupConfiguration(env) {
  const target = env.BACKUP_SSH_TARGET ?? '';
  const directory = env.BACKUP_REMOTE_DIR ?? '';
  const retentionDays = Number(env.BACKUP_RETENTION_DAYS);
  if (!/^[a-zA-Z0-9_][a-zA-Z0-9_.-]*@[a-zA-Z0-9][a-zA-Z0-9.-]*$/.test(target)) {
    throw new Error('BACKUP_SSH_TARGET must identify a user and host');
  }
  if (
    !/^\/[a-zA-Z0-9_/-]+$/.test(directory) ||
    directory.length < 6 ||
    directory.includes('//') ||
    directory.endsWith('/')
  ) {
    throw new Error('BACKUP_REMOTE_DIR must be a dedicated absolute directory');
  }
  if (!Number.isInteger(retentionDays) || retentionDays < 1 || retentionDays > 3650) {
    throw new Error('BACKUP_RETENTION_DAYS must be between 1 and 3650');
  }
  if (
    !env.DATABASE_URL ||
    !env.BACKUP_SPOOL_DIR ||
    !env.BACKUP_SUCCESS_FILE ||
    !env.BACKUP_SSH_KEY ||
    !env.BACKUP_KNOWN_HOSTS
  ) {
    throw new Error(
      'Database, spool, success marker, SSH key and pinned known-hosts configuration is required',
    );
  }
  return { target, directory, retentionDays };
}

export async function fileSha256(filename) {
  const hash = createHash('sha256');
  for await (const chunk of createReadStream(filename)) hash.update(chunk);
  return hash.digest('hex');
}

function transfer(command, args) {
  const result = spawnSync(command, args, {
    encoding: 'utf8',
    timeout: 300_000,
    windowsHide: true,
  });
  if (result.error || result.status !== 0) throw new Error('Backup transport operation failed');
  return result.stdout.trim();
}

export async function backup(env = process.env, commands = { postgres: postgresTool, transfer }) {
  const config = backupConfiguration(env);
  await mkdir(env.BACKUP_SPOOL_DIR, { recursive: true, mode: 0o700 });
  const filename = `modern-pos-${new Date().toISOString().replace(/[:.]/g, '-')}-${randomUUID()}.dump`;
  const local = path.join(env.BACKUP_SPOOL_DIR, filename);
  const remote = `${config.directory}/${filename}`;
  const sshOptions = [
    '-o',
    'BatchMode=yes',
    '-o',
    'StrictHostKeyChecking=yes',
    '-o',
    `UserKnownHostsFile=${env.BACKUP_KNOWN_HOSTS}`,
    '-i',
    env.BACKUP_SSH_KEY,
  ];
  try {
    await writeFile(local, '', { flag: 'wx', mode: 0o600 });
    commands.postgres(
      env.PG_DUMP_BIN ?? 'pg_dump',
      ['--format=custom', '--no-owner', '--no-privileges', '--file', local],
      env.DATABASE_URL,
      env,
    );
    const digest = await fileSha256(local);
    commands.transfer('scp', [...sshOptions, '--', local, `${config.target}:${remote}.partial`]);
    const remoteDigest = commands
      .transfer('ssh', [...sshOptions, config.target, `sha256sum -- '${remote}.partial'`])
      .split(/\s+/)[0];
    if (remoteDigest !== digest) throw new Error('Off-host backup checksum mismatch');
    commands.transfer('ssh', [
      ...sshOptions,
      config.target,
      `mv -- '${remote}.partial' '${remote}' && find '${config.directory}' -maxdepth 1 -type f -name 'modern-pos-*.dump' -mmin +${config.retentionDays * 24 * 60} -delete`,
    ]);
    const record = {
      completedAt: new Date().toISOString(),
      filename,
      sha256: digest,
      retentionDays: config.retentionDays,
    };
    const temporaryMarker = `${env.BACKUP_SUCCESS_FILE}.${randomUUID()}.tmp`;
    await writeFile(temporaryMarker, JSON.stringify(record) + '\n', { mode: 0o600 });
    await rename(temporaryMarker, env.BACKUP_SUCCESS_FILE);
    return record;
  } finally {
    // A failed transfer leaves the previous success marker untouched. pg_dump is reproducible.
    await unlink(local).catch((error) => {
      if (error.code !== 'ENOENT') throw error;
    });
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  backup()
    .then((record) => console.log(JSON.stringify({ event: 'backup_verified', ...record })))
    .catch(() => {
      console.error('Backup failed; inspect protected service diagnostics and retry');
      process.exitCode = 1;
    });
}
