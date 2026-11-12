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
  ],
};

export function permissionsForRole(role: Role): readonly Permission[] {
  return ROLE_PERMISSIONS[role] ?? [];
}

export function hasPermission(role: Role, permission: Permission): boolean {
  return permissionsForRole(role).includes(permission);
}
