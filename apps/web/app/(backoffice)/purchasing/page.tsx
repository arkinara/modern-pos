import type { Metadata } from 'next';
import { PurchasingScreen } from '@/components/purchasing-screen';

export const metadata: Metadata = { title: 'Purchasing' };

export default function PurchasingPage() {
  return <PurchasingScreen />;
}
