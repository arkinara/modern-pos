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
    query?: {
      cursor?: string;
      limit?: number;
      type?: ApiSchemas['Movement']['type'];
      reason?: string;
      supplierId?: string;
      supplierReference?: string;
    },
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
  createOnlinePayment(outletId: string, saleId: string): Promise<ApiSchemas['OnlinePayment']>;
  getOnlinePayment(outletId: string, saleId: string): Promise<ApiSchemas['OnlinePayment']>;
  refreshOnlinePayment(outletId: string, saleId: string): Promise<ApiSchemas['OnlinePayment']>;
  listOnlinePayments(
    outletId: string,
    query?: { limit?: number },
  ): Promise<ApiSchemas['OnlinePaymentList']>;
  reconcileOnlinePayments(outletId: string): Promise<ApiSchemas['ReconciliationSummary']>;
  getSettlementReport(
    outletId: string,
    query: { from: string; to: string },
  ): Promise<ApiSchemas['SettlementReport']>;
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
    action: 'DISCOUNT' | 'REFUND' | 'CASH_OUT',
    rule: ApiSchemas['ApprovalRuleWrite'],
  ): Promise<ApiSchemas['ApprovalRule']>;
  listShifts(
    outletId: string,
    query?: { status?: ApiSchemas['Shift']['status']; cursor?: string; limit?: number },
  ): Promise<ApiSchemas['ShiftPage']>;
  openShift(outletId: string, shift: ApiSchemas['ShiftWrite']): Promise<ApiSchemas['Shift']>;
  getShift(outletId: string, shiftId: string): Promise<ApiSchemas['Shift']>;
  recordShiftCashMovement(
    outletId: string,
    shiftId: string,
    movement: ApiSchemas['ShiftCashMovementWrite'],
  ): Promise<ApiSchemas['Shift']>;
  closeShift(
    outletId: string,
    shiftId: string,
    close: ApiSchemas['ShiftCloseWrite'],
  ): Promise<ApiSchemas['Shift']>;
  getShiftReport(outletId: string, shiftId: string): Promise<ApiSchemas['ShiftReport']>;
  listAttendance(
    outletId: string,
    query?: { userId?: string; from?: string; to?: string; cursor?: string; limit?: number },
  ): Promise<ApiSchemas['AttendancePage']>;
  clockInAttendance(
    outletId: string,
    body: ApiSchemas['AttendanceWrite'],
  ): Promise<ApiSchemas['AttendanceRecord']>;
  clockOutAttendance(
    outletId: string,
    body: ApiSchemas['AttendanceWrite'],
  ): Promise<ApiSchemas['AttendanceRecord']>;
  getPermissionMatrix(outletId: string): Promise<ApiSchemas['PermissionMatrix']>;
  searchAudit(
    outletId: string,
    query?: {
      actorId?: string;
      from?: string;
      to?: string;
      action?: ApiSchemas['OperationAuditEntry']['action'];
      cursor?: string;
      limit?: number;
    },
  ): Promise<ApiSchemas['OperationAuditPage']>;
  listSuppliers(
    outletId: string,
    query?: { cursor?: string; limit?: number; search?: string },
  ): Promise<ApiSchemas['SupplierPage']>;
  createSupplier(
    outletId: string,
    supplier: ApiSchemas['SupplierWrite'],
  ): Promise<ApiSchemas['Supplier']>;
  listPurchaseOrders(
    outletId: string,
    query?: { cursor?: string; limit?: number },
  ): Promise<ApiSchemas['PurchaseOrderPage']>;
  createPurchaseOrder(
    outletId: string,
    order: ApiSchemas['PurchaseOrderWrite'],
  ): Promise<ApiSchemas['PurchaseOrder']>;
  receivePurchaseOrder(
    outletId: string,
    purchaseOrderId: string,
    receipt: ApiSchemas['PurchaseOrderReceiptWrite'],
  ): Promise<ApiSchemas['PurchaseOrderReceipt']>;
  cancelPurchaseOrder(
    outletId: string,
    purchaseOrderId: string,
  ): Promise<ApiSchemas['PurchaseOrder']>;
  listStockCounts(
    outletId: string,
    query?: { cursor?: string; limit?: number },
  ): Promise<ApiSchemas['StockCountPage']>;
  createStockCount(
    outletId: string,
    count: ApiSchemas['StockCountWrite'],
  ): Promise<ApiSchemas['StockCount']>;
  listWaste(
    outletId: string,
    query?: { cursor?: string; limit?: number },
  ): Promise<ApiSchemas['WastePage']>;
  recordWaste(outletId: string, waste: ApiSchemas['WasteWrite']): Promise<ApiSchemas['Waste']>;
  listTransfers(
    outletId: string,
    query?: { state?: ApiSchemas['OutletTransfer']['state']; cursor?: string; limit?: number },
  ): Promise<ApiSchemas['OutletTransferPage']>;
  createTransfer(
    outletId: string,
    transfer: ApiSchemas['OutletTransferWrite'],
  ): Promise<ApiSchemas['OutletTransfer']>;
  dispatchTransfer(
    outletId: string,
    transferId: string,
  ): Promise<ApiSchemas['OutletTransferMutation']>;
  receiveTransfer(
    outletId: string,
    transferId: string,
    receipt: ApiSchemas['OutletTransferReceiveWrite'],
  ): Promise<ApiSchemas['OutletTransferMutation']>;
  cancelTransfer(outletId: string, transferId: string): Promise<ApiSchemas['OutletTransfer']>;
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
    createOnlinePayment: (outletId, saleId) =>
      request<ApiSchemas['OnlinePayment']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/sales/${encodeURIComponent(saleId)}/online-payment`,
        { method: 'POST' },
      ),
    getOnlinePayment: (outletId, saleId) =>
      request<ApiSchemas['OnlinePayment']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/sales/${encodeURIComponent(saleId)}/online-payment`,
      ),
    refreshOnlinePayment: (outletId, saleId) =>
      request<ApiSchemas['OnlinePayment']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/sales/${encodeURIComponent(saleId)}/online-payment/refresh`,
        { method: 'POST' },
      ),
    listOnlinePayments: (outletId, query) =>
      request<ApiSchemas['OnlinePaymentList']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/online-payments${toQueryString({
          limit: query?.limit,
        })}`,
      ),
    reconcileOnlinePayments: (outletId) =>
      request<ApiSchemas['ReconciliationSummary']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/online-payments/reconcile`,
        { method: 'POST' },
      ),
    getSettlementReport: (outletId, query) =>
      request<ApiSchemas['SettlementReport']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/online-payments/settlements${toQueryString(query)}`,
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
    listShifts: (outletId, query = {}) =>
      request<ApiSchemas['ShiftPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/shifts${toQueryString(query)}`,
      ),
    openShift: (outletId, shift) =>
      request<ApiSchemas['Shift']>(`/v1/outlets/${encodeURIComponent(outletId)}/shifts`, {
        method: 'POST',
        body: JSON.stringify(shift),
      }),
    getShift: (outletId, shiftId) =>
      request<ApiSchemas['Shift']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/shifts/${encodeURIComponent(shiftId)}`,
      ),
    recordShiftCashMovement: (outletId, shiftId, movement) =>
      request<ApiSchemas['Shift']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/shifts/${encodeURIComponent(
          shiftId,
        )}/cash-movements`,
        { method: 'POST', body: JSON.stringify(movement) },
      ),
    closeShift: (outletId, shiftId, close) =>
      request<ApiSchemas['Shift']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/shifts/${encodeURIComponent(shiftId)}/close`,
        { method: 'POST', body: JSON.stringify(close) },
      ),
    getShiftReport: (outletId, shiftId) =>
      request<ApiSchemas['ShiftReport']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/shifts/${encodeURIComponent(shiftId)}/report`,
      ),
    listAttendance: (outletId, query = {}) =>
      request<ApiSchemas['AttendancePage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/attendance${toQueryString(query)}`,
      ),
    clockInAttendance: (outletId, body) =>
      request<ApiSchemas['AttendanceRecord']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/attendance/clock-in`,
        { method: 'POST', body: JSON.stringify(body) },
      ),
    clockOutAttendance: (outletId, body) =>
      request<ApiSchemas['AttendanceRecord']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/attendance/clock-out`,
        { method: 'POST', body: JSON.stringify(body) },
      ),
    getPermissionMatrix: (outletId) =>
      request<ApiSchemas['PermissionMatrix']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/permissions`,
      ),
    searchAudit: (outletId, query = {}) =>
      request<ApiSchemas['OperationAuditPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/audit${toQueryString(query)}`,
      ),
    listSuppliers: (outletId, query = {}) =>
      request<ApiSchemas['SupplierPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/suppliers${toQueryString(query)}`,
      ),
    createSupplier: (outletId, supplier) =>
      request<ApiSchemas['Supplier']>(`/v1/outlets/${encodeURIComponent(outletId)}/suppliers`, {
        method: 'POST',
        body: JSON.stringify(supplier),
      }),
    listPurchaseOrders: (outletId, query = {}) =>
      request<ApiSchemas['PurchaseOrderPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/purchase-orders${toQueryString(query)}`,
      ),
    createPurchaseOrder: (outletId, order) =>
      request<ApiSchemas['PurchaseOrder']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/purchase-orders`,
        { method: 'POST', body: JSON.stringify(order) },
      ),
    receivePurchaseOrder: (outletId, purchaseOrderId, receipt) =>
      request<ApiSchemas['PurchaseOrderReceipt']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/purchase-orders/${encodeURIComponent(
          purchaseOrderId,
        )}/receipts`,
        { method: 'POST', body: JSON.stringify(receipt) },
      ),
    cancelPurchaseOrder: (outletId, purchaseOrderId) =>
      request<ApiSchemas['PurchaseOrder']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/purchase-orders/${encodeURIComponent(
          purchaseOrderId,
        )}/cancel`,
        { method: 'POST' },
      ),
    listStockCounts: (outletId, query = {}) =>
      request<ApiSchemas['StockCountPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock-counts${toQueryString(query)}`,
      ),
    createStockCount: (outletId, count) =>
      request<ApiSchemas['StockCount']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock-counts`,
        { method: 'POST', body: JSON.stringify(count) },
      ),
    listWaste: (outletId, query = {}) =>
      request<ApiSchemas['WastePage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/stock-wastes${toQueryString(query)}`,
      ),
    recordWaste: (outletId, waste) =>
      request<ApiSchemas['Waste']>(`/v1/outlets/${encodeURIComponent(outletId)}/stock-wastes`, {
        method: 'POST',
        body: JSON.stringify(waste),
      }),
    listTransfers: (outletId, query = {}) =>
      request<ApiSchemas['OutletTransferPage']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/transfers${toQueryString(query)}`,
      ),
    createTransfer: (outletId, transfer) =>
      request<ApiSchemas['OutletTransfer']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/transfers`,
        {
          method: 'POST',
          body: JSON.stringify(transfer),
        },
      ),
    dispatchTransfer: (outletId, transferId) =>
      request<ApiSchemas['OutletTransferMutation']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/transfers/${encodeURIComponent(
          transferId,
        )}/dispatch`,
        { method: 'POST' },
      ),
    receiveTransfer: (outletId, transferId, receipt) =>
      request<ApiSchemas['OutletTransferMutation']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/transfers/${encodeURIComponent(
          transferId,
        )}/receive`,
        { method: 'POST', body: JSON.stringify(receipt) },
      ),
    cancelTransfer: (outletId, transferId) =>
      request<ApiSchemas['OutletTransfer']>(
        `/v1/outlets/${encodeURIComponent(outletId)}/transfers/${encodeURIComponent(
          transferId,
        )}/cancel`,
        { method: 'POST' },
      ),
  };
}
