import type { Metadata } from 'next';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export const metadata: Metadata = { title: 'Sales' };

export default function SalesPage() {
  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Sales</h1>
        <p className="mt-2 max-w-2xl text-sm text-muted">
          Read-only inspection of sale records created by the Android app. The web back office
          cannot create, edit or complete a sale.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Recorded sales</CardTitle>
          <CardDescription>
            List and detail depth arrive with the sales-history ticket. This scaffold reads
            mobile-originated records only.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto rounded-surface border border-border">
            <table className="w-full table-auto text-left text-sm">
              <thead className="bg-surface-tint text-xs uppercase tracking-[0.12em] text-muted">
                <tr>
                  <th scope="col" className="px-4 py-3 font-medium">
                    Recorded
                  </th>
                  <th scope="col" className="px-4 py-3 font-medium">
                    Receipt
                  </th>
                  <th scope="col" className="px-4 py-3 font-medium">
                    Total
                  </th>
                  <th scope="col" className="px-4 py-3 font-medium">
                    Source
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td colSpan={4} className="px-4 py-10 text-center text-sm text-muted">
                    No mobile-originated sales yet. Completed records appear here after the Android
                    app syncs them.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
