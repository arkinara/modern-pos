import type { Metadata } from 'next';
import { PromotionsScreen } from '@/components/promotions-screen';

export const metadata: Metadata = { title: 'Promotions' };

export default function PromotionsPage() {
  return <PromotionsScreen />;
}
