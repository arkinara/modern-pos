import { readFile, writeFile, rename } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export function monitorUrl(value, allowLocal = false) {
  const url = new URL(value);
  const local = allowLocal && ['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname);
  if (
    (url.protocol !== 'https:' && !(local && url.protocol === 'http:')) ||
    url.username ||
    url.password ||
    url.hash
  )
    throw new Error('Monitor endpoints require HTTPS without embedded credentials');
  return url;
}

export async function monitor(env = process.env) {
  const allowLocal = env.MONITOR_ALLOW_LOOPBACK === 'true';
  const health = monitorUrl(env.MONITOR_HEALTH_URL, allowLocal);
  const alert = monitorUrl(env.MONITOR_ALERT_URL, allowLocal);
  if (!env.MONITOR_STATE_FILE) throw new Error('MONITOR_STATE_FILE is required');
  let previous = null;
  try {
    previous = JSON.parse(await readFile(env.MONITOR_STATE_FILE, 'utf8'));
  } catch (error) {
    if (error.code !== 'ENOENT') throw new Error('Monitor state is unreadable');
  }
  const reasons = [];
  try {
    const response = await fetch(health, { signal: AbortSignal.timeout(5000), redirect: 'error' });
    if (!response.ok) throw new Error('Health request failed');
    const body = await response.json();
    if (body.status !== 'ok' || body.database !== 'up' || body.service !== 'modern-pos-api') {
      throw new Error('Health response failed');
    }
  } catch {
    reasons.push('api_health_failed');
  }
  if (env.BACKUP_SUCCESS_FILE) {
    const maximumAge = Number(env.MONITOR_BACKUP_MAX_AGE_SECONDS);
    if (!Number.isInteger(maximumAge) || maximumAge < 60)
      throw new Error('Backup freshness threshold is required');
    try {
      const marker = JSON.parse(await readFile(env.BACKUP_SUCCESS_FILE, 'utf8'));
      const age = Date.now() - Date.parse(marker.completedAt);
      if (!Number.isFinite(age) || age < 0 || age > maximumAge * 1000)
        throw new Error('Stale backup');
    } catch {
      reasons.push('verified_backup_stale');
    }
  }
  const state = { healthy: reasons.length === 0, reasons, checkedAt: new Date().toISOString() };
  if (
    (!state.healthy && JSON.stringify(previous?.reasons) !== JSON.stringify(reasons)) ||
    (state.healthy && previous?.healthy === false)
  ) {
    const response = await fetch(alert, {
      method: 'POST',
      redirect: 'error',
      signal: AbortSignal.timeout(5000),
      headers: {
        'content-type': 'application/json',
        ...(env.MONITOR_ALERT_TOKEN ? { authorization: `Bearer ${env.MONITOR_ALERT_TOKEN}` } : {}),
      },
      body: JSON.stringify({
        service: 'modern-pos-api',
        event: state.healthy ? 'recovered' : 'incident',
        reasons,
        at: state.checkedAt,
        runbook: 'docs/operations-qa.md',
      }),
    });
    if (!response.ok) throw new Error('Alert delivery failed; next probe will retry');
  }
  const temporary = `${env.MONITOR_STATE_FILE}.${randomUUID()}.tmp`;
  await writeFile(temporary, JSON.stringify(state) + '\n', { mode: 0o600 });
  await rename(temporary, env.MONITOR_STATE_FILE);
  return state;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  monitor()
    .then((state) => {
      console.log(JSON.stringify(state));
      if (!state.healthy) process.exitCode = 1;
    })
    .catch(() => {
      console.error('Monitor probe or alert delivery failed');
      process.exitCode = 1;
    });
}
