export type ProviderPaymentStatus = 'PENDING' | 'SUCCEEDED' | 'FAILED';

export interface ProviderPayment {
  providerRef: string;
  status: ProviderPaymentStatus;
  amountMinor: bigint;
  currency: string;
  qrPayload?: string | null;
  refundedMinor?: bigint;
}

export interface CreateProviderPaymentInput {
  idempotencyKey: string;
  amountMinor: bigint;
  currency: string;
}

export interface RefundProviderPaymentInput {
  providerRef: string;
  idempotencyKey: string;
  amountMinor: bigint;
}

export interface ProviderRefund {
  providerRef: string;
  refundedMinor: bigint;
  status: ProviderPaymentStatus;
}

export interface PaymentProviderAdapter {
  readonly name: 'MOCK' | 'QRIS';
  createPayment(input: CreateProviderPaymentInput): Promise<ProviderPayment>;
  fetchPayment(providerRef: string): Promise<ProviderPayment>;
  refundPayment(input: RefundProviderPaymentInput): Promise<ProviderRefund>;
}
