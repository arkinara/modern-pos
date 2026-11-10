import type { Metadata } from 'next';
import { SalesScreen } from '@/components/sales-screen';

export const metadata: Metadata = { title: 'Sales' };

export default function SalesPage() {
  return <SalesScreen />;
}
