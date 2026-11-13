'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { AlertTriangle, RefreshCw, Send } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { apiErrorCode, describeOperationError } from '@/lib/api-errors';
import { formatMoney } from '@/lib/reporting';
import { useActiveOutletId } from '@/lib/use-active-outlet';

type ChannelOrder = ApiSchemas['ChannelOrder'];
type Menu = ApiSchemas['Menu'];

const inputClass =
  'h-11 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';
const selectClass =
  'h-11 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

const STATE_TONES: Record<
  ChannelOrder['state'],
  'neutral' | 'accent' | 'warning' | 'success' | 'danger'
> = {
  RECEIVED: 'warning',
  ACCEPTED: 'accent',
  FULFILLED: 'success',
  CANCELLED: 'danger',
};

function stateTone(state: ChannelOrder['state']) {
  return STATE_TONES[state];
}

function money(order: ChannelOrder): string {
  return formatMoney(order.totalMinor, order.currency, order.currencyExponent);
}

export function OrderingScreen() {
  const outletId = useActiveOutletId();
  const queryClient = useQueryClient();
  const [reference, setReference] = useState('');
  const [channel, setChannel] = useState<'MANUAL' | 'PHONE'>('MANUAL');
  const [variantId, setVariantId] = useState('');
  const [quantity, setQuantity] = useState('1');
  const [cancellationReason, setCancellationReason] = useState('Customer cancelled');
  const [pending, setPending] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  const channelsQuery = useQuery({
    queryKey: ['channels', outletId],
    queryFn: () => api.listChannels(outletId as string),
    enabled: Boolean(outletId),
  });
  const ordersQuery = useQuery({
    queryKey: ['channel-orders', outletId],
    queryFn: () => api.listChannelOrders(outletId as string, { limit: 50 }),
    enabled: Boolean(outletId),
  });
  const menuQuery = useQuery({
    queryKey: ['menu-options', outletId],
    queryFn: () => api.listMenu(outletId as string, { limit: 100 }),
    enabled: Boolean(outletId),
  });

  const variants = (menuQuery.data?.items ?? []).flatMap((item: Menu) =>
    item.variants.map((variant) => ({
      id: variant.id,
      label: `${item.name} · ${variant.name}`,
      enabled: variant.enabled,
    })),
  );

  useEffect(() => {
    if (!variantId && variants.length > 0) {
      setVariantId(variants[0].id);
    }
  }, [variantId, variants]);

  function clearFeedback(): void {
    setMessage(null);
    setActionError(null);
  }

  async function refreshOrders(): Promise<void> {
    await queryClient.invalidateQueries({ queryKey: ['channel-orders', outletId] });
  }

  async function createOrder(): Promise<void> {
    if (!outletId || !reference.trim() || !variantId) {
      return;
    }
    clearFeedback();
    setPending('create');
    try {
      const result = await api.createManualChannelOrder(outletId, {
        channel,
        reference: reference.trim(),
        items: [{ variantId, quantity: Number(quantity) || 1 }],
      });
      setReference('');
      await refreshOrders();
      setMessage(
        result.duplicate
          ? 'That channel reference already existed; the existing order was returned.'
          : 'Order received. Stock is not taken until acceptance.',
      );
    } catch (error) {
      const code = apiErrorCode(error);
      setActionError(
        code === 'CHANNEL_REFERENCE_CONFLICT'
          ? 'This channel reference already exists with different items.'
          : describeOperationError(error, 'Could not create the order'),
      );
    } finally {
      setPending(null);
    }
  }

  async function acceptOrder(orderId: string): Promise<void> {
    if (!outletId) {
      return;
    }
    clearFeedback();
    setPending(`accept-${orderId}`);
    try {
      await api.acceptChannelOrder(outletId, orderId);
      await refreshOrders();
      setMessage('Order accepted. Stock is taken exactly once at this point.');
    } catch (error) {
      setActionError(describeOperationError(error, 'Could not accept the order'));
    } finally {
      setPending(null);
    }
  }

  async function cancelOrder(orderId: string): Promise<void> {
    if (!outletId || cancellationReason.trim().length < 3) {
      return;
    }
    clearFeedback();
    setPending(`cancel-${orderId}`);
    try {
      await api.cancelChannelOrder(outletId, orderId, {
        reason: cancellationReason.trim(),
      });
      await refreshOrders();
      setMessage('Order cancelled. Stock is restored only when it had been accepted.');
    } catch (error) {
      setActionError(describeOperationError(error, 'Could not cancel the order'));
    } finally {
      setPending(null);
    }
  }

  async function fulfillOrder(order: ChannelOrder): Promise<void> {
    if (!outletId) {
      return;
    }
    clearFeedback();
    setPending(`fulfill-${order.id}`);
    try {
      await api.fulfillChannelOrder(outletId, order.id, {
        collectedMinor: String(order.totalMinor),
      });
      await refreshOrders();
      setMessage('Pickup collected. One payment is recorded for this order.');
    } catch (error) {
      setActionError(describeOperationError(error, 'Could not fulfil the order'));
    } finally {
      setPending(null);
    }
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

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Online ordering</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Incoming channel orders are deduplicated by channel and reference. Stock is taken when an
          order is accepted and restored when an accepted order is cancelled. Third-party channels
          remain pending until an account is connected.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Channels</CardTitle>
          <CardDescription>
            Supported channels and their current availability on this deployment.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {channelsQuery.isLoading ? (
            <div className="flex flex-col gap-2" role="status" aria-busy="true">
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
            </div>
          ) : channelsQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(channelsQuery.error, 'Could not load channels')}
              </p>
              <Button variant="outline" onClick={() => void channelsQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : (
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {(channelsQuery.data?.items ?? []).map((channelRow) => (
                <div
                  key={channelRow.channel}
                  className="rounded-surface border border-border bg-surface-tint p-4"
                >
                  <div className="flex items-center justify-between gap-2">
                    <p className="text-sm font-semibold text-text">{channelRow.label}</p>
                    <Badge tone={channelRow.availability === 'AVAILABLE' ? 'success' : 'warning'}>
                      {channelRow.availability === 'AVAILABLE' ? 'Available' : 'Pending'}
                    </Badge>
                  </div>
                  <p className="mt-2 text-xs text-muted">
                    {channelRow.reason ??
                      (channelRow.inboundWebhook
                        ? 'Signed inbound webhook'
                        : 'Staff-entered order')}
                  </p>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Create a manual or phone order</CardTitle>
          <CardDescription>
            Reference is the dedupe key. Reusing it returns the existing order instead of creating a
            second one.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Channel
              <select
                className={selectClass}
                value={channel}
                onChange={(event) => setChannel(event.target.value as 'MANUAL' | 'PHONE')}
              >
                <option value="MANUAL">Manual</option>
                <option value="PHONE">Phone</option>
              </select>
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Channel reference
              <input
                className={inputClass}
                value={reference}
                maxLength={120}
                onChange={(event) => setReference(event.target.value)}
                placeholder="PHONE-0001"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Menu item
              <select
                className={selectClass}
                value={variantId}
                onChange={(event) => setVariantId(event.target.value)}
              >
                {variants.length === 0 ? <option value="">No saleable items</option> : null}
                {variants.map((variant) => (
                  <option key={variant.id} value={variant.id} disabled={!variant.enabled}>
                    {variant.label}
                  </option>
                ))}
              </select>
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Quantity
              <input
                className={inputClass}
                type="number"
                min={1}
                max={1000}
                value={quantity}
                onChange={(event) => setQuantity(event.target.value)}
              />
            </label>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <Button
              onClick={() => void createOrder()}
              disabled={pending === 'create' || !reference.trim() || !variantId}
            >
              <Send aria-hidden="true" className="size-4" />
              Receive order
            </Button>
            {message ? (
              <p className="text-sm text-success" role="status">
                {message}
              </p>
            ) : null}
            {actionError ? (
              <p className="flex items-center gap-2 text-sm text-danger" role="alert">
                <AlertTriangle aria-hidden="true" className="size-4" />
                {actionError}
              </p>
            ) : null}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Incoming orders</CardTitle>
          <CardDescription>
            Received → accepted → fulfilled, or cancelled. Channel references stay searchable and
            are shown on every order.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {ordersQuery.isLoading ? (
            <div className="flex flex-col gap-2" role="status" aria-busy="true">
              <div className="h-20 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-20 animate-pulse rounded-control bg-surface-muted" />
            </div>
          ) : ordersQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(ordersQuery.error, 'Could not load incoming orders')}
              </p>
              <Button variant="outline" onClick={() => void ordersQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : (ordersQuery.data?.items.length ?? 0) === 0 ? (
            <p className="rounded-surface border border-dashed border-border bg-surface-tint p-6 text-sm text-muted">
              No channel orders yet. Create a manual order above or deliver a signed web order.
            </p>
          ) : (
            <div className="flex flex-col gap-3">
              {(ordersQuery.data?.items ?? []).map((order) => (
                <div
                  key={order.id}
                  className="rounded-surface border border-border bg-surface-tint p-4"
                >
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div>
                      <div className="flex flex-wrap items-center gap-2">
                        <p className="text-sm font-semibold text-text">
                          {order.channel} · {order.channelReference}
                        </p>
                        <Badge tone={stateTone(order.state)}>{order.state}</Badge>
                        <Badge tone={order.paymentStatus === 'PAID' ? 'success' : 'neutral'}>
                          {order.paymentStatus}
                        </Badge>
                      </div>
                      <p className="mt-1 text-xs text-muted">
                        {order.lines
                          .map((line) => `${line.quantity}× ${line.name} ${line.variantName}`)
                          .join(', ')}{' '}
                        · {money(order)}
                      </p>
                    </div>
                    <div className="flex flex-wrap items-center gap-2">
                      {order.state === 'RECEIVED' ? (
                        <Button
                          size="sm"
                          onClick={() => void acceptOrder(order.id)}
                          disabled={pending === `accept-${order.id}`}
                        >
                          Accept
                        </Button>
                      ) : null}
                      {order.state === 'ACCEPTED' ? (
                        <Button
                          size="sm"
                          onClick={() => void fulfillOrder(order)}
                          disabled={pending === `fulfill-${order.id}`}
                        >
                          Collect and fulfil
                        </Button>
                      ) : null}
                      {order.state === 'RECEIVED' || order.state === 'ACCEPTED' ? (
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => void cancelOrder(order.id)}
                          disabled={pending === `cancel-${order.id}`}
                        >
                          Cancel
                        </Button>
                      ) : null}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
          <div className="mt-4 flex flex-col gap-1">
            <label className="text-sm font-medium text-text" htmlFor="cancellation-reason">
              Cancellation reason
            </label>
            <input
              id="cancellation-reason"
              className={inputClass}
              value={cancellationReason}
              maxLength={500}
              onChange={(event) => setCancellationReason(event.target.value)}
            />
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
