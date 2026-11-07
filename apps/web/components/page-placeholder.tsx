import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export function PagePlaceholder({
  title,
  description,
  emptyTitle,
  emptyBody,
}: {
  title: string;
  description: string;
  emptyTitle: string;
  emptyBody: string;
}) {
  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">{title}</h1>
        <p className="mt-2 max-w-2xl text-sm text-muted">{description}</p>
      </header>
      <Card>
        <CardHeader>
          <CardTitle>{emptyTitle}</CardTitle>
          <CardDescription>{emptyBody}</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="rounded-surface border border-dashed border-control bg-surface-tint p-8 text-center text-sm text-muted">
            No records yet. This screen is a scaffold placeholder for a later Phase 1 ticket.
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
