import type { Metadata } from 'next';
import { ShiftsScreen } from '@/components/shifts-screen';

export const metadata: Metadata = { title: 'Shifts' };

export default function ShiftsPage() {
  return <ShiftsScreen />;
}
