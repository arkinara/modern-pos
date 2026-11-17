import { spawnSync } from 'node:child_process';

export function databaseEnvironment(value, env = process.env) {
  const url = new URL(value);
  if (!['postgres:', 'postgresql:'].includes(url.protocol) || !url.pathname.slice(1)) {
    throw new Error('A PostgreSQL database URL is required');
  }
  const result = {
    ...env,
    PGHOST: url.hostname.replace(/^\[|\]$/g, ''),
    PGPORT: url.port || '5432',
    PGUSER: decodeURIComponent(url.username),
    PGPASSWORD: decodeURIComponent(url.password),
    PGDATABASE: decodeURIComponent(url.pathname.slice(1)),
    PGCONNECT_TIMEOUT: '10',
  };
  const options = {
    sslmode: 'PGSSLMODE',
    sslrootcert: 'PGSSLROOTCERT',
    sslcert: 'PGSSLCERT',
    sslkey: 'PGSSLKEY',
    channel_binding: 'PGCHANNELBINDING',
    options: 'PGOPTIONS',
  };
  for (const [name, value] of url.searchParams) {
    if (Object.hasOwn(options, name)) result[options[name]] = value;
    else if (!['schema', 'connection_limit', 'pool_timeout'].includes(name)) {
      throw new Error('Unsupported database connection option');
    }
  }
  return result;
}

export function postgresTool(command, args, databaseUrl, env = process.env) {
  const result = spawnSync(command, args, {
    env: databaseEnvironment(databaseUrl, env),
    encoding: 'utf8',
    windowsHide: true,
    timeout: 300_000,
    maxBuffer: 10 * 1024 * 1024,
  });
  // Child diagnostics can contain connection credentials or customer data.
  if (result.error || result.status !== 0) throw new Error('PostgreSQL operation failed');
  return result.stdout.trim();
}
