import type { Metadata } from 'next';
import { PagePlaceholder } from '@/components/page-placeholder';

export const metadata: Metadata = { title: 'Menu' };

export default function MenuPage() {
  return (
    <PagePlaceholder
      title="Menu"
      description="Manage categories, products, variants and prices for this outlet. Catalog behavior is delivered in ticket #6."
      emptyTitle="Catalog not loaded"
      emptyBody="The API contract is available now; catalog persistence and editing arrive with the catalog ticket."
    />
  );
}
