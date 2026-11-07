#!/usr/bin/env node
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), 'utf8');
const exists = (...parts) => fs.existsSync(path.join(root, ...parts));

assert.match(read('app', 'page.tsx'), /redirect\('\/menu'\)/, 'root must land on Menu');
assert.ok(!exists('app', '(backoffice)', 'cashier'), 'no cashier route');
assert.ok(!exists('app', '(backoffice)', 'cart'), 'no cart route');
assert.ok(!exists('app', '(backoffice)', 'checkout'), 'no checkout route');

for (const route of ['menu', 'stock', 'sales', 'reports', 'printers', 'settings']) {
  assert.ok(exists('app', '(backoffice)', route, 'page.tsx'), `missing /${route} route`);
}

const nav = read('components', 'sidebar-nav.tsx');
const labels = [...nav.matchAll(/label: '([^']+)'/g)].map((match) => match[1]);
assert.deepEqual(
  labels,
  ['Menu', 'Stock', 'Sales', 'Reports', 'Printers', 'Settings'],
  'navigation labels and order changed',
);
assert.match(nav, /aria-current=\{active \? 'page' : undefined\}/, 'selected nav state missing');
assert.match(nav, /overflow-x-auto/, 'mobile navigation needs its own scroll container');
assert.match(nav, /shrink-0/, 'mobile navigation items must not collapse');

const layout = read('app', '(backoffice)', 'layout.tsx');
assert.match(layout, /flex-col md:flex-row/, 'shell must stack below the desktop breakpoint');
assert.match(layout, /md:w-\[var\(--pos-sidebar\)\]/, 'desktop sidebar width token missing');
assert.match(layout, /min-w-0 flex-1/, 'main region must be allowed to shrink');

const sales = read('app', '(backoffice)', 'sales', 'page.tsx');
assert.match(sales, /overflow-x-auto/, 'sales table needs an internal scroll container');
assert.match(sales, /mobile-originated/i, 'sales page must name the mobile source');
assert.doesNotMatch(sales, /href="\/(sales|checkout|cart)/i, 'sales page must not link to a sale flow');

const reports = read('app', '(backoffice)', 'reports', 'page.tsx');
assert.match(reports, /mobile-recorded|mobile-originated/i, 'reports page must name the mobile source');
assert.doesNotMatch(reports, /href=/i, 'empty reports must not link to a sale flow');

const settings = read('components', 'settings-screen.tsx');
assert.match(settings, /Try again/, 'settings failure state needs a retry action');
assert.match(settings, /role="alert"/, 'settings failure state needs an alert region');
const printers = read('components', 'printers-screen.tsx');
assert.match(printers, /Try again/, 'printers failure state needs a retry action');
assert.match(printers, /serviceQuery\.data\.receiptHeader|receiptHeader/, 'receipt identity missing');

const forbidden = /cashier|cart|checkout|tender|new.?sale/i;
for (const directory of ['app', 'components', 'lib']) {
  for (const file of walk(path.join(root, directory))) {
    if (!/\.(ts|tsx|css)$/.test(file)) {
      continue;
    }
    const source = fs.readFileSync(file, 'utf8');
    assert.doesNotMatch(source, forbidden, `forbidden cashier-flow text in ${file}`);
  }
}

console.log(
  'Back-office shell source checks passed: menu landing, six routes, selected nav state, internal scroll containers, retry states, no cashier-flow routes or labels.',
);

function walk(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(full) : [full];
  });
}
