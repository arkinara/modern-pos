import type { Metadata } from 'next';
import { PagePlaceholder } from '@/components/page-placeholder';

export const metadata: Metadata = { title: 'Reports' };

export default function ReportsPage() {
  return (
    <PagePlaceholder
      title="Reports"
      description="Daily sales reconciliation and CSV export will read from server-owned sale records."
      emptyTitle="No reporting period selected"
      emptyBody="Report queries and export wiring land with the reporting tickets in Phase 1."
    />
  );
}
