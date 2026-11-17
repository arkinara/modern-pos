type Environment = Readonly<Record<string, string | undefined>>;

export class RuntimeConfigurationError extends Error {
  constructor(fields: string[]) {
    // Only variable names are diagnostic. Never interpolate submitted values.
    super(`Invalid runtime configuration: ${[...new Set(fields)].join(', ')}`);
    this.name = 'RuntimeConfigurationError';
  }
}

export function environmentName(env: Environment = process.env): string {
  return (env.NODE_ENV ?? 'development').trim().toLowerCase();
}

function enabled(value: string | undefined): boolean {
  return ['true', '1'].includes((value ?? '').trim().toLowerCase());
}

/** Independent of startup validation: production can never enable mock routes. */
export function sandboxPaymentsEnabled(env: Environment = process.env): boolean {
  return (
    ['development', 'test'].includes(environmentName(env)) &&
    enabled(env.PAYMENT_SANDBOX_ENABLED) &&
    (env.PAYMENT_MODE ?? 'sandbox').trim().toLowerCase() === 'sandbox' &&
    (env.PAYMENT_PROVIDER ?? 'mock').trim().toLowerCase() === 'mock'
  );
}

function placeholder(value: string | undefined, minimumLength: number): boolean {
  const text = value?.trim() ?? '';
  return (
    text.length < minimumLength ||
    /(?:change[-_ ]?me|replace[-_ ]?me|placeholder|modern-pos-local|local-development|^your[-_ <]|^example|^fake|^test[-_ ]|^demo[-_ ])/i.test(
      text,
    ) ||
    /^<.*>$/.test(text) ||
    new Set(text).size < 8
  );
}

export function validateProductionAuth(env: Environment = process.env): void {
  if (environmentName(env) !== 'production') return;
  const errors: string[] = [];
  if (placeholder(env.JWT_SECRET, 32)) errors.push('JWT_SECRET');
  if (!enabled(env.COOKIE_SECURE)) errors.push('COOKIE_SECURE');
  if (errors.length) throw new RuntimeConfigurationError(errors);
}

function validUrl(value: string, originOnly: boolean): boolean {
  try {
    const url = new URL(value);
    return (
      url.protocol === 'https:' &&
      !url.username &&
      !url.password &&
      !value.includes('*') &&
      !url.search &&
      !url.hash &&
      (!originOnly || url.origin === value)
    );
  } catch {
    return false;
  }
}

export interface RuntimeConfig {
  allowedOrigins: string[];
}

/** Called before Nest construction, database connection or opening a listener. */
export function validateRuntimeConfig(env: Environment = process.env): RuntimeConfig {
  const production = environmentName(env) === 'production';
  const errors: string[] = [];
  if (!['development', 'test', 'production'].includes(environmentName(env)))
    errors.push('NODE_ENV');
  const provider = (env.PAYMENT_PROVIDER ?? 'mock').trim().toLowerCase();
  const mode = (env.PAYMENT_MODE ?? 'sandbox').trim().toLowerCase();
  const flag = (env.PAYMENT_SANDBOX_ENABLED ?? 'false').trim().toLowerCase();
  if (!['mock', 'qris'].includes(provider)) errors.push('PAYMENT_PROVIDER');
  if (!['sandbox', 'live'].includes(mode)) errors.push('PAYMENT_MODE');
  if (!['true', 'false', '1', '0'].includes(flag)) errors.push('PAYMENT_SANDBOX_ENABLED');
  if (provider === 'mock' && !sandboxPaymentsEnabled(env)) errors.push('PAYMENT_SANDBOX_ENABLED');
  const origins = (env.WEB_ORIGIN ?? '').split(',').map((origin) => origin.trim());

  if (production) {
    if (placeholder(env.JWT_SECRET, 32)) errors.push('JWT_SECRET');
    if (!enabled(env.COOKIE_SECURE)) errors.push('COOKIE_SECURE');
    if (!env.WEB_ORIGIN?.trim() || origins.some((origin) => !validUrl(origin, true)))
      errors.push('WEB_ORIGIN');
    if (!env.PAYMENT_PROVIDER?.trim() || provider !== 'qris') errors.push('PAYMENT_PROVIDER');
    if (!env.PAYMENT_MODE?.trim()) errors.push('PAYMENT_MODE');
    if (enabled(env.PAYMENT_SANDBOX_ENABLED)) errors.push('PAYMENT_SANDBOX_ENABLED');
    if (placeholder(env.PAYMENT_WEBHOOK_SECRET, 32)) errors.push('PAYMENT_WEBHOOK_SECRET');
    if (placeholder(env.PAYMENT_PROVIDER_API_KEY, 8)) errors.push('PAYMENT_PROVIDER_API_KEY');
    if (!validUrl(env.PAYMENT_PROVIDER_BASE_URL?.trim() ?? '', false))
      errors.push('PAYMENT_PROVIDER_BASE_URL');
    // Channels are optional and already fail closed when unset; reject an unsafe
    // configured secret rather than letting a local example reach production.
    if (env.CHANNEL_WEBHOOK_SECRET !== undefined && placeholder(env.CHANNEL_WEBHOOK_SECRET, 32))
      errors.push('CHANNEL_WEBHOOK_SECRET');
  }
  if (errors.length) throw new RuntimeConfigurationError(errors);
  return { allowedOrigins: origins.filter(Boolean) };
}
