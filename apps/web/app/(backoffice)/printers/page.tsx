import type { Metadata } from 'next';
import { PrintersScreen } from '@/components/printers-screen';

export const metadata: Metadata = { title: 'Printers' };

export default function PrintersPage() {
  return <PrintersScreen />;
}
