# Usability refinement from measured operator feedback (#29)

Status: implemented and verified on synthetic local data. No real cashier or owner
was observed. Everything below is a developer walkthrough, Playwright check or API
measurement against the staging/synthetic databases; it is not field evidence.

Source discovery: [#28](https://github.com/arkinara/modern-pos/issues/28) and
`docs/operator-feedback.md`. Umbrella ticket: #29. Implementation tickets:
[#56](https://github.com/arkinara/modern-pos/issues/56),
[#57](https://github.com/arkinara/modern-pos/issues/57),
[#58](https://github.com/arkinara/modern-pos/issues/58),
[#59](https://github.com/arkinara/modern-pos/issues/59) and
[#60](https://github.com/arkinara/modern-pos/issues/60).

## Chosen items and why

All five approved issues were chosen. Each traces to a ranked friction entry in
`docs/operator-feedback.md`, and each fix is small and root-cause.

| Issue | Friction | Rank / score | Why chosen | Success criterion |
| --- | --- | --- | --- | --- |
| #56 | F1 | 2 / 16 | Owners cannot discover nine implemented modules without knowing URLs. | An owner reaches all 15 implemented modules from primary navigation in one click; a cashier sees only role-permitted modules; no 320 px overflow. |
| #57 | F2 | 3 / 15 | A cashier is sent into four guaranteed 403 requests and a multi-second loading state. | A cashier sees an owner-only state with zero report requests sent; an owner keeps the full report and CSV export. |
| #58 | F3 | 1 / 16 | A hard-coded "No printer registered" card misleads an owner during setup and support. | With a registered printer, the Printers page lists its name, model, transport, width and encoding; with none, it shows an explicit empty state rather than a failed connection. |
| #59 | F4 | 4 / 15 | Every cashier stock card advertises a History action that always returns 403, and the error names the wrong action. | A cashier sees zero movement-history actions; an owner still opens the ledger; a stock-history 403 says it is about viewing history, not changing outlet settings. |
| #60 | F5 | 5 / 12 | Finding one receipt for support needs date widening and paging as sale volume grows. | The API applies full or partial reference search inside the selected outlet and date range; clearing it restores the normal list. |

Deferred: F6 (read-only print-job history) remains the ranked, unticketed
candidate. Its impact is lower than the five approved items and the Android queue
already owns print execution. No #56-#60 issue was deferred.

## Before and after evidence

All values are synthetic and reproducible with the commands in this document.
"Before" values come from the #28 walkthrough and the code paths it cited; "after"
values were measured on this branch.

| Issue | Before | After | Evidence |
| --- | --- | --- | --- |
| #56 | Primary sidebar had 6 links: Menu, Stock, Sales, Reports, Printers, Settings. Nine implemented routes were reachable only from secondary links or a known URL. | Owner primary navigation has 15 grouped links covering every implemented route. Cashier navigation has 7 permitted links and no owner-only destination. Every link has a link role and accessible name; the active route has `aria-current="page"`. | `qa29-verify.cjs`: 15/15 owner labels, 4 group labels, 7 cashier labels, accessible names, active route at 320/768/1024/1440. |
| #57 | Cashier `/reports` issued four `GET /reports/daily` requests, each 403, and stayed loading for about four seconds. | Cashier `/reports` issues **0** report requests and immediately renders "Owner-only reports" / "requires an owner account". The API owner guard is unchanged. The owner report and CSV export still work. | Playwright intercepted `/reports/daily` requests: 0 for a cashier. Owner CSV and figures remain covered by `qa5-verify.cjs`. Message appeared 690 ms after navigation in the final run; repeated dev runs ranged 683-1064 ms, with the cold run above one second because of Next.js development compilation. There is no retry loop. |
| #58 | The page always rendered a hard-coded `No printer registered`; an owner could not tell which printer was configured. `GET /printers` without `deviceId` returned 400. | Registered printers are listed with name, model, transport, paper width and encoding; connection settings are not returned. An owner may omit `deviceId` and receives the outlet's non-secret printer metadata (`200`). A cashier still needs a device ID. Empty and error states are explicit and retryable. | API on the synthetic database: before `400 VALIDATION_ERROR` (deviceId required); after `200` with the registered printer. Playwright on staging: `Counter printer`, `TM-T82`, `LAN`, `80 mm`, `CP437`, and no `No printer registered` text. |
| #59 | A cashier saw a History button on every stock card; the request returned 403 and the UI said "This account is not allowed to change outlet settings." | A cashier sees 0 History actions. An owner still sees 21 actions on the staging page and opens the append-only ledger. A forced 403 displays "Only an owner can view stock movement history." | Playwright cashier count = 0, owner count = 21. A routed 403 response produced the new text and no "change outlet settings" text. |
| #60 | `reference` was not a valid list query; the API answered `400 VALIDATION_ERROR` (`property reference should not exist`). The UI loaded 25 rows per page with no reference filter. | The API accepts a full or partial reference, case-insensitive, scoped to the outlet, caller role and required date range. The UI sends the filter to the API and shows an explicit no-match state; Clear restores the date-filtered list. | Before: 22 visible rows for the date and a rejected `reference` query. After: partial lower-case reference returned 1 matching sale; an unknown reference returned 0; reference without dates returned 400. Playwright confirmed the browser request contained `reference=...`, the table narrowed to one row, and clearing restored more than one row. |

### Reproduction commands used

Reference search and printer metadata (synthetic database on port 4100):

```bash
TOKEN=$(curl -sS -X POST http://localhost:4100/v1/auth/mobile/login \
  -H 'content-type: application/json' \
  -d '{"email":"owner@example.test","password":"modern-pos-demo-password","deviceId":"00000000-0000-4000-8000-000000000091"}' \
  | jq -r .accessToken)

# Full/partial reference search inside a date range
curl -sS "http://localhost:4100/v1/outlets/00000000-0000-4000-8000-000000000002/sales?from=2026-11-14&to=2026-11-14&reference=50a63469" \
  -H "authorization: Bearer $TOKEN" | jq '.items | length'

# Owner printer metadata without a device filter
curl -sS "http://localhost:4100/v1/outlets/00000000-0000-4000-8000-000000000002/printers" \
  -H "authorization: Bearer $TOKEN" | jq '[.[] | {name, model, transport, paperWidthMm, encoding}]'

# The same request as a cashier still requires a device ID
curl -sS -o /dev/null -w '%{http_code}\n' \
  "http://localhost:4100/v1/outlets/00000000-0000-4000-8000-000000000002/printers" \
  -H "authorization: Bearer $CASHIER_TOKEN"
```

Browser walkthrough:

```bash
cd /tmp/qa5-pw
node qa29-verify.cjs   # 82 checks, ticket #29 improvements
node qa5-verify.cjs    # 37 checks, existing back-office regression suite
```

## Accessibility results

These are targeted checks, not a full WCAG audit. Real assistive-technology
testing with a screen reader is still pending.

| Check | Result |
| --- | --- |
| Keyboard reachability | Every primary navigation link is in tab order. Tab reached the navigation at 320, 768, 1024 and 1440 px. |
| Visible focus | Navigation focus and the sales-reference input render a 3 px accent outline with 3 px offset. The shared Button component no longer suppresses the global focus-visible outline, so the new Clear/retry controls are visibly focusable too. |
| Accessible names and roles | All 15 owner navigation links expose one accessible link role and name. The active route uses `aria-current="page"`. Icon-only decoration is `aria-hidden`. |
| Contrast, measured from computed colors at 320 px | Active navigation 10.35:1; inactive navigation 8.69:1; body text 13.35:1. All exceed 4.5:1. |
| Touch target | All 15 navigation targets are at least 44 px tall (the links use 48 px minimum). |
| Horizontal overflow | All 15 routes were checked at 320, 768, 1024 and 1440 px. Document, body and navigation widths stayed within the viewport. A pre-existing 12 px Bookkeeping card overflow at 320 px was fixed with `min-w-0` on the two affected grid cards because #56 now makes that page a primary destination. |
| Loading, empty and error states | Reports has an explicit owner-only state; printers has loading, empty, error-with-retry and populated states; sales has loading, no-match, error and cleared-filter states; stock keeps its existing loading/error/movement-history states. |

## Screen-size results

`qa29-verify.cjs` ran 15 routes at 320, 768, 1024 and 1440 px: 60 route/width
checks, plus four width-specific navigation focus and target-size checks. All 82
checks passed, including contrast, accessible names, role visibility, printer
metadata, sale-reference search and the cashier dead-end checks. The existing
`qa5-verify.cjs` regression suite also passed 37 checks at the same widths.

## Real-user status

`PENDING — requires real users`.

The Playwright walkthrough is synthetic. A real cashier and owner should repeat
these tasks on the staging deployment:

1. As a cashier, sign in, open `/reports` directly, and record how long the
   owner-only message takes and whether a report request appears in the network
   panel.
2. As a cashier, open Stock and confirm no History action appears; as an owner,
   open one History panel and confirm the ledger is readable.
3. As an owner, register a printer through the API, open Printers, and compare
   the listed metadata with the Android device's paired printer.
4. As an owner, find a receipt by a partial reference from a support call, then
   clear the search and confirm the normal date-filtered list returns.
5. Record the number of clicks from sign-in to Promotions, Purchasing,
   Bookkeeping, Shifts, Attendance, Online ordering, Customers, Audit search and
   Permissions. Target: one click from any back-office page.

No real-user timing, error-rate or support-incident claim is made here. The #28
support-incident baseline remains `PENDING — requires real usage`.

## Limits

- Playwright ran against the Next.js development server on port 3001 and the
  staging API on port 4100. Development compilation explains cold-load variance;
  production timing needs a separate measurement.
- The Android app was not changed. Printer discovery, pairing and physical
  printing remain on the device and are still `PENDING — requires printer model
  + Android device`.
- Navigation role visibility is a client UX aid. API authorization remains the
  enforcement point and was not weakened.
- No customer data, payment credential, production database or real operator
  identity was used.
