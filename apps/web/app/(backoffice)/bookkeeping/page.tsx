import type { Metadata } from 'next';
import { BookkeepingScreen } from '@/components/bookkeeping-screen';

export const metadata: Metadata = { title: 'Bookkeeping' };

export default function BookkeepingPage() {
  return <BookkeepingScreen />;
}
