'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import {
  ArrowRightLeft,
  ClipboardCheck,
  PackageCheck,
  PackagePlus,
  RefreshCw,
  Search,
  ShoppingBasket,
  Trash2,
  Truck,
  Users,
} from 'lucide-react';
import { useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { apiErrorCode, describeApiError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { useActiveOutletId } from '@/lib/use-active-outlet';

type Supplier = ApiSchemas['Supplier'];
type PurchaseOrder = ApiSchemas['PurchaseOrder'];
type PurchaseOrderLine = ApiSchemas['PurchaseOrderLine'];
type StockCount = ApiSchemas['StockCount'];
type Waste = ApiSchemas['Waste'];
type Transfer = ApiSchemas['OutletTransfer'];
type TransferLine = ApiSchemas['OutletTransferLine'];
type Movement = ApiSchemas['Movement'];
type StockItem = ApiSchemas['Stock'];

type Section = 'SUPPLIERS' | 'ORDERS' | 'COUNTS' | 'WASTE' | 'TRANSFERS' | 'LEDGER';
type Feedback = { tone: 'success' | 'error'; message: string };
type ReceiptUnit = 'SUPPLIER' | 'BASE';
type TransferLineDraft = { quantity: string };

const inputClass =
  'h-11 w-full rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted';
const labelClass = 'flex flex-col gap-1 text-sm font-medium text-text';

const SECTIONS: { id: Section; label: string; icon: typeof Users }[] = [
  { id: 'SUPPLIERS', label: 'Suppliers', icon: Users },
  { id: 'ORDERS', label: 'Purchase orders', icon: ShoppingBasket },
  { id: 'COUNTS', label: 'Stock counts', icon: ClipboardCheck },
  { id: 'WASTE', label: 'Waste', icon: Trash2 },
  { id: 'TRANSFERS', label: 'Transfers', icon: Truck },
  { id: 'LEDGER', label: 'Movement ledger', icon: Search },
];

const WASTE_REASONS: ApiSchemas['WasteWrite']['reason'][] = [
  'DAMAGE',
  'EXPIRY',
  'THEFT',
  'SPOILAGE',
  'OTHER',
];

function shortId(value: string): string {
  return value.slice(0, 8);
}

function stateTone(state: string): 'neutral' | 'accent' | 'success' | 'warning' | 'danger' {
  if (state === 'RECEIVED') return 'success';
  if (state === 'PARTIALLY_RECEIVED' || state === 'DISPATCHED') return 'warning';
  if (state === 'CANCELLED') return 'danger';
  if (state === 'OPEN' || state === 'DRAFT') return 'accent';
  return 'neutral';
}

function formatTimestamp(value: string | null): string {
  if (!value) return '—';
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? value : parsed.toLocaleString();
}

function describePurchasingError(error: unknown, fallback: string): string {
  const code = apiErrorCode(error);
  if (code === 'OVER_RECEIPT') return 'This receipt would exceed the ordered quantity.';
  if (code === 'CONVERSION_NOT_EXACT')
    return 'That unit cannot be converted exactly. Adjust the quantity.';
  if (code === 'CONVERSION_OVERFLOW') return 'That converted quantity is too large.';
  if (code === 'QUANTITY_PRECISION_EXCEEDED')
    return 'That quantity has more decimals than the item allows.';
  if (code === 'PURCHASE_ORDER_CLOSED' || code === 'PURCHASE_ORDER_CANCELLED')
    return 'This purchase order is closed and cannot receive more stock.';
  if (code === 'INSUFFICIENT_STOCK')
    return 'The outlet does not have enough stock for that movement.';
  if (code === 'TRANSFER_ALREADY_RECEIVED') return 'This transfer was already received.';
  if (code === 'RECEIVE_EXCEEDS_DISPATCHED')
    return 'Received quantity is above the dispatched quantity.';
  if (code === 'TRANSFER_PARTIALLY_RECEIVED')
    return 'A partially received transfer cannot be cancelled.';
  return describeApiError(error, fallback);
}

function LoadingCard({ label }: { label: string }) {
  return (
    <div
      className="flex min-h-40 flex-col items-center justify-center gap-3 rounded-surface border border-border bg-surface p-6"
      role="status"
    >
      <span className="size-7 animate-spin rounded-full border-2 border-border border-t-accent" />
      <p className="text-sm text-muted">{label}</p>
    </div>
  );
}

function ErrorCard({ error, onRetry }: { error: unknown; onRetry: () => void }) {
  return (
    <div className="rounded-surface border border-danger bg-danger-soft p-4">
      <p role="alert" className="text-sm text-danger">
        {describePurchasingError(
          error,
          'The request failed. Check the API connection and try again.',
        )}
      </p>
      <Button type="button" variant="outline" size="sm" className="mt-3" onClick={onRetry}>
        <RefreshCw aria-hidden="true" className="size-4" />
        Try again
      </Button>
    </div>
  );
}

function EmptyState({ title, detail }: { title: string; detail: string }) {
  return (
    <div className="rounded-control border border-dashed border-border bg-surface-tint p-5 text-sm text-muted">
      <p className="font-medium text-text">{title}</p>
      <p className="mt-1">{detail}</p>
    </div>
  );
}

export function PurchasingScreen() {
  const outletId = useActiveOutletId();
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const isOwner = user?.role === 'OWNER';
  const [section, setSection] = useState<Section>('SUPPLIERS');
  const [feedback, setFeedback] = useState<Feedback | null>(null);

  const suppliersQuery = useQuery({
    queryKey: ['suppliers', outletId],
    queryFn: () => api.listSuppliers(outletId as string, { limit: 100 }),
    enabled: Boolean(outletId),
    retry: 1,
  });
  const ordersQuery = useQuery({
    queryKey: ['purchase-orders', outletId],
    queryFn: () => api.listPurchaseOrders(outletId as string, { limit: 50 }),
    enabled: Boolean(outletId),
    retry: 1,
  });
  const countsQuery = useQuery({
    queryKey: ['stock-counts', outletId],
    queryFn: () => api.listStockCounts(outletId as string, { limit: 50 }),
    enabled: Boolean(outletId),
    retry: 1,
  });
  const wasteQuery = useQuery({
    queryKey: ['stock-waste', outletId],
    queryFn: () => api.listWaste(outletId as string, { limit: 50 }),
    enabled: Boolean(outletId),
    retry: 1,
  });
  const transfersQuery = useQuery({
    queryKey: ['transfers', outletId],
    queryFn: () => api.listTransfers(outletId as string, { limit: 50 }),
    enabled: Boolean(outletId),
    retry: 1,
  });
  const stockQuery = useQuery({
    queryKey: ['stock', outletId, 'purchasing'],
    queryFn: () => api.listStock(outletId as string, { limit: 100 }),
    enabled: Boolean(outletId),
    retry: 1,
  });

  const suppliers = suppliersQuery.data?.items ?? [];
  const orders = ordersQuery.data?.items ?? [];
  const counts = countsQuery.data?.items ?? [];
  const wastes = wasteQuery.data?.items ?? [];
  const transfers = transfersQuery.data?.items ?? [];
  const stockItems = stockQuery.data?.items ?? [];

  function invalidateStock(): void {
    void queryClient.invalidateQueries({ queryKey: ['stock', outletId] });
    void queryClient.invalidateQueries({ queryKey: ['stock-movements', outletId] });
  }

  function notify(tone: Feedback['tone'], message: string): void {
    setFeedback({ tone, message });
  }

  if (!outletId) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>No outlet assigned</CardTitle>
          <CardDescription>This account has no outlet scope.</CardDescription>
        </CardHeader>
      </Card>
    );
  }

  const visibleSections = isOwner
    ? SECTIONS
    : SECTIONS.filter((item) => item.id === 'COUNTS' || item.id === 'WASTE');
  const effectiveSection: Section =
    isOwner || section === 'COUNTS' || section === 'WASTE' ? section : 'COUNTS';

  return (
    <div className="flex w-full flex-col gap-6">
      <header className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight text-text">
            Purchasing & stock control
          </h1>
          <p className="mt-2 max-w-3xl text-sm text-muted">
            {isOwner
              ? 'Suppliers, purchase orders with partial receipt and unit conversion, stock counts, waste, outlet transfers and the append-only movement ledger.'
              : 'Count stock and record waste for your outlet. Suppliers, purchase orders and outlet transfers are owner operations.'}
          </p>
        </div>
        <Button
          type="button"
          variant="outline"
          onClick={() => {
            void queryClient.invalidateQueries();
            notify('success', 'Reloading purchasing data.');
          }}
        >
          <RefreshCw aria-hidden="true" className="size-4" />
          Reload
        </Button>
      </header>

      {feedback ? (
        <div
          role={feedback.tone === 'error' ? 'alert' : 'status'}
          className={
            feedback.tone === 'success'
              ? 'rounded-control bg-success-soft px-4 py-3 text-sm text-success'
              : 'rounded-control bg-danger-soft px-4 py-3 text-sm text-danger'
          }
        >
          {feedback.message}
        </div>
      ) : null}

      <nav aria-label="Purchasing sections" className="flex flex-wrap gap-2">
        {visibleSections.map((item) => {
          const Icon = item.icon;
          return (
            <button
              key={item.id}
              type="button"
              aria-pressed={effectiveSection === item.id}
              onClick={() => setSection(item.id)}
              className={
                effectiveSection === item.id
                  ? 'inline-flex min-h-10 items-center gap-2 rounded-control bg-accent px-3 text-sm font-medium text-surface'
                  : 'inline-flex min-h-10 items-center gap-2 rounded-control border border-control bg-surface px-3 text-sm font-medium text-text hover:bg-surface-muted'
              }
            >
              <Icon aria-hidden="true" className="size-4" />
              {item.label}
            </button>
          );
        })}
      </nav>

      {effectiveSection === 'SUPPLIERS' && isOwner ? (
        <SupplierSection
          outletId={outletId}
          suppliers={suppliers}
          loading={suppliersQuery.isPending}
          error={suppliersQuery.isError ? suppliersQuery.error : null}
          onRetry={() => void suppliersQuery.refetch()}
          onSaved={(message) => {
            notify('success', message);
            void queryClient.invalidateQueries({ queryKey: ['suppliers', outletId] });
          }}
          onError={(message) => notify('error', message)}
        />
      ) : null}

      {effectiveSection === 'ORDERS' && isOwner ? (
        <PurchaseOrderSection
          outletId={outletId}
          suppliers={suppliers}
          stockItems={stockItems}
          orders={orders}
          loading={ordersQuery.isPending || stockQuery.isPending}
          error={ordersQuery.isError ? ordersQuery.error : null}
          onRetry={() => void ordersQuery.refetch()}
          onChanged={(message) => {
            notify('success', message);
            void queryClient.invalidateQueries({ queryKey: ['purchase-orders', outletId] });
            invalidateStock();
          }}
          onError={(message) => notify('error', message)}
        />
      ) : null}

      {effectiveSection === 'COUNTS' ? (
        <StockCountSection
          outletId={outletId}
          stockItems={stockItems}
          counts={counts}
          loading={countsQuery.isPending || stockQuery.isPending}
          error={countsQuery.isError ? countsQuery.error : null}
          onRetry={() => void countsQuery.refetch()}
          onChanged={(message) => {
            notify('success', message);
            void queryClient.invalidateQueries({ queryKey: ['stock-counts', outletId] });
            invalidateStock();
          }}
          onError={(message) => notify('error', message)}
        />
      ) : null}

      {effectiveSection === 'WASTE' ? (
        <WasteSection
          outletId={outletId}
          stockItems={stockItems}
          wastes={wastes}
          loading={wasteQuery.isPending || stockQuery.isPending}
          error={wasteQuery.isError ? wasteQuery.error : null}
          onRetry={() => void wasteQuery.refetch()}
          onChanged={(message) => {
            notify('success', message);
            void queryClient.invalidateQueries({ queryKey: ['stock-waste', outletId] });
            invalidateStock();
          }}
          onError={(message) => notify('error', message)}
        />
      ) : null}

      {effectiveSection === 'TRANSFERS' && isOwner ? (
        <TransferSection
          outletId={outletId}
          outletIds={user?.outletIds ?? []}
          stockItems={stockItems}
          transfers={transfers}
          loading={transfersQuery.isPending || stockQuery.isPending}
          error={transfersQuery.isError ? transfersQuery.error : null}
          onRetry={() => void transfersQuery.refetch()}
          onChanged={(message) => {
            notify('success', message);
            void queryClient.invalidateQueries({ queryKey: ['transfers', outletId] });
            invalidateStock();
          }}
          onError={(message) => notify('error', message)}
        />
      ) : null}

      {effectiveSection === 'LEDGER' && isOwner ? (
        <LedgerSection
          outletId={outletId}
          stockItems={stockItems}
          suppliers={suppliers}
          loading={stockQuery.isPending}
          onError={(message) => notify('error', message)}
        />
      ) : null}
    </div>
  );
}

function SupplierSection({
  outletId,
  suppliers,
  loading,
  error,
  onRetry,
  onSaved,
  onError,
}: {
  outletId: string;
  suppliers: Supplier[];
  loading: boolean;
  error: unknown;
  onRetry: () => void;
  onSaved: (message: string) => void;
  onError: (message: string) => void;
}) {
  const [name, setName] = useState('');
  const [reference, setReference] = useState('');
  const [contact, setContact] = useState('');
  const [busy, setBusy] = useState(false);

  async function submit(): Promise<void> {
    if (name.trim().length === 0) {
      onError('A supplier name is required.');
      return;
    }
    setBusy(true);
    try {
      await api.createSupplier(outletId, {
        name: name.trim(),
        reference: reference.trim() || undefined,
        contact: contact.trim() || undefined,
      });
      setName('');
      setReference('');
      setContact('');
      onSaved('Supplier created.');
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not create the supplier.'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,2fr)]">
      <Card>
        <CardHeader>
          <CardTitle>New supplier</CardTitle>
          <CardDescription>Name is required. Reference and contact are optional.</CardDescription>
        </CardHeader>
        <CardContent>
          <form
            className="flex flex-col gap-3"
            onSubmit={(event) => {
              event.preventDefault();
              void submit();
            }}
          >
            <label className={labelClass}>
              Name
              <input
                className={inputClass}
                value={name}
                maxLength={200}
                onChange={(event) => setName(event.target.value)}
                required
              />
            </label>
            <label className={labelClass}>
              Reference
              <input
                className={inputClass}
                value={reference}
                maxLength={100}
                onChange={(event) => setReference(event.target.value)}
              />
            </label>
            <label className={labelClass}>
              Contact
              <input
                className={inputClass}
                value={contact}
                maxLength={300}
                onChange={(event) => setContact(event.target.value)}
              />
            </label>
            <Button type="submit" disabled={busy}>
              <PackagePlus aria-hidden="true" className="size-4" />
              {busy ? 'Saving' : 'Create supplier'}
            </Button>
          </form>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardTitle>Suppliers</CardTitle>
          <CardDescription>
            Business-wide supplier records available to every outlet.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? <LoadingCard label="Loading suppliers" /> : null}
          {error ? <ErrorCard error={error} onRetry={onRetry} /> : null}
          {!loading && !error && suppliers.length === 0 ? (
            <EmptyState
              title="No suppliers yet"
              detail="Create the first supplier before raising a purchase order."
            />
          ) : null}
          <ul className="flex flex-col divide-y divide-border">
            {suppliers.map((supplier) => (
              <li
                key={supplier.id}
                className="flex flex-wrap items-center justify-between gap-3 py-3 first:pt-0 last:pb-0"
              >
                <div className="min-w-0">
                  <p className="truncate font-medium text-text">{supplier.name}</p>
                  <p className="text-sm text-muted">
                    {supplier.reference ?? 'No reference'} · {supplier.contact ?? 'No contact'}
                  </p>
                </div>
                <Badge tone="neutral">{shortId(supplier.id)}</Badge>
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}

function PurchaseOrderSection({
  outletId,
  suppliers,
  stockItems,
  orders,
  loading,
  error,
  onRetry,
  onChanged,
  onError,
}: {
  outletId: string;
  suppliers: Supplier[];
  stockItems: StockItem[];
  orders: PurchaseOrder[];
  loading: boolean;
  error: unknown;
  onRetry: () => void;
  onChanged: (message: string) => void;
  onError: (message: string) => void;
}) {
  const [supplierId, setSupplierId] = useState('');
  const [reference, setReference] = useState('');
  const [stockItemId, setStockItemId] = useState('');
  const [supplierUnit, setSupplierUnit] = useState('case');
  const [unitsPerSupplierUnit, setUnitsPerSupplierUnit] = useState('1');
  const [orderedQuantity, setOrderedQuantity] = useState('');
  const [unitPrice, setUnitPrice] = useState('0');
  const [busy, setBusy] = useState(false);
  const [receipts, setReceipts] = useState<
    Record<string, { quantity: string; unit: ReceiptUnit; note: string }>
  >({});
  const [receivingLineId, setReceivingLineId] = useState<string | null>(null);

  function receiptFor(line: PurchaseOrderLine) {
    return (
      receipts[line.id] ?? {
        quantity: line.remainingQuantity,
        unit: 'SUPPLIER' as ReceiptUnit,
        note: '',
      }
    );
  }

  function updateReceipt(
    lineId: string,
    patch: Partial<{ quantity: string; unit: ReceiptUnit; note: string }>,
  ): void {
    setReceipts((current) => ({
      ...current,
      [lineId]: { ...(current[lineId] ?? { quantity: '', unit: 'SUPPLIER', note: '' }), ...patch },
    }));
  }

  async function cancelOrder(order: PurchaseOrder): Promise<void> {
    setBusy(true);
    try {
      await api.cancelPurchaseOrder(outletId, order.id);
      onChanged(`Purchase order ${order.reference} cancelled.`);
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not cancel the purchase order.'));
    } finally {
      setBusy(false);
    }
  }

  async function createOrder(): Promise<void> {
    if (!supplierId || !stockItemId || orderedQuantity.trim() === '') {
      onError('Choose a supplier and stock item, then enter the ordered quantity.');
      return;
    }
    setBusy(true);
    try {
      await api.createPurchaseOrder(outletId, {
        supplierId,
        reference: reference.trim() || undefined,
        lines: [
          {
            stockItemId,
            supplierUnit: supplierUnit.trim() || 'unit',
            unitsPerSupplierUnit,
            orderedQuantity: orderedQuantity.trim(),
            unitPrice: unitPrice.trim() || '0',
          },
        ],
      });
      setReference('');
      setOrderedQuantity('');
      onChanged('Purchase order created.');
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not create the purchase order.'));
    } finally {
      setBusy(false);
    }
  }

  async function receive(order: PurchaseOrder, line: PurchaseOrderLine): Promise<void> {
    const draft = receiptFor(line);
    setReceivingLineId(line.id);
    try {
      await api.receivePurchaseOrder(outletId, order.id, {
        lineId: line.id,
        quantity: draft.quantity.trim(),
        unit: draft.unit,
        note: draft.note.trim() || undefined,
      });
      onChanged(`Received stock for ${order.reference}.`);
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not receive the purchase order.'));
    } finally {
      setReceivingLineId(null);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <Card>
        <CardHeader>
          <CardTitle>Create purchase order</CardTitle>
          <CardDescription>
            Ordered quantity uses supplier units. The server stores the exact base-unit conversion
            and rejects fractions the stock item cannot represent.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form
            className="grid gap-4 md:grid-cols-2 xl:grid-cols-4"
            onSubmit={(event) => {
              event.preventDefault();
              void createOrder();
            }}
          >
            <label className={labelClass}>
              Supplier
              <select
                className={inputClass}
                value={supplierId}
                onChange={(event) => setSupplierId(event.target.value)}
                required
              >
                <option value="">Choose supplier</option>
                {suppliers.map((supplier) => (
                  <option key={supplier.id} value={supplier.id}>
                    {supplier.name}
                  </option>
                ))}
              </select>
            </label>
            <label className={labelClass}>
              Stock item
              <select
                className={inputClass}
                value={stockItemId}
                onChange={(event) => setStockItemId(event.target.value)}
                required
              >
                <option value="">Choose item</option>
                {stockItems.map((item) => (
                  <option key={item.id} value={item.id}>
                    {item.name} ({item.baseUnit})
                  </option>
                ))}
              </select>
            </label>
            <label className={labelClass}>
              Reference
              <input
                className={inputClass}
                value={reference}
                maxLength={100}
                onChange={(event) => setReference(event.target.value)}
                placeholder="Optional"
              />
            </label>
            <label className={labelClass}>
              Supplier unit
              <input
                className={inputClass}
                value={supplierUnit}
                maxLength={50}
                onChange={(event) => setSupplierUnit(event.target.value)}
                placeholder="case"
              />
            </label>
            <label className={labelClass}>
              Base units per supplier unit
              <input
                className={inputClass}
                inputMode="decimal"
                value={unitsPerSupplierUnit}
                onChange={(event) => setUnitsPerSupplierUnit(event.target.value)}
                placeholder="12"
              />
            </label>
            <label className={labelClass}>
              Ordered supplier quantity
              <input
                className={inputClass}
                inputMode="decimal"
                value={orderedQuantity}
                onChange={(event) => setOrderedQuantity(event.target.value)}
                placeholder="10"
              />
            </label>
            <label className={labelClass}>
              Unit price
              <input
                className={inputClass}
                inputMode="decimal"
                value={unitPrice}
                onChange={(event) => setUnitPrice(event.target.value)}
                placeholder="0"
              />
            </label>
            <div className="flex items-end">
              <Button type="submit" className="w-full" disabled={busy}>
                <PackagePlus aria-hidden="true" className="size-4" />
                {busy ? 'Creating' : 'Create order'}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Purchase orders</CardTitle>
          <CardDescription>
            Receive partially or fully. Every receipt writes a base-unit ledger entry.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {loading ? <LoadingCard label="Loading purchase orders" /> : null}
          {error ? <ErrorCard error={error} onRetry={onRetry} /> : null}
          {!loading && !error && orders.length === 0 ? (
            <EmptyState
              title="No purchase orders"
              detail="Create an order to start receiving stock."
            />
          ) : null}
          {orders.map((order) => (
            <div
              key={order.id}
              className="rounded-control border border-border bg-surface-tint p-4"
            >
              <div className="flex flex-wrap items-center justify-between gap-2">
                <div>
                  <p className="font-medium text-text">
                    {order.reference} · {order.supplierName}
                  </p>
                  <p className="text-sm text-muted">
                    Supplier reference {order.supplierReference ?? '—'} · Created{' '}
                    {formatTimestamp(order.createdAt)}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <Badge tone={stateTone(order.state)}>{order.state.replace('_', ' ')}</Badge>
                  {order.state === 'OPEN' ? (
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      disabled={busy}
                      onClick={() => void cancelOrder(order)}
                    >
                      Cancel order
                    </Button>
                  ) : null}
                </div>
              </div>
              <div className="mt-4 flex flex-col gap-3">
                {order.lines.map((line) => {
                  const draft = receiptFor(line);
                  return (
                    <div
                      key={line.id}
                      className="rounded-control border border-border bg-surface p-3"
                    >
                      <div className="flex flex-wrap items-center justify-between gap-2">
                        <p className="font-medium text-text">{line.stockItemName}</p>
                        <p className="text-sm text-muted">
                          {line.receivedQuantity} / {line.orderedQuantity} {line.supplierUnit} ·
                          base {line.receivedBaseQuantity} / {line.orderedBaseQuantity}{' '}
                          {line.baseUnit}
                        </p>
                      </div>
                      {order.state !== 'RECEIVED' && order.state !== 'CANCELLED' ? (
                        <div className="mt-3 grid gap-2 md:grid-cols-[1fr_8rem_1fr_auto]">
                          <label className="text-xs font-medium text-muted">
                            Quantity (
                            {draft.unit === 'SUPPLIER' ? line.supplierUnit : line.baseUnit})
                            <input
                              className={inputClass}
                              inputMode="decimal"
                              value={draft.quantity}
                              onChange={(event) =>
                                updateReceipt(line.id, { quantity: event.target.value })
                              }
                            />
                          </label>
                          <label className="text-xs font-medium text-muted">
                            Unit
                            <select
                              className={inputClass}
                              value={draft.unit}
                              onChange={(event) =>
                                updateReceipt(line.id, { unit: event.target.value as ReceiptUnit })
                              }
                            >
                              <option value="SUPPLIER">Supplier</option>
                              <option value="BASE">Base</option>
                            </select>
                          </label>
                          <label className="text-xs font-medium text-muted">
                            Note
                            <input
                              className={inputClass}
                              value={draft.note}
                              maxLength={300}
                              onChange={(event) =>
                                updateReceipt(line.id, { note: event.target.value })
                              }
                            />
                          </label>
                          <div className="flex items-end">
                            <Button
                              type="button"
                              variant="outline"
                              onClick={() => void receive(order, line)}
                              disabled={receivingLineId === line.id}
                            >
                              <PackageCheck aria-hidden="true" className="size-4" />
                              {receivingLineId === line.id ? 'Receiving' : 'Receive'}
                            </Button>
                          </div>
                        </div>
                      ) : null}
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}

function StockCountSection({
  outletId,
  stockItems,
  counts,
  loading,
  error,
  onRetry,
  onChanged,
  onError,
}: {
  outletId: string;
  stockItems: StockItem[];
  counts: StockCount[];
  loading: boolean;
  error: unknown;
  onRetry: () => void;
  onChanged: (message: string) => void;
  onError: (message: string) => void;
}) {
  const [reason, setReason] = useState('');
  const [itemId, setItemId] = useState('');
  const [counted, setCounted] = useState('');
  const [draft, setDraft] = useState<{ stockItemId: string; countedQuantity: string }[]>([]);
  const [busy, setBusy] = useState(false);

  const itemById = new Map(stockItems.map((item) => [item.id, item]));
  const selected = itemById.get(itemId) ?? null;
  const variance =
    selected && counted.trim() !== '' ? Number(counted) - Number(selected.quantity) : null;

  function addLine(): void {
    if (!itemId || counted.trim() === '') {
      onError('Choose an item and enter the counted quantity.');
      return;
    }
    if (draft.some((line) => line.stockItemId === itemId)) {
      onError('That stock item is already in this count.');
      return;
    }
    setDraft((current) => [...current, { stockItemId: itemId, countedQuantity: counted.trim() }]);
    setCounted('');
  }

  async function submit(): Promise<void> {
    if (reason.trim().length < 3) {
      onError('A count reason of at least three characters is required.');
      return;
    }
    if (draft.length === 0) {
      onError('Add at least one counted item.');
      return;
    }
    setBusy(true);
    try {
      await api.createStockCount(outletId, { reason: reason.trim(), lines: draft });
      setReason('');
      setDraft([]);
      onChanged('Stock count posted with variance ledger entries.');
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not post the stock count.'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <Card>
        <CardHeader>
          <CardTitle>Count stock</CardTitle>
          <CardDescription>
            Review the variance against the system quantity before posting. Only non-zero variances
            write ledger entries, each with the reason and actor.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="grid gap-4 md:grid-cols-3">
            <label className={labelClass}>
              Stock item
              <select
                className={inputClass}
                value={itemId}
                onChange={(event) => setItemId(event.target.value)}
              >
                <option value="">Choose item</option>
                {stockItems.map((item) => (
                  <option key={item.id} value={item.id}>
                    {item.name} ({item.baseUnit})
                  </option>
                ))}
              </select>
            </label>
            <label className={labelClass}>
              Counted quantity
              <input
                className={inputClass}
                inputMode="decimal"
                value={counted}
                onChange={(event) => setCounted(event.target.value)}
              />
            </label>
            <div className="flex items-end">
              <Button type="button" variant="outline" className="w-full" onClick={addLine}>
                <ClipboardCheck aria-hidden="true" className="size-4" />
                Add count line
              </Button>
            </div>
          </div>
          <div className="rounded-control border border-border bg-surface-tint p-3 text-sm">
            <p className="text-muted">System quantity</p>
            <p className="font-medium text-text">
              {selected ? `${selected.quantity} ${selected.baseUnit}` : 'Choose an item'}
            </p>
            <p className="mt-2 text-muted">Variance preview</p>
            <p
              className={
                variance && variance !== 0 ? 'font-medium text-warning' : 'font-medium text-success'
              }
            >
              {variance === null ? '—' : `${variance > 0 ? '+' : ''}${variance.toFixed(6)}`}
            </p>
          </div>
          {draft.length > 0 ? (
            <ul className="flex flex-col divide-y divide-border rounded-control border border-border">
              {draft.map((line) => {
                const item = itemById.get(line.stockItemId);
                return (
                  <li
                    key={line.stockItemId}
                    className="flex items-center justify-between gap-3 px-3 py-2 text-sm"
                  >
                    <span>
                      {item?.name ?? shortId(line.stockItemId)}: {line.countedQuantity}{' '}
                      {item?.baseUnit ?? ''}
                    </span>
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() =>
                        setDraft((current) =>
                          current.filter((row) => row.stockItemId !== line.stockItemId),
                        )
                      }
                    >
                      Remove
                    </Button>
                  </li>
                );
              })}
            </ul>
          ) : null}
          <label className={labelClass}>
            Count reason
            <input
              className={inputClass}
              value={reason}
              maxLength={500}
              onChange={(event) => setReason(event.target.value)}
              placeholder="Weekly count"
            />
          </label>
          <Button type="button" disabled={busy} onClick={() => void submit()}>
            {busy ? 'Posting' : 'Post stock count'}
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Stock count history</CardTitle>
          <CardDescription>Variance lines and the resulting ledger movements.</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {loading ? <LoadingCard label="Loading stock counts" /> : null}
          {error ? <ErrorCard error={error} onRetry={onRetry} /> : null}
          {!loading && !error && counts.length === 0 ? (
            <EmptyState
              title="No stock counts"
              detail="Post a count to compare counted and system quantities."
            />
          ) : null}
          {counts.map((count) => (
            <div
              key={count.id}
              className="rounded-control border border-border bg-surface-tint p-4"
            >
              <div className="flex flex-wrap items-center justify-between gap-2">
                <div>
                  <p className="font-medium text-text">{count.reference}</p>
                  <p className="text-sm text-muted">
                    {count.reason} · {formatTimestamp(count.createdAt)}
                  </p>
                </div>
                <Badge tone={count.movements.length > 0 ? 'warning' : 'success'}>
                  {count.movements.length} ledger line{count.movements.length === 1 ? '' : 's'}
                </Badge>
              </div>
              <ul className="mt-3 flex flex-col divide-y divide-border">
                {count.lines.map((line) => (
                  <li
                    key={line.stockItemId}
                    className="flex flex-wrap items-center justify-between gap-2 py-2 text-sm"
                  >
                    <span>{line.stockItemName}</span>
                    <span className={Number(line.variance) === 0 ? 'text-muted' : 'text-warning'}>
                      counted {line.countedQuantity} · system {line.systemQuantity} · variance{' '}
                      {line.variance} {line.baseUnit}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}

function WasteSection({
  outletId,
  stockItems,
  wastes,
  loading,
  error,
  onRetry,
  onChanged,
  onError,
}: {
  outletId: string;
  stockItems: StockItem[];
  wastes: Waste[];
  loading: boolean;
  error: unknown;
  onRetry: () => void;
  onChanged: (message: string) => void;
  onError: (message: string) => void;
}) {
  const [stockItemId, setStockItemId] = useState('');
  const [quantity, setQuantity] = useState('');
  const [reason, setReason] = useState<ApiSchemas['WasteWrite']['reason']>('EXPIRY');
  const [note, setNote] = useState('');
  const [busy, setBusy] = useState(false);

  async function submit(): Promise<void> {
    if (!stockItemId || quantity.trim() === '') {
      onError('Choose a stock item and enter a quantity.');
      return;
    }
    setBusy(true);
    try {
      await api.recordWaste(outletId, {
        stockItemId,
        quantity: quantity.trim(),
        reason,
        note: note.trim() || undefined,
      });
      setQuantity('');
      setNote('');
      onChanged('Waste recorded with a ledger entry.');
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not record the waste.'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,2fr)]">
      <Card>
        <CardHeader>
          <CardTitle>Record waste or loss</CardTitle>
          <CardDescription>
            A reason is mandatory. The ledger stores the actor and reason.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form
            className="flex flex-col gap-3"
            onSubmit={(event) => {
              event.preventDefault();
              void submit();
            }}
          >
            <label className={labelClass}>
              Stock item
              <select
                className={inputClass}
                value={stockItemId}
                onChange={(event) => setStockItemId(event.target.value)}
                required
              >
                <option value="">Choose item</option>
                {stockItems.map((item) => (
                  <option key={item.id} value={item.id}>
                    {item.name} ({item.baseUnit})
                  </option>
                ))}
              </select>
            </label>
            <label className={labelClass}>
              Quantity
              <input
                className={inputClass}
                inputMode="decimal"
                value={quantity}
                onChange={(event) => setQuantity(event.target.value)}
                required
              />
            </label>
            <label className={labelClass}>
              Reason
              <select
                className={inputClass}
                value={reason}
                onChange={(event) =>
                  setReason(event.target.value as ApiSchemas['WasteWrite']['reason'])
                }
              >
                {WASTE_REASONS.map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </label>
            <label className={labelClass}>
              Note
              <input
                className={inputClass}
                value={note}
                maxLength={500}
                onChange={(event) => setNote(event.target.value)}
                placeholder="Optional detail"
              />
            </label>
            <Button type="submit" disabled={busy}>
              <Trash2 aria-hidden="true" className="size-4" />
              {busy ? 'Saving' : 'Record waste'}
            </Button>
          </form>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardTitle>Waste history</CardTitle>
          <CardDescription>Every recorded loss has a reason, note and actor.</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {loading ? <LoadingCard label="Loading waste" /> : null}
          {error ? <ErrorCard error={error} onRetry={onRetry} /> : null}
          {!loading && !error && wastes.length === 0 ? (
            <EmptyState
              title="No waste recorded"
              detail="Damage, expiry, theft and spoilage appear here."
            />
          ) : null}
          <ul className="flex flex-col divide-y divide-border">
            {wastes.map((waste) => (
              <li
                key={waste.id}
                className="flex flex-wrap items-center justify-between gap-2 py-3 first:pt-0 last:pb-0"
              >
                <div>
                  <p className="font-medium text-text">{waste.stockItemName}</p>
                  <p className="text-sm text-muted">
                    {waste.reason} · {waste.note ?? 'No note'} · {formatTimestamp(waste.createdAt)}
                  </p>
                </div>
                <Badge tone="danger">-{waste.quantity}</Badge>
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}

function TransferSection({
  outletId,
  outletIds,
  stockItems,
  transfers,
  loading,
  error,
  onRetry,
  onChanged,
  onError,
}: {
  outletId: string;
  outletIds: string[];
  stockItems: StockItem[];
  transfers: Transfer[];
  loading: boolean;
  error: unknown;
  onRetry: () => void;
  onChanged: (message: string) => void;
  onError: (message: string) => void;
}) {
  const [destinationOutletId, setDestinationOutletId] = useState('');
  const [stockItemId, setStockItemId] = useState('');
  const [quantity, setQuantity] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);
  const [receiveDraft, setReceiveDraft] = useState<Record<string, TransferLineDraft>>({});

  const destinations = outletIds.filter((id) => id !== outletId);

  async function create(): Promise<void> {
    if (!destinationOutletId || !stockItemId || quantity.trim() === '') {
      onError('Choose a destination outlet, stock item and quantity.');
      return;
    }
    setBusyId('create');
    try {
      await api.createTransfer(outletId, {
        destinationOutletId,
        lines: [{ stockItemId, quantity: quantity.trim() }],
      });
      setQuantity('');
      onChanged('Draft transfer created. Dispatch it when stock leaves this outlet.');
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not create the transfer.'));
    } finally {
      setBusyId(null);
    }
  }

  async function dispatch(transfer: Transfer): Promise<void> {
    setBusyId(transfer.id);
    try {
      await api.dispatchTransfer(outletId, transfer.id);
      onChanged(`Transfer ${transfer.reference} dispatched. Stock is now in transit.`);
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not dispatch the transfer.'));
    } finally {
      setBusyId(null);
    }
  }

  async function receive(transfer: Transfer): Promise<void> {
    const lines = transfer.lines
      .filter((line) => Number(line.inTransitQuantity) > 0)
      .map((line) => ({
        lineId: line.id,
        quantity: (receiveDraft[line.id]?.quantity ?? line.inTransitQuantity).trim(),
      }));
    if (lines.length === 0) {
      onError('There is no in-transit quantity to receive.');
      return;
    }
    setBusyId(transfer.id);
    try {
      await api.receiveTransfer(outletId, transfer.id, { lines });
      onChanged(`Transfer ${transfer.reference} received at this outlet.`);
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not receive the transfer.'));
    } finally {
      setBusyId(null);
    }
  }

  async function cancel(transfer: Transfer): Promise<void> {
    setBusyId(transfer.id);
    try {
      await api.cancelTransfer(outletId, transfer.id);
      onChanged(`Transfer ${transfer.reference} cancelled. Source stock was restored.`);
    } catch (submitError) {
      onError(describePurchasingError(submitError, 'Could not cancel the transfer.'));
    } finally {
      setBusyId(null);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <Card>
        <CardHeader>
          <CardTitle>New outlet transfer</CardTitle>
          <CardDescription>
            Dispatch removes stock from this outlet. Receive adds it only at the destination. The
            difference stays visible as in-transit and is excluded from both balances.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form
            className="grid gap-4 md:grid-cols-2 xl:grid-cols-4"
            onSubmit={(event) => {
              event.preventDefault();
              void create();
            }}
          >
            <label className={labelClass}>
              Destination outlet
              <select
                className={inputClass}
                value={destinationOutletId}
                onChange={(event) => setDestinationOutletId(event.target.value)}
                required
              >
                <option value="">Choose outlet</option>
                {destinations.map((id) => (
                  <option key={id} value={id}>
                    Outlet {shortId(id)}
                  </option>
                ))}
              </select>
            </label>
            <label className={labelClass}>
              Stock item
              <select
                className={inputClass}
                value={stockItemId}
                onChange={(event) => setStockItemId(event.target.value)}
                required
              >
                <option value="">Choose item</option>
                {stockItems.map((item) => (
                  <option key={item.id} value={item.id}>
                    {item.name} ({item.baseUnit})
                  </option>
                ))}
              </select>
            </label>
            <label className={labelClass}>
              Base quantity
              <input
                className={inputClass}
                inputMode="decimal"
                value={quantity}
                onChange={(event) => setQuantity(event.target.value)}
                required
              />
            </label>
            <div className="flex items-end">
              <Button type="submit" className="w-full" disabled={busyId === 'create'}>
                <ArrowRightLeft aria-hidden="true" className="size-4" />
                {busyId === 'create' ? 'Creating' : 'Create transfer'}
              </Button>
            </div>
          </form>
          {destinations.length === 0 ? (
            <p className="mt-3 text-sm text-warning">
              This account can see only one outlet. Transfers need two outlets in the same business.
            </p>
          ) : null}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Transfers</CardTitle>
          <CardDescription>Dispatch, receive or cancel unreceived transfers.</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {loading ? <LoadingCard label="Loading transfers" /> : null}
          {error ? <ErrorCard error={error} onRetry={onRetry} /> : null}
          {!loading && !error && transfers.length === 0 ? (
            <EmptyState
              title="No transfers"
              detail="Create a draft transfer to move stock between outlets."
            />
          ) : null}
          {transfers.map((transfer) => {
            const isSource = transfer.sourceOutletId === outletId;
            const isDestination = transfer.destinationOutletId === outletId;
            return (
              <div
                key={transfer.id}
                className="rounded-control border border-border bg-surface-tint p-4"
              >
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <div>
                    <p className="font-medium text-text">{transfer.reference}</p>
                    <p className="text-sm text-muted">
                      {transfer.sourceOutletName} → {transfer.destinationOutletName} · in transit{' '}
                      {transfer.inTransitQuantity}
                    </p>
                  </div>
                  <Badge tone={stateTone(transfer.state)}>{transfer.state}</Badge>
                </div>
                <div className="mt-3 flex flex-col gap-2">
                  {transfer.lines.map((line) => (
                    <div
                      key={line.id}
                      className="flex flex-wrap items-center justify-between gap-2 rounded-control border border-border bg-surface px-3 py-2 text-sm"
                    >
                      <span>{line.stockItemName}</span>
                      <span className="text-muted">
                        dispatched {line.dispatchedQuantity} · received {line.receivedQuantity} · in
                        transit {line.inTransitQuantity} {line.baseUnit}
                      </span>
                      {isDestination &&
                      transfer.state === 'DISPATCHED' &&
                      Number(line.inTransitQuantity) > 0 ? (
                        <label className="flex items-center gap-2 text-xs text-muted">
                          Receive
                          <input
                            className="h-9 w-28 rounded-control border border-control bg-surface px-2 text-sm text-text"
                            inputMode="decimal"
                            value={receiveDraft[line.id]?.quantity ?? line.inTransitQuantity}
                            onChange={(event) =>
                              setReceiveDraft((current) => ({
                                ...current,
                                [line.id]: { quantity: event.target.value },
                              }))
                            }
                          />
                        </label>
                      ) : null}
                    </div>
                  ))}
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  {isSource && transfer.state === 'DRAFT' ? (
                    <Button
                      type="button"
                      size="sm"
                      disabled={busyId === transfer.id}
                      onClick={() => void dispatch(transfer)}
                    >
                      <Truck aria-hidden="true" className="size-4" />
                      Dispatch
                    </Button>
                  ) : null}
                  {isDestination && transfer.state === 'DISPATCHED' ? (
                    <Button
                      type="button"
                      size="sm"
                      disabled={busyId === transfer.id}
                      onClick={() => void receive(transfer)}
                    >
                      <PackageCheck aria-hidden="true" className="size-4" />
                      Receive
                    </Button>
                  ) : null}
                  {isSource && (transfer.state === 'DRAFT' || transfer.state === 'DISPATCHED') ? (
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      disabled={busyId === transfer.id}
                      onClick={() => void cancel(transfer)}
                    >
                      Cancel
                    </Button>
                  ) : null}
                </div>
              </div>
            );
          })}
        </CardContent>
      </Card>
    </div>
  );
}

function LedgerSection({
  outletId,
  stockItems,
  suppliers,
  loading,
  onError,
}: {
  outletId: string;
  stockItems: StockItem[];
  suppliers: Supplier[];
  loading: boolean;
  onError: (message: string) => void;
}) {
  const [stockItemId, setStockItemId] = useState('');
  const [type, setType] = useState<'' | Movement['type']>('');
  const [reason, setReason] = useState('');
  const [supplierId, setSupplierId] = useState('');

  const movementTypes: Movement['type'][] = [
    'OPENING',
    'RECEIPT',
    'ADJUSTMENT',
    'COUNT',
    'WASTE',
    'TRANSFER_OUT',
    'TRANSFER_IN',
    'TRANSFER_CANCEL',
    'SALE',
    'REVERSAL',
  ];

  const movementsQuery = useQuery({
    queryKey: ['stock-movements', outletId, stockItemId, type, reason, supplierId],
    queryFn: () =>
      api.listStockMovements(outletId, stockItemId, {
        limit: 100,
        type: type || undefined,
        reason: reason.trim() || undefined,
        supplierId: supplierId || undefined,
      }),
    enabled: Boolean(outletId && stockItemId),
    retry: 1,
  });

  const movements = movementsQuery.data?.items ?? [];

  return (
    <Card>
      <CardHeader>
        <CardTitle>Movement ledger</CardTitle>
        <CardDescription>
          Filter by movement type, reason text or supplier. Supplier references and purchase order
          references are shown on purchase receipts.
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-4">
        {loading ? <LoadingCard label="Loading stock items" /> : null}
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <label className={labelClass}>
            Stock item
            <select
              className={inputClass}
              value={stockItemId}
              onChange={(event) => setStockItemId(event.target.value)}
            >
              <option value="">Choose item</option>
              {stockItems.map((item) => (
                <option key={item.id} value={item.id}>
                  {item.name} ({item.baseUnit})
                </option>
              ))}
            </select>
          </label>
          <label className={labelClass}>
            Type
            <select
              className={inputClass}
              value={type}
              onChange={(event) => setType(event.target.value as '' | Movement['type'])}
            >
              <option value="">All types</option>
              {movementTypes.map((value) => (
                <option key={value} value={value}>
                  {value}
                </option>
              ))}
            </select>
          </label>
          <label className={labelClass}>
            Reason contains
            <input
              className={inputClass}
              value={reason}
              maxLength={100}
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
          <label className={labelClass}>
            Supplier
            <select
              className={inputClass}
              value={supplierId}
              onChange={(event) => setSupplierId(event.target.value)}
            >
              <option value="">All suppliers</option>
              {suppliers.map((supplier) => (
                <option key={supplier.id} value={supplier.id}>
                  {supplier.name}
                </option>
              ))}
            </select>
          </label>
        </div>
        {!stockItemId ? (
          <EmptyState
            title="Choose a stock item"
            detail="The ledger is scoped to one stock item at a time."
          />
        ) : null}
        {movementsQuery.isPending && stockItemId ? <LoadingCard label="Loading movements" /> : null}
        {movementsQuery.isError ? (
          <ErrorCard
            error={movementsQuery.error}
            onRetry={() => {
              onError('Retrying the movement ledger.');
              void movementsQuery.refetch();
            }}
          />
        ) : null}
        {stockItemId &&
        !movementsQuery.isPending &&
        !movementsQuery.isError &&
        movements.length === 0 ? (
          <EmptyState
            title="No movements match"
            detail="Clear a filter or choose another stock item."
          />
        ) : null}
        {movements.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full min-w-[40rem] border-collapse text-sm">
              <thead>
                <tr className="border-b border-border text-left text-xs uppercase tracking-wide text-muted">
                  <th className="py-2 pr-3">Time</th>
                  <th className="py-2 pr-3">Type</th>
                  <th className="py-2 pr-3">Delta</th>
                  <th className="py-2 pr-3">Reason</th>
                  <th className="py-2 pr-3">Supplier / PO</th>
                  <th className="py-2">Actor</th>
                </tr>
              </thead>
              <tbody>
                {movements.map((movement) => (
                  <tr key={movement.id} className="border-b border-border last:border-0">
                    <td className="py-2 pr-3 text-muted">{formatTimestamp(movement.createdAt)}</td>
                    <td className="py-2 pr-3">
                      <Badge tone={stateTone(movement.type)}>{movement.type}</Badge>
                    </td>
                    <td className="py-2 pr-3 font-medium tabular-nums">{movement.delta}</td>
                    <td className="py-2 pr-3">{movement.reason}</td>
                    <td className="py-2 pr-3 text-muted">
                      {movement.supplierReference ?? movement.supplierName ?? '—'}
                      {movement.purchaseOrderReference
                        ? ` · ${movement.purchaseOrderReference}`
                        : ''}
                    </td>
                    <td className="py-2 font-mono text-xs text-muted">
                      {shortId(movement.actorId)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}
      </CardContent>
    </Card>
  );
}
