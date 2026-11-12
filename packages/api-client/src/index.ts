import type { components, paths } from './schema';

export type { components, paths };
export type ApiPaths = paths;
export type ApiSchemas = components['schemas'];

export interface HealthStatus {
  status: 'ok';
  service: 'modern-pos-api';
  version: string;
  database: 'up';
}

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly body: unknown,
    message = `API request failed with HTTP ${status}`,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export interface ApiClientOptions {
  baseUrl: string;
  fetchImpl?: typeof fetch;
  getAccessToken?: () => string | null;
  credentials?: RequestCredentials;
  onUnauthorized?: () => void;
}

export interface ApiClient {
  getHealth(): Promise<HealthStatus>;
  signInWeb(email: string, password: string): Promise<ApiSchemas['WebSession']>;
  refreshWeb(csrfToken: string): Promise<ApiSchemas['WebSession']>;
  signOut(): Promise<void>;
  getMe(): Promise<ApiSchemas['User']>;
  getOutlet(outletId: string): Promise<ApiSchemas['Outlet']>;
  getSettings(outletId: string): Promise<ApiSchemas['Settings']>;
  updateSettings(
    outletId: string,
    settings: ApiSchemas['SettingsUpdate'],
  ): Promise<ApiSchemas['Settings']>;
  getCategories(outletId: string): Promise<ApiSchemas['Category'][]>;
  createCategory(
    outletId: string,
    category: ApiSchemas['CategoryWrite'],
  ): Promise<ApiSchemas['Category']>;
  listMenu(
    outletId: string,
    query?: { cursor?: string; limit?: number; search?: string },
  ): Promise<ApiSchemas['MenuPage']>;
  createMenu(outletId: string, menu: ApiSchemas['MenuWrite']): Promise<ApiSchemas['Menu']>;
  updateMenu(
    outletId: string,
    menuId: string,
    menu: ApiSchemas['MenuUpdate'],
  ): Promise<ApiSchemas['Menu']>;
  archiveMenu(outletId: string, menuId: string, revision: number): Promise<void>;
  updateVariant(
    outletId: string,
    variantId: string,
    variant: ApiSchemas['VariantUpdate'],
  ): Promise<ApiSchemas['Variant']>;
  getRecipe(outletId: string, variantId: string): Promise<ApiSchemas['Recipe']>;
  publishRecipe(
    outletId: string,
    variantId: string,
    recipe: ApiSchemas['RecipeWrite'],
  ): Promise<ApiSchemas['Recipe']>;
  listStock(
    outletId: string,
    query?: { cursor?: string; limit?: number; search?: string },
  ): Promise<ApiSchemas['StockPage']>;
  createStock(outletId: string, stock: ApiSchemas['StockWrite']): Promise<ApiSchemas['Stock']>;
  listStockMovements(
    outletId: string,
    stockItemId: string,
    query?: { cursor?: string; limit?: number },
  ): Promise<ApiSchemas['MovementPage']>;
  recordOpeningBalance(
    outletId: string,
    idempotencyKey: string,
    change: ApiSchemas['StockChange'],
  ): Promise<ApiSchemas['Movement']>;
  recordStockReceipt(
    outletId: string,
    idempotencyKey: string,
    change: ApiSchemas['StockChange'],
  ): Promise<ApiSchemas['Movement']>;
  recordStockAdjustment(
    outletId: string,
    idempotencyKey: string,
    adjustment: ApiSchemas['Adjustment'],
  ): Promise<ApiSchemas['Movement']>;
  listSales(
    outletId: string,
    query?: { cursor?: string; limit?: number; from?: string; to?: string },
  ): Promise<ApiSchemas['SalePage']>;
  getSale(outletId: string, saleId: string): Promise<ApiSchemas['Sale']>;
  reverseSale(
    outletId: string,
    saleId: string,
    idempotencyKey: string,
    reversal: ApiSchemas['ReversalWrite'],
  ): Promise<ApiSchemas['Reversal']>;
  getDailyReport(
    outletId: string,
    query: { from: string; to: string },
  ): Promise<ApiSchemas['DailyReport']>;
  exportSalesCsv(
    outletId: string,
    query: { from: string; to: string },
  ): Promise<{ filename: string; csv: string }>;
  listPromotions(outletId: string): Promise<ApiSchemas['Promotion'][]>;
  createPromotion(
    outletId: string,
    promotion: ApiSchemas['PromotionWrite'],
  ): Promise<ApiSchemas['Promotion']>;
  updatePromotion(
    outletId: string,
    promotionId: string,
    promotion: ApiSchemas['PromotionUpdate'],
  ): Promise<ApiSchemas['Promotion']>;
  listModifiers(outletId: string): Promise<ApiSchemas['Modifier'][]>;
  createModifier(
    outletId: string,
    modifier: ApiSchemas['ModifierWrite'],
  ): Promise<ApiSchemas['Modifier']>;
  listApprovalRules(outletId: string): Promise<ApiSchemas['ApprovalRule'][]>;
  upsertApprovalRule(
    outletId: string,
    action: 'DISCOUNT' | 'REFUND',
    rule: ApiSchemas['ApprovalRuleWrite'],
  ): Promise<ApiSchemas['ApprovalRule']>;
}

function toQueryString(query: Record<string, string | number | undefined>): string {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined && value !== '') {
      params.set(key, String(value));
    }
  }
  const serialized = params.toString();
  return serialized.length > 0 ? `?${serialized}` : '';
}

function parseErrorBody(text: string): unknown {
  if (text.length === 0) {
    return null;
  }

  try {
    return JSON.parse(text) as unknown;
  } catch {
    return text;
  }
}

export function createApiClient({
  baseUrl,
  fetchImpl = globalThis.fetch,
  getAccessToken,
  credentials,
  onUnauthorized,
}: ApiClientOptions): ApiClient {
  const root = baseUrl.replace(/\/$/, '');

  async function request<T>(path: string, init?: RequestInit): Promise<T> {
    const accessToken = getAccessToken?.() ?? null;
    const response = await fetchImpl(`${root}${path}`, {
      ...init,
      credentials,
      headers: {
        Accept: 'application/json',
        ...(init?.body ? { 'Content-Type': 'application/json' } : {}),
        ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
        ...init?.headers,
      },
    });

    if (response.status === 401) {
      onUnauthorized?.();
    }

    if (!response.ok) {
      const body = parseErrorBody(await response.text());
      throw new ApiError(response.status, body);
    }

    if (response.status === 204) {
      return undefined as T;
    }

    return (await response.json()) as T;
  }

  async function requestText(
    path: string,
    init?: RequestInit,
  ): Promise<{ filename: string; body: string }> {
    const accessToken = getAccessToken?.() ?? null;
    const response = await fetchImpl(`${root}${path}`, {
      ...init,
      credentials,
      headers: {
        Accept: 'text/csv',
        ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
        ...init?.headers,
      },
    });

    if (response.status === 401) {
      onUnauthorized?.();
    }

    if (!response.ok) {
      const body = parseErrorBody(await response.text());
      throw new ApiError(response.status, body);
    }

    const disposition = response.headers.get('Content-Disposition') ?? '';
    const match = /filename="?([^";]+)"?/.exec(disposition);

    return {
      filename: match?.[1] ?? 'sales.csv',
      body: await response.text(),
    };
  }

  return {
    getHealth: () => request<HealthStatus>('/health'),
    signInWeb: (email, password) =>
      request<ApiSchemas['WebSession']>('/v1/auth/web/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      }),
    refreshWeb: (csrfToken) =>
      request<ApiSchemas['WebSession']>('/v1/auth/web/refresh', {
        method: 'POST',
        headers: { 'X-CSRF-Token': csrfToken },
      }),
    signOut: () => request<void>('/v1/auth/logout', { method: 'POST' }),
    getMe: () => request<ApiSchemas['User']>('/v1/auth/me'),
    getOutlet: (outletId) =>
      request<ApiSchemas['Outlet']>(`/v1/outlets/${encodeURIComponent(outletId)}`),
    getSettings: (outletId) =>
      request<ApiSchemas['Settings']>(`/v1/outlets/${encodeURIComponent(outletId)}/settings`),
    updateSettings: (outletId, settings) =>
      request<ApiSchemas['Settings']>(`/v1/outlets/${encodeURIComponent(outletId)}/settings`, {
        method: 'PATCH',
        body: JSON.stringify(settings),
      }),
    getCategories: (outletId) =>
      request<ApiSchemas['Category'][]>(`/v1/outlets/${encodeURIComponent(outletId)}/categories`),
    createCategory: (outletId, category) =>
      request<ApiSchemas['Category']>(`/v1/outlets/${encodeURIComponent(outletId)}/categories`, {
        method: 'POST',
        body: JSON.stringify(category),
      }),
    listMenu: (outletId, query = {}) =>
      request<ApiSchemas['MenuPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/menu${toQueryString(query)}`,
      ),
    createMenu: (outletId, menu) =>
      request<ApiSchemas['Menu']>(`/v1/outlets/${encodeURIComponent(outletId)}/menu`, {
        method: 'POST',
        body: JSON.stringify(menu),
      }),
    updateMenu: (outletId, menuId, menu) =>
      request<ApiSchemas['Menu']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/menu/${encodeURIComponent(menuId)}`,
        {
          method: 'PATCH',
          body: JSON.stringify(menu),
        },
      ),
    archiveMenu: (outletId, menuId, revision) =>
      request<void>(
        `/v1/outlets/${encodeURIComponent(outletId)}/menu/${encodeURIComponent(menuId)}/archive`,
        {
          method: 'POST',
          body: JSON.stringify({ revision }),
        },
      ),
    updateVariant: (outletId, variantId, variant) =>
      request<ApiSchemas['Variant']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/variants/${encodeURIComponent(variantId)}`,
        {
          method: 'PATCH',
          body: JSON.stringify(variant),
        },
      ),
    getRecipe: (outletId, variantId) =>
      request<ApiSchemas['Recipe']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/variants/${encodeURIComponent(
          variantId,
        )}/recipe`,
      ),
    publishRecipe: (outletId, variantId, recipe) =>
      request<ApiSchemas['Recipe']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/variants/${encodeURIComponent(
          variantId,
        )}/recipe`,
        {
          method: 'PUT',
          body: JSON.stringify(recipe),
        },
      ),
    listStock: (outletId, query = {}) =>
      request<ApiSchemas['StockPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock${toQueryString(query)}`,
      ),
    createStock: (outletId, stock) =>
      request<ApiSchemas['Stock']>(`/v1/outlets/${encodeURIComponent(outletId)}/stock`, {
        method: 'POST',
        body: JSON.stringify(stock),
      }),
    listStockMovements: (outletId, stockItemId, query = {}) =>
      request<ApiSchemas['MovementPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock/${encodeURIComponent(
          stockItemId,
        )}/movements${toQueryString(query)}`,
      ),
    recordOpeningBalance: (outletId, idempotencyKey, change) =>
      request<ApiSchemas['Movement']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock/opening-balances`,
        {
          method: 'POST',
          headers: { 'Idempotency-Key': idempotencyKey },
          body: JSON.stringify(change),
        },
      ),
    recordStockReceipt: (outletId, idempotencyKey, change) =>
      request<ApiSchemas['Movement']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock/receipts`,
        {
          method: 'POST',
          headers: { 'Idempotency-Key': idempotencyKey },
          body: JSON.stringify(change),
        },
      ),
    recordStockAdjustment: (outletId, idempotencyKey, adjustment) =>
      request<ApiSchemas['Movement']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock/adjustments`,
        {
          method: 'POST',
          headers: { 'Idempotency-Key': idempotencyKey },
          body: JSON.stringify(adjustment),
        },
      ),
    listSales: (outletId, query = {}) =>
      request<ApiSchemas['SalePage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/sales${toQueryString(query)}`,
      ),
    getSale: (outletId, saleId) =>
      request<ApiSchemas['Sale']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/sales/${encodeURIComponent(saleId)}`,
      ),
    reverseSale: (outletId, saleId, idempotencyKey, reversal) =>
      request<ApiSchemas['Reversal']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/sales/${encodeURIComponent(saleId)}/reversals`,
        {
          method: 'POST',
          headers: { 'Idempotency-Key': idempotencyKey },
          body: JSON.stringify(reversal),
        },
      ),
    getDailyReport: (outletId, query) =>
      request<ApiSchemas['DailyReport']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/reports/daily${toQueryString(query)}`,
      ),
    exportSalesCsv: async (outletId, query) => {
      const exported = await requestText(
        `/v1/outlets/${encodeURIComponent(outletId)}/reports/sales.csv${toQueryString(query)}`,
      );
      return { filename: exported.filename, csv: exported.body };
    },
    listPromotions: (outletId) =>
      request<ApiSchemas['Promotion'][]>(`/v1/outlets/${encodeURIComponent(outletId)}/promotions`),
    createPromotion: (outletId, promotion) =>
      request<ApiSchemas['Promotion']>(`/v1/outlets/${encodeURIComponent(outletId)}/promotions`, {
        method: 'POST',
        body: JSON.stringify(promotion),
      }),
    updatePromotion: (outletId, promotionId, promotion) =>
      request<ApiSchemas['Promotion']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/promotions/${encodeURIComponent(promotionId)}`,
        { method: 'PATCH', body: JSON.stringify(promotion) },
      ),
    listModifiers: (outletId) =>
      request<ApiSchemas['Modifier'][]>(`/v1/outlets/${encodeURIComponent(outletId)}/modifiers`),
    createModifier: (outletId, modifier) =>
      request<ApiSchemas['Modifier']>(`/v1/outlets/${encodeURIComponent(outletId)}/modifiers`, {
        method: 'POST',
        body: JSON.stringify(modifier),
      }),
    listApprovalRules: (outletId) =>
      request<ApiSchemas['ApprovalRule'][]>(
        `/v1/outlets/${encodeURIComponent(outletId)}/approval-rules`,
      ),
    upsertApprovalRule: (outletId, action, rule) =>
      request<ApiSchemas['ApprovalRule']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/approval-rules/${action}`,
        { method: 'PUT', body: JSON.stringify(rule) },
      ),
  };
}
