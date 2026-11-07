'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  BarChart3,
  Boxes,
  Printer,
  ReceiptText,
  Settings as SettingsIcon,
  UtensilsCrossed,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const items = [
  { href: '/menu', label: 'Menu', icon: UtensilsCrossed },
  { href: '/stock', label: 'Stock', icon: Boxes },
  { href: '/sales', label: 'Sales', icon: ReceiptText },
  { href: '/reports', label: 'Reports', icon: BarChart3 },
  { href: '/printers', label: 'Printers', icon: Printer },
  { href: '/settings', label: 'Settings', icon: SettingsIcon },
];

export function SidebarNav() {
  const pathname = usePathname();

  return (
    <nav aria-label="Back office" className="flex gap-1 overflow-x-auto md:flex-col">
      {items.map((item) => {
        const active = pathname === item.href || pathname.startsWith(`${item.href}/`);
        const Icon = item.icon;
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
    </nav>
  );
}
