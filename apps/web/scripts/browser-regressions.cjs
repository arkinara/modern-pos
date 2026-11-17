#!/usr/bin/env node
const assert = require('node:assert/strict');
const { chromium } = require('playwright');
const fixtures = require('./fixtures/browser-regressions.json');

const WEB_BASE = process.env.WEB_BASE_URL ?? 'http://localhost:3001';
const API_BASE = process.env.API_BASE_URL ?? 'http://localhost:4000';
const OWNER_ONLY = fixtures.routes.filter(
  (route) => !fixtures.cashierLabels.some((label) => labelForRoute(route) === label),
);

let checks = 0;

function pass(message) {
  checks += 1;
  console.log(`PASS ${message}`);
}

function labelForRoute(route) {
  return fixtures.ownerLabels[fixtures.routes.indexOf(route)];
}

function channel(hex) {
  const value = parseInt(hex, 16) / 255;
  return value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4;
}

function luminance([r, g, b]) {
  return (
    0.2126 * channel(r.toString(16).padStart(2, '0')) +
    0.7152 * channel(g.toString(16).padStart(2, '0')) +
    0.0722 * channel(b.toString(16).padStart(2, '0'))
  );
}

function contrast(foreground, background) {
  const first = luminance(foreground);
  const second = luminance(background);
  return (Math.max(first, second) + 0.05) / (Math.min(first, second) + 0.05);
}

function parseRgb(value) {
  const match = /rgba?\((\d+),\s*(\d+),\s*(\d+)/.exec(value);
  assert.ok(match, `expected an rgb color, received ${value}`);
  return [Number(match[1]), Number(match[2]), Number(match[3])];
}

async function signIn(page, email, password) {
  await page.goto(`${WEB_BASE}/login`, { waitUntil: 'networkidle' });
  await page.getByLabel('Email').fill(email);
  await page.getByLabel('Password').fill(password);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('**/menu', { timeout: 30000 });
  await page.waitForSelector('nav[aria-label="Back office"]');
}

async function apiLogin(email, password) {
  const response = await fetch(`${API_BASE}/v1/auth/web/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  assert.equal(response.status, 200, `API login failed with ${response.status}`);
  const body = await response.json();
  assert.ok(body.accessToken, 'API login returned no access token');
  return body.accessToken;
}

async function listPrinters(token) {
  const response = await fetch(`${API_BASE}/v1/outlets/${fixtures.outletId}/printers`, {
    headers: { authorization: `Bearer ${token}` },
  });
  assert.equal(response.status, 200, `printer list failed with ${response.status}`);
  return response.json();
}

async function ensurePrinter(token) {
  const existing = await listPrinters(token);
  if (existing.some((printer) => printer.name === fixtures.printer.name)) {
    return;
  }

  const response = await fetch(`${API_BASE}/v1/outlets/${fixtures.outletId}/printers`, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${token}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify(fixtures.printer),
  });

  if (response.status === 201) {
    return;
  }

  if (response.status === 409) {
    const afterConflict = await listPrinters(token);
    assert.ok(
      afterConflict.some((printer) => printer.name === fixtures.printer.name),
      'printer create conflicted but the printer is absent',
    );
    return;
  }

  throw new Error(`printer create failed with ${response.status}: ${await response.text()}`);
}

function routeLabelMap() {
  const map = new Map();
  fixtures.routes.forEach((route, index) => map.set(route, fixtures.ownerLabels[index]));
  return map;
}

async function checkLayout(page, route, width, label) {
  await page.goto(`${WEB_BASE}${route}`, { waitUntil: 'networkidle' });
  await page.getByRole('heading', { level: 1 }).waitFor({ timeout: 30000 });

  const layout = await page.evaluate(() => ({
    documentWidth: document.documentElement.scrollWidth,
    bodyWidth: document.body.scrollWidth,
    viewport: window.innerWidth,
    navClient: document.querySelector('nav[aria-label="Back office"]')?.clientWidth ?? 0,
  }));
  assert.ok(
    layout.documentWidth <= layout.viewport,
    `${route} @ ${width}: document ${layout.documentWidth} > viewport ${layout.viewport}`,
  );
  assert.ok(
    layout.bodyWidth <= layout.viewport,
    `${route} @ ${width}: body ${layout.bodyWidth} > viewport ${layout.viewport}`,
  );
  assert.ok(
    layout.navClient <= layout.viewport,
    `${route} @ ${width}: navigation ${layout.navClient} > viewport ${layout.viewport}`,
  );

  const active = await page
    .locator('nav[aria-label="Back office"] a[aria-current="page"]')
    .getAttribute('href');
  assert.equal(active, route, `${route} @ ${width}: active navigation state`);
  pass(`${label} (${route}) @ ${width}px: accessible active route with no horizontal overflow`);
}

async function checkKeyboardAndTargets(page, width) {
  await page.goto(`${WEB_BASE}/menu`, { waitUntil: 'networkidle' });

  const targetSizes = await page.evaluate(() =>
    [...document.querySelectorAll('nav[aria-label="Back office"] a')].map((link) => {
      const box = link.getBoundingClientRect();
      return { width: box.width, height: box.height };
    }),
  );
  assert.equal(targetSizes.length, 15);
  for (const box of targetSizes) {
    assert.ok(box.height >= 44, `nav target height ${box.height} < 44 at ${width}px`);
  }
  pass(`navigation @ ${width}px: all 15 targets are at least 44px tall`);

  let focusedInNavigation = false;
  for (let attempt = 0; attempt < 40; attempt += 1) {
    await page.keyboard.press('Tab');
    const focused = await page.evaluate(() => {
      const element = document.activeElement;
      if (!(element instanceof HTMLElement)) {
        return null;
      }
      const styles = getComputedStyle(element);
      return {
        inNavigation: Boolean(element.closest('nav[aria-label="Back office"]')),
        tag: element.tagName,
        outlineStyle: styles.outlineStyle,
        outlineWidth: parseFloat(styles.outlineWidth),
      };
    });
    if (focused?.inNavigation) {
      assert.equal(focused.tag, 'A');
      assert.notEqual(focused.outlineStyle, 'none');
      assert.ok(focused.outlineWidth >= 3, `focus outline ${focused.outlineWidth}px < 3px`);
      focusedInNavigation = true;
      break;
    }
  }
  assert.ok(focusedInNavigation, `navigation @ ${width}px: no keyboard focus reached a link`);
  pass(`navigation @ ${width}px: keyboard focus reaches a link with a 3px visible outline`);

  if (width === 320) {
    const colors = await page.evaluate(() => {
      const active = document.querySelector('nav[aria-label="Back office"] a[aria-current="page"]');
      const inactive = document.querySelector(
        'nav[aria-label="Back office"] a:not([aria-current="page"])',
      );
      if (!(active instanceof HTMLElement) || !(inactive instanceof HTMLElement)) {
        return null;
      }
      const activeStyle = getComputedStyle(active);
      const inactiveStyle = getComputedStyle(inactive);
      const asideStyle = getComputedStyle(active.closest('aside'));
      const bodyStyle = getComputedStyle(document.body);
      return {
        activeText: activeStyle.color,
        activeBackground: activeStyle.backgroundColor,
        inactiveText: inactiveStyle.color,
        navBackground: asideStyle.backgroundColor,
        bodyText: bodyStyle.color,
        bodyBackground: bodyStyle.backgroundColor,
      };
    });
    assert.ok(colors, 'contrast colors could not be read');
    const ratios = {
      active: contrast(parseRgb(colors.activeText), parseRgb(colors.activeBackground)),
      inactive: contrast(parseRgb(colors.inactiveText), parseRgb(colors.navBackground)),
      body: contrast(parseRgb(colors.bodyText), parseRgb(colors.bodyBackground)),
    };
    assert.ok(ratios.active >= 4.5, `active nav contrast ${ratios.active.toFixed(2)} < 4.5`);
    assert.ok(ratios.inactive >= 4.5, `inactive nav contrast ${ratios.inactive.toFixed(2)} < 4.5`);
    assert.ok(ratios.body >= 4.5, `body contrast ${ratios.body.toFixed(2)} < 4.5`);
    pass(
      `contrast @ 320px: active nav ${ratios.active.toFixed(2)}:1, inactive nav ${ratios.inactive.toFixed(2)}:1, body ${ratios.body.toFixed(2)}:1`,
    );
  }
}

async function checkReports(page) {
  await page.goto(`${WEB_BASE}/reports`, { waitUntil: 'networkidle' });
  const dates = page.locator('input[type="date"]');
  await dates.nth(0).fill(fixtures.saleDate);
  await dates.nth(1).fill(fixtures.saleDate);
  await page.getByText('Gross item sales', { exact: true }).first().waitFor({ timeout: 20000 });
  await page.getByText('Payment-method totals', { exact: true }).first().waitFor();
  await page.getByText('Definitions', { exact: true }).waitFor();
  pass('owner /reports shows the populated daily report and definitions');

  const downloadPromise = page.waitForEvent('download', { timeout: 20000 });
  await page.getByRole('button', { name: /Export CSV/ }).click();
  const download = await downloadPromise;
  assert.equal(download.suggestedFilename(), fixtures.csvFilename);
  pass(`owner /reports downloads CSV ${fixtures.csvFilename}`);
}

async function checkPrinters(page, token) {
  const printerListRoute = (url) =>
    url.pathname.endsWith('/printers') && url.pathname.includes('/outlets/');
  await page.route(printerListRoute, async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: '[]',
    });
  });
  await page.goto(`${WEB_BASE}/printers`, { waitUntil: 'networkidle' });
  await page.getByText('No printer configuration registered', { exact: true }).waitFor({
    timeout: 20000,
  });
  assert.match(await page.locator('body').innerText(), /empty state, not a connection failure/i);
  await page.unroute(printerListRoute);
  pass('printer empty state is explicit and never presented as a connection failure');

  await ensurePrinter(token);
  await page.goto(`${WEB_BASE}/printers`, { waitUntil: 'networkidle' });
  await page.getByText(fixtures.printer.name, { exact: true }).waitFor({ timeout: 20000 });
  const printerText = await page.locator('body').innerText();
  for (const expected of [
    fixtures.printer.model,
    fixtures.printer.transport,
    `${fixtures.printer.paperWidthMm} mm`,
    fixtures.printer.encoding,
  ]) {
    assert.match(printerText, new RegExp(expected.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
  }
  assert.match(printerText, /not proof that it is online, connected or physically tested/i);
  assert.doesNotMatch(printerText, /fixture-do-not-render/);
  assert.equal(await page.getByText(/^(Connected|Ready|Online)$/).count(), 0);
  pass(
    'printer populated state shows real non-secret metadata with no physical-connectivity claim',
  );

  await page.route(printerListRoute, async (route) => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({
        code: 'IN_FAILURE',
        message: 'synthetic printer failure',
        retryable: true,
      }),
    });
  });
  await page.goto(`${WEB_BASE}/printers`, { waitUntil: 'networkidle' });
  await page.getByText(/Could not load registered printers/i).waitFor({ timeout: 20000 });
  const errorCard = page
    .locator('div[role="alert"]')
    .filter({ hasText: /printer/i })
    .first();
  await errorCard.getByRole('button', { name: 'Try again' }).waitFor();
  await page.unroute(printerListRoute);
  pass('printer error state shows the failure and an explicit retry action');
}

async function checkStock(page) {
  await page.goto(`${WEB_BASE}/stock`, { waitUntil: 'networkidle' });
  const historyButtons = page.getByRole('button', { name: 'History' });
  const ownerHistoryCount = await historyButtons.count();
  assert.ok(ownerHistoryCount > 0, 'owner should see stock movement-history actions');
  await historyButtons.first().click();
  await page.getByText(/Movement history ·/).waitFor({ timeout: 20000 });
  await page.getByText('OPENING', { exact: true }).first().waitFor({ timeout: 20000 });
  pass(`owner stock page opens the movement ledger (${ownerHistoryCount} history actions)`);

  await page.getByRole('button', { name: 'Close history' }).click();
  const movementsRoute = (url) =>
    url.pathname.includes('/stock/') && url.pathname.endsWith('/movements');
  await page.route(movementsRoute, async (route) => {
    await route.fulfill({
      status: 403,
      contentType: 'application/json',
      body: JSON.stringify({ code: 'FORBIDDEN', message: 'forbidden', retryable: false }),
    });
  });
  await page.getByRole('button', { name: 'History' }).nth(1).click();
  await page
    .getByText('Only an owner can view stock movement history.', { exact: true })
    .waitFor({ timeout: 20000 });
  assert.doesNotMatch(await page.locator('body').innerText(), /change outlet settings/i);
  await page.unroute(movementsRoute);
  pass('stock-history 403 copy names the read action, not an outlet settings change');
}

async function checkSalesReferenceSearch(page) {
  await page.goto(`${WEB_BASE}/sales`, { waitUntil: 'networkidle' });
  const dates = page.locator('input[type="date"]');
  await dates.nth(0).fill(fixtures.saleDate);
  await dates.nth(1).fill(fixtures.saleDate);
  await page.getByText(fixtures.seedSaleReference, { exact: false }).first().waitFor({
    timeout: 20000,
  });

  const initialRows = await page.locator('tbody tr').count();
  assert.ok(initialRows > 0, 'expected at least one seeded sale row');

  const matchingRequest = page.waitForRequest(
    (request) => request.url().includes('/sales?') && request.url().includes('reference='),
    { timeout: 20000 },
  );
  await page.getByLabel('Sale reference').fill('SEED-MAIN');
  const request = await matchingRequest;
  const requestUrl = new URL(request.url());
  assert.equal(requestUrl.pathname, `/v1/outlets/${fixtures.outletId}/sales`);
  assert.equal(requestUrl.searchParams.get('reference'), 'SEED-MAIN');
  assert.equal(requestUrl.searchParams.get('from'), fixtures.saleDate);
  assert.equal(requestUrl.searchParams.get('to'), fixtures.saleDate);
  await page.getByText(fixtures.seedSaleReference, { exact: false }).first().waitFor({
    timeout: 20000,
  });
  pass('reference search reaches the API with outlet, date range and reference scope');

  await page.getByLabel('Sale reference').fill(fixtures.unknownReference);
  await page.getByText(/No sales match this reference/i).waitFor({ timeout: 20000 });
  pass('unknown reference shows the explicit no-match state');

  await page.getByRole('button', { name: 'Clear' }).click();
  await page.waitForFunction(
    (count) => document.querySelectorAll('tbody tr').length === count,
    initialRows,
  );
  await page.getByText(fixtures.seedSaleReference, { exact: false }).first().waitFor({
    timeout: 20000,
  });
  pass('clearing the reference restores the date-filtered sale list');
}

async function checkCashier(browser) {
  const context = await browser.newContext({ viewport: { width: 1024, height: 900 } });
  const page = await context.newPage();
  const reportRequests = [];
  page.on('request', (request) => {
    if (request.url().includes('/reports/daily')) {
      reportRequests.push(request.url());
    }
  });

  await signIn(page, fixtures.cashier.email, fixtures.cashier.password);
  const cashierLabels = (
    await page.locator('nav[aria-label="Back office"] a').allTextContents()
  ).map((label) => label.trim());
  assert.deepEqual(cashierLabels, fixtures.cashierLabels);
  for (const route of OWNER_ONLY) {
    assert.equal(
      cashierLabels.includes(routeLabelMap().get(route)),
      false,
      `cashier must not see ${route}`,
    );
  }
  pass('cashier navigation shows only the seven permitted destinations');

  await page.goto(`${WEB_BASE}/reports`, { waitUntil: 'domcontentloaded' });
  await page.getByText('Owner-only reports', { exact: true }).waitFor({ timeout: 5000 });
  assert.equal(reportRequests.length, 0, 'cashier /reports issued a report request');
  assert.match(await page.locator('body').innerText(), /requires an owner account/i);
  assert.doesNotMatch(await page.locator('body').innerText(), /Loading report/);
  pass('cashier direct /reports shows the owner-only state with zero report requests');

  await page.goto(`${WEB_BASE}/stock`, { waitUntil: 'networkidle' });
  await page.getByRole('heading', { name: 'Stock', exact: true }).waitFor();
  assert.equal(await page.getByRole('button', { name: 'History' }).count(), 0);
  pass('cashier stock page has no guaranteed-403 movement-history action');

  await page.goto(`${WEB_BASE}/menu`, { waitUntil: 'networkidle' });
  await page.getByRole('heading', { name: 'Menu', exact: true }).waitFor();
  pass('cashier can still open the permitted menu route');

  await context.close();
}

(async () => {
  const browser = await chromium.launch({ headless: true });

  try {
    const ownerContext = await browser.newContext({
      viewport: { width: 1024, height: 900 },
      acceptDownloads: true,
    });
    const ownerPage = await ownerContext.newPage();

    await signIn(ownerPage, fixtures.owner.email, fixtures.owner.password);
    pass('owner signs in and reaches the back office');

    const ownerLabels = (
      await ownerPage.locator('nav[aria-label="Back office"] a').allTextContents()
    ).map((label) => label.trim());
    assert.deepEqual(ownerLabels, fixtures.ownerLabels);
    pass('owner navigation exposes all 15 grouped destinations');

    const groupLabels = (
      await ownerPage.locator('nav[aria-label="Back office"] p').allTextContents()
    ).map((label) => label.trim());
    assert.deepEqual(groupLabels, fixtures.navGroups);
    pass('owner navigation is grouped into Selling, Operations, Insights and Administration');

    for (const label of ownerLabels) {
      assert.equal(
        await ownerPage.getByRole('link', { name: label, exact: true }).count(),
        1,
        `expected one accessible link named ${label}`,
      );
    }
    pass('all 15 navigation links expose one accessible link role and name');

    const labelMap = routeLabelMap();
    for (const width of fixtures.widths) {
      await ownerPage.setViewportSize({ width, height: 900 });
      for (const route of fixtures.routes) {
        await checkLayout(ownerPage, route, width, labelMap.get(route));
      }
      await checkKeyboardAndTargets(ownerPage, width);
    }

    await ownerPage.setViewportSize({ width: 1024, height: 900 });
    await checkReports(ownerPage);

    const token = await apiLogin(fixtures.owner.email, fixtures.owner.password);
    await checkPrinters(ownerPage, token);
    await checkStock(ownerPage);
    await checkSalesReferenceSearch(ownerPage);

    await ownerContext.close();
    await checkCashier(browser);
  } finally {
    await browser.close();
  }

  console.log(`TOTAL CHECKS ${checks}`);
  console.log('ALL BROWSER REGRESSION CHECKS PASSED');
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
