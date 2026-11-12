import type { Metadata } from 'next';
import { PermissionsScreen } from '@/components/permissions-screen';

export const metadata: Metadata = { title: 'Permissions' };

export default function PermissionsPage() {
  return <PermissionsScreen />;
}
