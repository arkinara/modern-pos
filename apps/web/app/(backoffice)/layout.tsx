import { ApiStatus } from '@/components/api-status';
import { AuthGate } from '@/components/auth-gate';
import { SidebarNav } from '@/components/sidebar-nav';
import { UserMenu } from '@/components/user-menu';

export default function BackOfficeLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <AuthGate>
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
          <div className="mt-auto flex flex-col gap-4">
            <div className="hidden md:block">
              <ApiStatus />
            </div>
            <UserMenu />
          </div>
        </aside>
        <main className="min-w-0 flex-1 px-4 py-6 sm:px-8 lg:px-10">{children}</main>
      </div>
    </AuthGate>
  );
}
