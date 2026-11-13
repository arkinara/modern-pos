import { createHash, randomBytes, randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { ReceiptCreateDto } from './dto/receipt.dto';

const DEFAULT_RECEIPT_DAYS = 90;
const DEFAULT_LINK_TTL_MINUTES = 1440;

export interface ReceiptResponse {
  id: string;
  receiptNumber: string;
  saleId: string | null;
  channelOrderId: string | null;
  customerId: string | null;
  token: string;
  url: string;
  issuedAt: string;
  expiresAt: string;
  html: string;
  text: string;
}

export interface PublicReceiptResponse {
  receiptNumber: string;
  issuedAt: string;
  expiresAt: string;
  html: string;
  text: string;
}

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function formatMinor(value: bigint, exponent: number): string {
  const negative = value < 0n;
  const absolute = negative ? -value : value;
  const divisor = 10n ** BigInt(exponent);
  const whole = absolute / divisor;
  const fraction = absolute % divisor;
  const body =
    exponent === 0
      ? whole.toString()
      : `${whole.toString()}.${fraction.toString().padStart(exponent, '0')}`;
  return negative ? `-${body}` : body;
}

@Injectable()
export class ReceiptsService {
  constructor(private readonly prisma: PrismaService) {}

  async createForSale(
    outletId: string,
    saleId: string,
    dto: ReceiptCreateDto,
    user: AuthenticatedUser,
  ): Promise<ReceiptResponse> {
    const sale = await this.prisma.sale.findFirst({
      where: { id: saleId, outletId, businessId: user.businessId },
      include: {
        lines: { orderBy: { id: 'asc' } },
        payment: true,
        outlet: true,
      },
    });

    if (!sale) {
      throw apiError(404, 'NOT_FOUND', 'Sale not found');
    }

    if (dto.customerId) {
      const customer = await this.prisma.customer.findFirst({
        where: { id: dto.customerId, outletId, businessId: user.businessId },
        select: { id: true, anonymizedAt: true },
      });
      if (!customer) {
        throw apiError(404, 'NOT_FOUND', 'Customer not found');
      }
      if (customer.anonymizedAt !== null) {
        throw apiError(
          422,
          'CUSTOMER_RETENTION_EXPIRED',
          'The customer record has been anonymised and cannot receive a new receipt',
        );
      }
    }

    const policy = await this.prisma.customerRetentionPolicy.findUnique({ where: { outletId } });
    const ttl = dto.expiresInMinutes ?? policy?.receiptLinkTtlMinutes ?? DEFAULT_LINK_TTL_MINUTES;
    const retentionDays = policy?.receiptRetentionDays ?? DEFAULT_RECEIPT_DAYS;
    const now = new Date();
    const expiresAt = new Date(now.getTime() + ttl * 60 * 1000);
    const token = randomBytes(32).toString('hex');
    const content = this.render(sale, token, now, expiresAt);
    const receiptNumber = `RCPT-${sale.id.slice(0, 8).toUpperCase()}-${randomUUID()
      .slice(0, 6)
      .toUpperCase()}`;

    const created = await this.prisma.digitalReceipt.create({
      data: {
        businessId: user.businessId,
        outletId,
        saleId: sale.id,
        channelOrderId: null,
        customerId: dto.customerId ?? null,
        receiptNumber,
        tokenHash: hashToken(token),
        contentHtml: content.html,
        contentText: content.text,
        issuedAt: now,
        expiresAt,
        // Keep the record until the configured retention purge removes it.
        purgedAt: null,
      },
    });

    void retentionDays;

    return {
      id: created.id,
      receiptNumber: created.receiptNumber,
      saleId: created.saleId,
      channelOrderId: created.channelOrderId,
      customerId: created.customerId,
      token,
      url: `/v1/receipts/${token}`,
      issuedAt: created.issuedAt.toISOString(),
      expiresAt: created.expiresAt.toISOString(),
      html: created.contentHtml,
      text: created.contentText,
    };
  }

  async getPublic(token: string): Promise<PublicReceiptResponse> {
    const receipt = await this.prisma.digitalReceipt.findFirst({
      where: {
        tokenHash: hashToken(token),
        purgedAt: null,
        expiresAt: { gt: new Date() },
      },
    });

    if (!receipt) {
      throw apiError(404, 'NOT_FOUND', 'Receipt not found');
    }

    return {
      receiptNumber: receipt.receiptNumber,
      issuedAt: receipt.issuedAt.toISOString(),
      expiresAt: receipt.expiresAt.toISOString(),
      html: receipt.contentHtml,
      text: receipt.contentText,
    };
  }

  async getPublicHtml(token: string): Promise<string> {
    return (await this.getPublic(token)).html;
  }

  private render(
    sale: {
      reference: string;
      currency: string;
      currencyExponent: number;
      subtotalMinor: bigint;
      discountMinor: bigint;
      serviceMinor: bigint;
      taxMinor: bigint;
      totalMinor: bigint;
      completedAt: Date;
      lines: {
        name: string;
        variantName: string;
        quantity: number;
        unitPriceMinor: bigint;
        lineSubtotalMinor: bigint;
      }[];
      payment: {
        kind: string;
        status: string;
        amountMinor: bigint;
        tenderedMinor: bigint | null;
        changeMinor: bigint | null;
      } | null;
      outlet: {
        name: string;
        receiptHeader: string;
        receiptFooter: string;
        receiptAddress: string;
      };
    },
    token: string,
    issuedAt: Date,
    expiresAt: Date,
  ): { html: string; text: string } {
    const exponent = sale.currencyExponent;
    const money = (value: bigint) => `${sale.currency} ${formatMinor(value, exponent)}`;
    const lineRows = sale.lines
      .map(
        (line) =>
          `<tr><td>${escapeHtml(line.name)} ${escapeHtml(line.variantName)}</td><td>${line.quantity}</td><td>${escapeHtml(
            money(line.unitPriceMinor),
          )}</td><td>${escapeHtml(money(line.lineSubtotalMinor))}</td></tr>`,
      )
      .join('');
    const paymentRows = sale.payment
      ? `<tr><td>Payment</td><td>${escapeHtml(sale.payment.kind)}</td><td>${escapeHtml(
          sale.payment.status,
        )}</td><td>${escapeHtml(money(sale.payment.amountMinor))}</td></tr>`
      : '';
    const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>${escapeHtml(sale.reference)}</title>
<style>body{font-family:system-ui,sans-serif;max-width:42rem;margin:2rem auto;padding:0 1rem;color:#242925}h1{font-size:1.25rem}table{width:100%;border-collapse:collapse;margin:1rem 0}th,td{text-align:left;border-bottom:1px solid #dddcd4;padding:.5rem .25rem;vertical-align:top}tfoot td{font-weight:600}p.muted{color:#64685f;font-size:.85rem}</style></head>
<body><header><h1>${escapeHtml(sale.outlet.receiptHeader || sale.outlet.name)}</h1>
<p>${escapeHtml(sale.outlet.receiptAddress)}</p><p class="muted">Sale ${escapeHtml(
      sale.reference,
    )} · ${sale.completedAt.toISOString()}</p></header>
<table><thead><tr><th>Item</th><th>Qty</th><th>Unit</th><th>Line</th></tr></thead><tbody>${lineRows}</tbody>
<tfoot><tr><td colspan="3">Subtotal</td><td>${escapeHtml(money(sale.subtotalMinor))}</td></tr>
<tr><td colspan="3">Discount</td><td>${escapeHtml(money(sale.discountMinor))}</td></tr>
<tr><td colspan="3">Service</td><td>${escapeHtml(money(sale.serviceMinor))}</td></tr>
<tr><td colspan="3">Tax</td><td>${escapeHtml(money(sale.taxMinor))}</td></tr>
<tr><td colspan="3">Total</td><td>${escapeHtml(money(sale.totalMinor))}</td></tr></tfoot></table>
<table><tbody>${paymentRows}</tbody></table>
<p>${escapeHtml(sale.outlet.receiptFooter)}</p>
<p class="muted">Digital receipt ${escapeHtml(token.slice(0, 8))}… issued ${issuedAt.toISOString()} · link expires ${expiresAt.toISOString()}</p>
</body></html>`;

    const text = [
      sale.outlet.receiptHeader || sale.outlet.name,
      sale.outlet.receiptAddress,
      `Sale ${sale.reference}`,
      '',
      ...sale.lines.map(
        (line) =>
          `${line.quantity}x ${line.name} ${line.variantName} @ ${money(
            line.unitPriceMinor,
          )} = ${money(line.lineSubtotalMinor)}`,
      ),
      '',
      `Subtotal: ${money(sale.subtotalMinor)}`,
      `Discount: ${money(sale.discountMinor)}`,
      `Service: ${money(sale.serviceMinor)}`,
      `Tax: ${money(sale.taxMinor)}`,
      `Total: ${money(sale.totalMinor)}`,
      sale.payment
        ? `Payment: ${sale.payment.kind} ${sale.payment.status} ${money(sale.payment.amountMinor)}`
        : 'Payment: none recorded',
      '',
      sale.outlet.receiptFooter,
      `Digital receipt link expires ${expiresAt.toISOString()}`,
    ].join('\n');

    return { html, text };
  }
}
