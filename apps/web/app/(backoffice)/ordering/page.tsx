import type { Metadata } from 'next';
import { OrderingScreen } from '@/components/ordering-screen';

export const metadata: Metadata = { title: 'Online ordering' };

export default function OrderingPage() {
  return <OrderingScreen />;
}
