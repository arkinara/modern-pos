export type BackOfficeRole = 'OWNER' | 'CASHIER';

export interface BackOfficeNavItem {
  href: string;
  label: string;
  roles: readonly BackOfficeRole[];
}

export interface BackOfficeNavGroup {
  label: string;
  items: readonly BackOfficeNavItem[];
}

const OWNER_AND_CASHIER: readonly BackOfficeRole[] = ['OWNER', 'CASHIER'];
const OWNER_ONLY: readonly BackOfficeRole[] = ['OWNER'];

export const BACK_OFFICE_NAV_GROUPS: readonly BackOfficeNavGroup[] = [
  {
    label: 'Selling',
    items: [
      { href: '/menu', label: 'Menu', roles: OWNER_AND_CASHIER },
      { href: '/stock', label: 'Stock', roles: OWNER_AND_CASHIER },
      { href: '/sales', label: 'Sales', roles: OWNER_AND_CASHIER },
      { href: '/promotions', label: 'Promotions', roles: OWNER_AND_CASHIER },
      { href: '/ordering', label: 'Online ordering', roles: OWNER_AND_CASHIER },
    ],
  },
  {
    label: 'Operations',
    items: [
      { href: '/shifts', label: 'Shifts', roles: OWNER_AND_CASHIER },
      { href: '/attendance', label: 'Attendance', roles: OWNER_AND_CASHIER },
      { href: '/purchasing', label: 'Purchasing', roles: OWNER_ONLY },
      { href: '/printers', label: 'Printers', roles: OWNER_ONLY },
    ],
  },
  {
    label: 'Insights',
    items: [
      { href: '/reports', label: 'Reports', roles: OWNER_ONLY },
      { href: '/bookkeeping', label: 'Bookkeeping', roles: OWNER_ONLY },
      { href: '/customers', label: 'Customers', roles: OWNER_ONLY },
    ],
  },
  {
    label: 'Administration',
    items: [
      { href: '/audit', label: 'Audit search', roles: OWNER_ONLY },
      { href: '/permissions', label: 'Permissions', roles: OWNER_ONLY },
      { href: '/settings', label: 'Settings', roles: OWNER_ONLY },
    ],
  },
];

export function navigationGroupsForRole(role: string | null | undefined): BackOfficeNavGroup[] {
  const normalized: BackOfficeRole | null = role === 'OWNER' || role === 'CASHIER' ? role : null;

  if (normalized === null) {
    return [];
  }

  return BACK_OFFICE_NAV_GROUPS.map((group) => ({
    label: group.label,
    items: group.items.filter((item) => item.roles.includes(normalized)),
  })).filter((group) => group.items.length > 0);
}

export function navigationItemsForRole(role: string | null | undefined): BackOfficeNavItem[] {
  return navigationGroupsForRole(role).flatMap((group) => [...group.items]);
}
