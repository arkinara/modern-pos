import type { Metadata } from 'next';
import { ApiStatus } from '@/components/api-status';
import { SidebarNav } from '@/components/sidebar-nav';
import { Providers } from './providers';
import './globals.css';

export const metadata: Metadata = {
  title: {
    default: 'Modern POS Back Office',
    template: '%s · Modern POS',
  },
  description: 'Owner back office for the Modern POS platform.',
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <div className="flex min-h-screen flex-col md:flex-row">
            <aside className="flex shrink-0 flex-col gap-6 bg-ink px-4 py-5 md:w-[var(--pos-sidebar)]">
              <div className="flex items-center justify-between gap-3 md:block">
                <div>
                  <p className="text-xs font-medium uppercase tracking-[0.18em] text-ink-muted">
                    Modern POS
                  </p>
                  <p className="mt-1 text-base font-semibold text-surface">Back office</p>
                </div>
                <div className="md:hidden">
                  <ApiStatus />
                </div>
              </div>
              <SidebarNav />
              <div className="mt-auto hidden md:block">
                <ApiStatus />
              </div>
            </aside>
            <main className="flex-1 px-4 py-6 sm:px-8 lg:px-10">{children}</main>
          </div>
        </Providers>
      </body>
    </html>
  );
}
