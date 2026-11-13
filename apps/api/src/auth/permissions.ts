import { Role } from '@prisma/client';

/**
 * Operational permissions are the single source of truth for shift, attendance
 * and audit access. Controllers reference these keys through @RequirePermission
 * instead of repeating role strings, and the same matrix is returned to the back
 * office permission view.
 */
export const PERMISSIONS = {
  SHIFT_READ: 'shift.read',
  SHIFT_OPEN: 'shift.open',
  SHIFT_CASH_IN: 'shift.cash_in',
  SHIFT_CASH_OUT: 'shift.cash_out',
  SHIFT_CLOSE: 'shift.close',
  SHIFT_REPORT_READ: 'shift.report.read',
  ATTENDANCE_CLOCK: 'attendance.clock',
  ATTENDANCE_READ: 'attendance.read',
  AUDIT_SEARCH: 'audit.search',
  PERMISSION_MATRIX_READ: 'permission.read',
  SUPPLIER_MANAGE: 'supplier.manage',
  PURCHASE_ORDER_MANAGE: 'purchase_order.manage',
  STOCK_COUNT: 'stock.count',
  STOCK_WASTE: 'stock.waste',
  STOCK_TRANSFER: 'stock.transfer',
} as const;

export type Permission = (typeof PERMISSIONS)[keyof typeof PERMISSIONS];

export interface PermissionDefinition {
  key: Permission;
  label: string;
  description: string;
}

export const PERMISSION_DEFINITIONS: readonly PermissionDefinition[] = [
  {
    key: PERMISSIONS.SHIFT_READ,
    label: 'Read shifts',
    description: 'Read the caller own shifts. Owners read every shift in the outlet.',
  },
  {
    key: PERMISSIONS.SHIFT_OPEN,
    label: 'Open shift',
    description: 'Open one drawer shift with an opening float.',
  },
  {
    key: PERMISSIONS.SHIFT_CASH_IN,
    label: 'Record paid-in',
    description: 'Add cash to the open shift with a reason and actor.',
  },
  {
    key: PERMISSIONS.SHIFT_CASH_OUT,
    label: 'Record paid-out',
    description: 'Remove cash from the open shift within the approval limit.',
  },
  {
    key: PERMISSIONS.SHIFT_CLOSE,
    label: 'Close shift',
    description: 'Count the drawer and close the caller own open shift.',
  },
  {
    key: PERMISSIONS.SHIFT_REPORT_READ,
    label: 'Read shift report',
    description: 'Read the reconciled per-shift cash report and payment totals.',
  },
  {
    key: PERMISSIONS.ATTENDANCE_CLOCK,
    label: 'Clock attendance',
    description: 'Clock in and clock out. Never opens or closes a shift.',
  },
  {
    key: PERMISSIONS.ATTENDANCE_READ,
    label: 'Read attendance',
    description: 'Read the caller own attendance. Owners read every outlet record.',
  },
  {
    key: PERMISSIONS.AUDIT_SEARCH,
    label: 'Search audit trail',
    description: 'Filter operational audit events by actor, action and time.',
  },
  {
    key: PERMISSIONS.PERMISSION_MATRIX_READ,
    label: 'Read permission matrix',
    description: 'Read the role-to-operation matrix used by the guards.',
  },
  {
    key: PERMISSIONS.SUPPLIER_MANAGE,
    label: 'Manage suppliers',
    description: 'Create and read supplier records for purchasing.',
  },
  {
    key: PERMISSIONS.PURCHASE_ORDER_MANAGE,
    label: 'Manage purchase orders',
    description: 'Create purchase orders and receive ordered stock in supplier or base units.',
  },
  {
    key: PERMISSIONS.STOCK_COUNT,
    label: 'Record stock count',
    description: 'Count stock and post counted variances with a reason and actor.',
  },
  {
    key: PERMISSIONS.STOCK_WASTE,
    label: 'Record waste',
    description: 'Remove damaged, expired, stolen or spoiled stock with a mandatory reason.',
  },
  {
    key: PERMISSIONS.STOCK_TRANSFER,
    label: 'Transfer between outlets',
    description: 'Create, dispatch, receive and cancel outlet transfers. Owners only.',
  },
];

const ALL_PERMISSIONS = PERMISSION_DEFINITIONS.map((definition) => definition.key);

export const ROLE_PERMISSIONS: Record<Role, readonly Permission[]> = {
  [Role.OWNER]: ALL_PERMISSIONS,
  [Role.CASHIER]: [
    PERMISSIONS.SHIFT_READ,
    PERMISSIONS.SHIFT_OPEN,
    PERMISSIONS.SHIFT_CASH_IN,
    PERMISSIONS.SHIFT_CASH_OUT,
    PERMISSIONS.SHIFT_CLOSE,
    PERMISSIONS.ATTENDANCE_CLOCK,
    PERMISSIONS.ATTENDANCE_READ,
    PERMISSIONS.STOCK_COUNT,
    PERMISSIONS.STOCK_WASTE,
  ],
};

export function permissionsForRole(role: Role): readonly Permission[] {
  return ROLE_PERMISSIONS[role] ?? [];
}

export function hasPermission(role: Role, permission: Permission): boolean {
  return permissionsForRole(role).includes(permission);
}
