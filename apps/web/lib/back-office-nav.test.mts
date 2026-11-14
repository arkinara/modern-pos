import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  BACK_OFFICE_NAV_GROUPS,
  navigationGroupsForRole,
  navigationItemsForRole,
} from './back-office-nav.ts';

const ALL_HREFS = [
  '/menu',
  '/stock',
  '/sales',
  '/promotions',
  '/ordering',
  '/shifts',
  '/attendance',
  '/purchasing',
  '/printers',
  '/reports',
  '/bookkeeping',
  '/customers',
  '/audit',
  '/permissions',
  '/settings',
];

test('owners see every implemented module exactly once', () => {
  const items = navigationItemsForRole('OWNER');
  assert.deepEqual(items.map((item) => item.href).sort(), [...ALL_HREFS].sort());
  assert.equal(new Set(items.map((item) => item.href)).size, ALL_HREFS.length);
  assert.equal(
    BACK_OFFICE_NAV_GROUPS.reduce((total, group) => total + group.items.length, 0),
    ALL_HREFS.length,
  );
});

test('cashiers see only permitted modules and no owner-only destination', () => {
  const items = navigationItemsForRole('CASHIER');
  assert.deepEqual(
    items.map((item) => item.href),
    ['/menu', '/stock', '/sales', '/promotions', '/ordering', '/shifts', '/attendance'],
  );

  for (const ownerOnly of [
    '/purchasing',
    '/printers',
    '/reports',
    '/bookkeeping',
    '/customers',
    '/audit',
    '/permissions',
    '/settings',
  ]) {
    assert.equal(
      items.some((item) => item.href === ownerOnly),
      false,
      `${ownerOnly} must stay hidden from a cashier`,
    );
  }
});

test('unknown roles receive no navigation instead of every destination', () => {
  assert.deepEqual(navigationItemsForRole(undefined), []);
  assert.deepEqual(navigationGroupsForRole(null), []);
  assert.deepEqual(navigationItemsForRole('MANAGER'), []);
});
