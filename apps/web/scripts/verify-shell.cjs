#!/usr/bin/env node
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { pathToFileURL } = require('node:url');

const root = path.resolve(__dirname, '..');
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), 'utf8');
const exists = (...parts) => fs.existsSync(path.join(root, ...parts));

const EXPECTED_OWNER_HREFS = [
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

const EXPECTED_CASHIER_HREFS = [
  '/menu',
  '/stock',
  '/sales',
  '/promotions',
  '/ordering',
  '/shifts',
  '/attendance',
];

const FORBIDDEN_HREF = /^\/(cashier|cart|checkout|tender|new-sale)(\/|$)/i;

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});

async function main() {
  assert.match(read('app', 'page.tsx'), /redirect\('\/menu'\)/, 'root must land on Menu');

  for (const route of ['cashier', 'cart', 'checkout', 'tender', 'new-sale']) {
    assert.ok(!exists('app', '(backoffice)', route), `no ${route} route`);
  }

  const navModule = await import(
    pathToFileURL(path.join(root, 'lib', 'back-office-nav.ts')).href
  );
  const {
    BACK_OFFICE_NAV_GROUPS,
    navigationGroupsForRole,
    navigationItemsForRole,
  } = navModule;

  assert.equal(
    BACK_OFFICE_NAV_GROUPS.length,
    new Set(BACK_OFFICE_NAV_GROUPS.map((group) => group.label)).size,
    'navigation group labels must be unique',
  );
  assert.ok(BACK_OFFICE_NAV_GROUPS.every((group) => group.items.length > 0), 'empty nav group');

  const ownerItems = navigationItemsForRole('OWNER');
  const ownerHrefs = ownerItems.map((item) => item.href);
  assert.deepEqual(
    [...ownerHrefs].sort(),
    [...EXPECTED_OWNER_HREFS].sort(),
    'owner navigation must expose all 15 back-office destinations',
  );
  assert.equal(ownerHrefs.length, 15, 'owner navigation must contain exactly 15 destinations');
  assert.equal(new Set(ownerHrefs).size, ownerHrefs.length, 'owner destinations must be unique');
  assert.equal(
    new Set(ownerItems.map((item) => item.label)).size,
    ownerItems.length,
    'owner destination labels must be unique',
  );

  const routeDirectories = fs
    .readdirSync(path.join(root, 'app', '(backoffice)'), { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => `/${entry.name}`)
    .sort();
  assert.deepEqual(
    routeDirectories,
    [...EXPECTED_OWNER_HREFS].sort(),
    'back-office routes must match the owner navigation destinations',
  );

  for (const href of EXPECTED_OWNER_HREFS) {
    const route = href.slice(1);
    const pageFile = path.join(root, 'app', '(backoffice)', route, 'page.tsx');
    assert.ok(fs.existsSync(pageFile), `missing /${route} route`);
    const page = fs.readFileSync(pageFile, 'utf8');
    assert.match(
      page,
      /import \{ \w+Screen \} from '@\/components\/[\w-]+-screen';/,
      `/${route} page must delegate to a screen component`,
    );
    assert.match(page, /<\w+Screen \/>/, `/${route} page must render its screen component`);
  }

  const cashierItems = navigationItemsForRole('CASHIER');
  const cashierHrefs = cashierItems.map((item) => item.href);
  assert.deepEqual(
    cashierHrefs,
    EXPECTED_CASHIER_HREFS,
    'cashier navigation must expose the permitted destinations',
  );
  assert.equal(new Set(cashierHrefs).size, cashierHrefs.length, 'cashier destinations unique');

  const ownerOnlyHrefs = EXPECTED_OWNER_HREFS.filter((href) => !cashierHrefs.includes(href));
  assert.equal(ownerOnlyHrefs.length, 8, 'expected eight owner-only destinations');

  for (const item of ownerItems) {
    const cashierVisible = cashierHrefs.includes(item.href);
    assert.equal(
      item.roles.includes('CASHIER'),
      cashierVisible,
      `${item.href} role definition must match cashier visibility`,
    );
    if (item.roles.includes('CASHIER')) {
      assert.ok(
        EXPECTED_CASHIER_HREFS.includes(item.href),
        `${item.href} must be a permitted cashier destination`,
      );
    } else {
      assert.ok(ownerOnlyHrefs.includes(item.href), `${item.href} must be owner-only`);
      assert.ok(
        !cashierVisible,
        `${item.href} is owner-only and must not be enabled for a cashier`,
      );
    }
  }

  for (const item of [...ownerItems, ...cashierItems]) {
    assert.doesNotMatch(item.href, FORBIDDEN_HREF, `cashier-flow destination ${item.href}`);
  }

  for (const routeHref of routeDirectories) {
    assert.doesNotMatch(routeHref, FORBIDDEN_HREF, `cashier-flow route ${routeHref}`);
  }

  const nav = read('components', 'sidebar-nav.tsx');
  assert.match(
    nav,
    /import \{ navigationGroupsForRole \} from '@\/lib\/back-office-nav'/,
    'sidebar must render the shared navigation definition',
  );
  assert.match(nav, /navigationGroupsForRole\(/, 'sidebar must derive destinations by role');
  assert.doesNotMatch(nav, /label: '/, 'sidebar must not keep inline destination labels');
  assert.match(nav, /aria-current=\{active \? 'page' : undefined\}/, 'selected nav state missing');
  assert.match(nav, /overflow-x-auto/, 'mobile navigation needs its own scroll container');
  assert.match(nav, /shrink-0/, 'mobile navigation items must not collapse');

  const layout = read('app', '(backoffice)', 'layout.tsx');
  assert.match(layout, /flex-col md:flex-row/, 'shell must stack below the desktop breakpoint');
  assert.match(layout, /md:w-\[var\(--pos-sidebar\)\]/, 'desktop sidebar width token missing');
  assert.match(layout, /min-w-0 flex-1/, 'main region must be allowed to shrink');

  const sales = read('components', 'sales-screen.tsx');
  assert.match(sales, /overflow-x-auto/, 'sales table needs an internal scroll container');
  assert.match(sales, /read-only history/i, 'sales screen must stay read-only');
  assert.match(sales, /Android\s+app/i, 'sales screen must name the mobile source');
  assertNoForbiddenHref(sales, 'sales screen');

  const reports = read('components', 'reports-screen.tsx');
  assert.match(reports, /Android\s+app/i, 'reports screen must name the mobile source');
  assertNoForbiddenHref(reports, 'reports screen');

  const settings = read('components', 'settings-screen.tsx');
  assert.match(settings, /Try again/, 'settings failure state needs a retry action');
  assert.match(settings, /role="alert"/, 'settings failure state needs an alert region');
  const printers = read('components', 'printers-screen.tsx');
  assert.match(printers, /Try again/, 'printers failure state needs a retry action');
  assert.match(printers, /serviceQuery\.data\.receiptHeader|receiptHeader/, 'receipt identity missing');

  const ownerOnly = ownerOnlyHrefs.join(', ');
  console.log(
    `Back-office shell source checks passed: menu landing, 15 owner destinations exactly once, 7 cashier destinations with no owner-only route, ${ownerOnly} owner-only, selected nav state, responsive shell, retry states, page wrappers delegating to screens, no cashier-flow routes or links.`,
  );
}

function assertNoForbiddenHref(source, label) {
  for (const match of source.matchAll(/href=["']([^"']+)["']/g)) {
    assert.doesNotMatch(match[1], FORBIDDEN_HREF, `${label} must not link to ${match[1]}`);
  }
}
