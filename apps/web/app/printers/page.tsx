import type { Metadata } from 'next';
import { PagePlaceholder } from '@/components/page-placeholder';

export const metadata: Metadata = { title: 'Printers' };

export default function PrintersPage() {
  return (
    <PagePlaceholder
      title="Printers"
      description="Printer metadata and print-job status are listed here. Device discovery and physical printing remain on Android."
      emptyTitle="No printers registered"
      emptyBody="Printer registration and job history arrive with the hardware and printing tickets."
    />
  );
}
