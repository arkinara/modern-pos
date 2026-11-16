import assert from 'node:assert/strict';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { performance } from 'node:perf_hooks';
import { postgresTool } from './postgres-tools.mjs';
import { fileSha256 } from './backup.mjs';

export function restoreTargets(env) {
  if (env.NODE_ENV?.trim().toLowerCase() === 'production')
    throw new Error('Restore drill requires an isolated environment');
  const source = new URL(env.DRILL_DATABASE_URL ?? '');
  const target = new URL(env.RESTORE_DATABASE_URL ?? '');
  if (
    !source.pathname.endsWith('_transaction_test') ||
    !target.pathname.endsWith('_restore_test') ||
    !['postgres:', 'postgresql:'].includes(source.protocol) ||
    !['postgres:', 'postgresql:'].includes(target.protocol)
  ) {
    throw new Error('Explicit synthetic source and isolated restore database names are required');
  }
  return { source: source.toString(), target: target.toString() };
}

const tables = [
  'sales',
  'sale_lines',
  'payment_records',
  'online_payments',
  'sale_reversals',
  'sale_refund_lines',
  'refund_intents',
  'stock_balances',
  'stock_movements',
  'sandbox_provider_payments',
];

function snapshot(database, env) {
  const result = {};
  for (const table of tables) {
    const query = `SELECT json_build_object('rows',count(*),'digest',md5(coalesce(string_agg(to_jsonb(t)::text,E'\\n' ORDER BY to_jsonb(t)::text),''))) FROM "${table}" t`;
    result[table] = JSON.parse(
      postgresTool(
        env.PSQL_BIN ?? 'psql',
        ['-X', '-A', '-t', '-v', 'ON_ERROR_STOP=1', '-c', query],
        database,
        env,
      ),
    );
  }
  const query = `SELECT json_build_object(
    'saleTotalMinor',(SELECT coalesce(sum("totalMinor"),0)::text FROM sales),
    'paymentTotalMinor',(SELECT coalesce(sum("amountMinor"),0)::text FROM payment_records),
    'refundTotalMinor',(SELECT coalesce(sum("refundMinor"),0)::text FROM sale_reversals),
    'providerRefundedMinor',(SELECT coalesce(sum("refundedMinor"),0)::text FROM online_payments))`;
  result.financialTotals = JSON.parse(
    postgresTool(
      env.PSQL_BIN ?? 'psql',
      ['-X', '-A', '-t', '-v', 'ON_ERROR_STOP=1', '-c', query],
      database,
      env,
    ),
  );
  return result;
}

export async function restoreDrill(env = process.env) {
  const { source, target } = restoreTargets(env);
  if (!env.DRILL_DUMP_FILE) throw new Error('DRILL_DUMP_FILE is required');
  const started = performance.now();
  const psql = env.PSQL_BIN ?? 'psql';
  const count = postgresTool(
    psql,
    [
      '-X',
      '-A',
      '-t',
      '-v',
      'ON_ERROR_STOP=1',
      '-c',
      "SELECT count(*) FROM pg_tables WHERE schemaname='public'",
    ],
    target,
    env,
  );
  if (count !== '0') throw new Error('Restore target must be an empty pre-created database');
  const before = snapshot(source, env);
  postgresTool(
    env.PG_DUMP_BIN ?? 'pg_dump',
    ['--format=custom', '--no-owner', '--no-privileges', '--file', env.DRILL_DUMP_FILE],
    source,
    env,
  );
  const restoreStarted = performance.now();
  postgresTool(
    env.PG_RESTORE_BIN ?? 'pg_restore',
    [
      '--exit-on-error',
      '--no-owner',
      '--no-privileges',
      '--dbname',
      decodeURIComponent(new URL(target).pathname.slice(1)),
      env.DRILL_DUMP_FILE,
    ],
    target,
    env,
  );
  const restoreSeconds = (performance.now() - restoreStarted) / 1000;
  // Source writers must remain paused throughout snapshot, dump and verification.
  assert.deepEqual(snapshot(source, env), before, 'Source changed during the isolated drill');
  assert.deepEqual(snapshot(target, env), before, 'Restored financial/stock records differ');
  return {
    event: 'restore_drill_passed',
    at: new Date().toISOString(),
    restoreSeconds,
    totalSeconds: (performance.now() - started) / 1000,
    sha256: await fileSha256(env.DRILL_DUMP_FILE),
    verified: before,
  };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  restoreDrill()
    .then((record) => console.log(JSON.stringify(record, null, 2)))
    .catch(() => {
      console.error(
        'Isolated restore drill failed; inspect the protected target and retry in a fresh empty database',
      );
      process.exitCode = 1;
    });
}
