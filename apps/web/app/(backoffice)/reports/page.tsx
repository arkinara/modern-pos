import type { Metadata } from 'next';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export const metadata: Metadata = { title: 'Reports' };

export default function ReportsPage() {
  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Reports</h1>
        <p className="mt-2 max-w-2xl text-sm text-muted">
          Read-only daily reconciliation from mobile-recorded sales. Report depth and export are
          delivered with the reporting ticket.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>No recorded sales yet</CardTitle>
          <CardDescription>
            Sales recorded in the Android app appear here after refresh. An empty period stays
            empty; this page does not offer a web sale action.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="rounded-surface border border-dashed border-control bg-surface-tint p-8 text-center text-sm text-muted">
            Reporting queries, payment breakdowns and CSV export remain deferred to ticket #14.
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
