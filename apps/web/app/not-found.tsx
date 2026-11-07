import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export default function NotFoundPage() {
  return (
    <main className="flex min-h-screen items-center justify-center px-4 py-12">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Page not found</CardTitle>
          <CardDescription>
            This back office only exposes the owner management screens.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Button asChild>
            <Link href="/menu">Back to Menu</Link>
          </Button>
        </CardContent>
      </Card>
    </main>
  );
}
