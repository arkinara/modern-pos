import type { Metadata } from 'next';
import { AuditScreen } from '@/components/audit-screen';

export const metadata: Metadata = { title: 'Audit search' };

export default function AuditPage() {
  return <AuditScreen />;
}
