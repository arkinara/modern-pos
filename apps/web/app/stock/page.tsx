import type { Metadata } from 'next';
import { PagePlaceholder } from '@/components/page-placeholder';

export const metadata: Metadata = { title: 'Stock' };

export default function StockPage() {
  return (
    <PagePlaceholder
      title="Stock"
      description="Review stock balances and the append-only movement ledger. Ledger behavior is delivered in ticket #7."
      emptyTitle="Stock ledger not loaded"
      emptyBody="Balances, receipts and adjustments will read from the server-owned stock ledger."
    />
  );
}
