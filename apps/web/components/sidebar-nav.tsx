'use client';

import type { LucideIcon } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  BarChart3,
  BookOpen,
  Boxes,
  CalendarDays,
  Clock,
  Megaphone,
  Package,
  Printer,
  ReceiptText,
  ScrollText,
  Settings as SettingsIcon,
  ShieldCheck,
  ShoppingCart,
  Users,
  UtensilsCrossed,
} from 'lucide-react';
import { navigationGroupsForRole } from '@/lib/back-office-nav';
import { useAuth } from '@/lib/auth';
import { cn } from '@/lib/utils';

const ICONS: Record<string, LucideIcon> = {
  '/menu': UtensilsCrossed,
  '/stock': Boxes,
  '/sales': ReceiptText,
  '/promotions': Megaphone,
  '/ordering': ShoppingCart,
  '/shifts': Clock,
  '/attendance': CalendarDays,
  '/purchasing': Package,
  '/printers': Printer,
  '/reports': BarChart3,
  '/bookkeeping': BookOpen,
  '/customers': Users,
  '/audit': ScrollText,
  '/permissions': ShieldCheck,
  '/settings': SettingsIcon,
};

export function SidebarNav() {
  const pathname = usePathname();
  const { user } = useAuth();
  const groups = navigationGroupsForRole(user?.role);

  return (
    <nav aria-label="Back office" className="flex flex-col gap-4 overflow-x-auto pb-1">
      {groups.map((group) => (
        <div key={group.label} className="flex flex-col gap-1">
          <p className="px-3 text-[0.68rem] font-medium uppercase tracking-[0.16em] text-ink-muted">
            {group.label}
          </p>
          <div className="flex min-w-max gap-1 md:min-w-0 md:flex-col">
            {group.items.map((item) => {
              const active = pathname === item.href || pathname.startsWith(`${item.href}/`);
              const Icon = ICONS[item.href] ?? Boxes;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  aria-current={active ? 'page' : undefined}
                  className={cn(
                    'flex min-h-12 shrink-0 items-center gap-3 rounded-control px-3 py-2 text-sm font-medium transition-colors',
                    active
                      ? 'bg-nav-selected text-nav-selected-text'
                      : 'text-nav-text hover:bg-ink-muted/10 hover:text-surface',
                  )}
                >
                  <Icon aria-hidden="true" className="size-5 shrink-0" strokeWidth={1.75} />
                  <span>{item.label}</span>
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </nav>
  );
}
