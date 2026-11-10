#!/usr/bin/env bash
# Repeatable synthetic-data smoke verification for the Phase 1 MVP.
# Requires: bash, curl, jq, python3, a running API and the seeded synthetic database.
set -euo pipefail

API_BASE="${API_BASE:-http://localhost:4000/v1}"
OWNER_EMAIL="${OWNER_EMAIL:-owner@example.test}"
OWNER_PASSWORD="${OWNER_PASSWORD:-modern-pos-demo-password}"
OUTLET="${OUTLET_ID:-00000000-0000-4000-8000-000000000002}"
DEVICE="${DEVICE_ID:-$(python3 -c 'import uuid;print(uuid.uuid4())')}"
STAMP="$(date -u +%H%M%S)"

uuid() { python3 -c 'import uuid;print(uuid.uuid4())'; }
fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }
json() { jq -c "$@"; }

TOKEN=$(curl -fsS -X POST "$API_BASE/auth/mobile/login" \
  -H 'Content-Type: application/json' \
  -d "$(jq -cn --arg e "$OWNER_EMAIL" --arg p "$OWNER_PASSWORD" --arg d "$DEVICE" \
    '{email:$e,password:$p,deviceId:$d}')" | jq -r .accessToken)
[ -n "$TOKEN" ] && [ "$TOKEN" != "null" ] || fail "owner login"
AUTH=(-H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json')
pass "owner login"

CATEGORY=$(curl -fsS -X POST "$API_BASE/outlets/$OUTLET/categories" "${AUTH[@]}" \
  -d "$(jq -cn --arg n "MV $STAMP" '{name:$n}')")
CATEGORY_ID=$(jq -r .id <<<"$CATEGORY")
[ -n "$CATEGORY_ID" ] && [ "$CATEGORY_ID" != "null" ] || fail "category create"
pass "category create"

STOCK=$(curl -fsS -X POST "$API_BASE/outlets/$OUTLET/stock" "${AUTH[@]}" \
  -d "$(jq -cn --arg n "MV Beans $STAMP" \
    '{name:$n,baseUnit:"g",quantityScale:0,reorderThreshold:"10"}')")
STOCK_ID=$(jq -r .id <<<"$STOCK")
[ -n "$STOCK_ID" ] && [ "$STOCK_ID" != "null" ] || fail "stock item create"
curl -fsS -X POST "$API_BASE/outlets/$OUTLET/stock/opening-balances" "${AUTH[@]}" \
  -H "Idempotency-Key: $(uuid)" \
  -d "$(jq -cn --arg s "$STOCK_ID" '{stockItemId:$s,quantity:"100",reason:"MV opening balance"}')" >/dev/null
pass "stock item and opening balance"

MENU=$(curl -fsS -X POST "$API_BASE/outlets/$OUTLET/menu" "${AUTH[@]}" \
  -d "$(jq -cn --arg n "MV Item $STAMP" --arg c "$CATEGORY_ID" \
    '{name:$n,description:"Synthetic MVP smoke item",categoryId:$c,variants:[{name:"Default",priceMinor:2500,stockPolicy:"TRACKED"}]}')")
VARIANT_ID=$(jq -r '.variants[0].id' <<<"$MENU")
[ -n "$VARIANT_ID" ] && [ "$VARIANT_ID" != "null" ] || fail "menu create"
curl -fsS -X PUT "$API_BASE/outlets/$OUTLET/variants/$VARIANT_ID/recipe" "${AUTH[@]}" \
  -d "$(jq -cn --arg s "$STOCK_ID" \
    '{expectedVersion:0,lines:[{stockItemId:$s,quantityPerSaleUnit:"5"}]}')" >/dev/null
pass "tracked menu item and recipe"

ORDER=$(curl -fsS -X POST "$API_BASE/outlets/$OUTLET/orders" "${AUTH[@]}" \
  -H "Idempotency-Key: $(uuid)" \
  -d "$(jq -cn --arg d "$DEVICE" --arg v "$VARIANT_ID" \
    '{deviceId:$d,lines:[{variantId:$v,quantity:2}]}')")
ORDER_ID=$(jq -r .id <<<"$ORDER")
[ -n "$ORDER_ID" ] && [ "$ORDER_ID" != "null" ] || fail "order create"
QUOTE=$(curl -fsS -X POST "$API_BASE/outlets/$OUTLET/orders/$ORDER_ID/quotes" "${AUTH[@]}" \
  -d '{"orderVersion":1}')
QUOTE_ID=$(jq -r .id <<<"$QUOTE")
TOTAL=$(jq -r .totals.totalMinor <<<"$QUOTE")
[ -n "$QUOTE_ID" ] && [ "$QUOTE_ID" != "null" ] || fail "quote create"
pass "order and quote"

FINALIZE_KEY=$(uuid)
FINALIZE_BODY=$(jq -cn --arg d "$DEVICE" --arg o "$ORDER_ID" --arg q "$QUOTE_ID" --argjson t "$TOTAL" \
  '{deviceId:$d,orderId:$o,quoteId:$q,payment:{kind:"CASH",amountMinor:$t,tenderedMinor:($t+1000)}}')
FINALIZE_CODE=$(curl -sS -o /tmp/mv-finalize.json -w '%{http_code}' \
  -X POST "$API_BASE/outlets/$OUTLET/sales/finalize" "${AUTH[@]}" \
  -H "Idempotency-Key: $FINALIZE_KEY" -d "$FINALIZE_BODY")
[ "$FINALIZE_CODE" = "200" ] || fail "finalize status $FINALIZE_CODE: $(cat /tmp/mv-finalize.json)"
SALE_ID=$(jq -r .sale.id /tmp/mv-finalize.json)
SALE_REF=$(jq -r .sale.reference /tmp/mv-finalize.json)
[ -n "$SALE_ID" ] && [ "$SALE_ID" != "null" ] || fail "sale id"
pass "finalize returned completed sale $SALE_REF"

REPLAY_CODE=$(curl -sS -o /tmp/mv-replay.json -w '%{http_code}' \
  -X POST "$API_BASE/outlets/$OUTLET/sales/finalize" "${AUTH[@]}" \
  -H "Idempotency-Key: $FINALIZE_KEY" -d "$FINALIZE_BODY")
[ "$REPLAY_CODE" = "200" ] || fail "duplicate finalize status $REPLAY_CODE"
[ "$(jq -r .replayed /tmp/mv-replay.json)" = "true" ] || fail "duplicate finalize not replayed"
[ "$(jq -r .sale.id /tmp/mv-replay.json)" = "$SALE_ID" ] || fail "duplicate finalize changed sale"
pass "duplicate finalize replayed the same sale without a second sale"

RECOVERY_CODE=$(curl -sS -o /tmp/mv-recovery.json -w '%{http_code}' \
  "$API_BASE/outlets/$OUTLET/checkout-requests/$FINALIZE_KEY?deviceId=$DEVICE" \
  -H "Authorization: Bearer $TOKEN")
[ "$RECOVERY_CODE" = "200" ] || fail "checkout recovery status $RECOVERY_CODE"
[ "$(jq -r .sale.id /tmp/mv-recovery.json)" = "$SALE_ID" ] || fail "recovery changed sale"
pass "retained checkout key recovered the same sale"

MOVEMENTS=$(curl -fsS "$API_BASE/outlets/$OUTLET/stock/$STOCK_ID/movements" \
  -H "Authorization: Bearer $TOKEN")
SALE_MOVEMENTS=$(jq --arg ref "$SALE_REF" '[.items[] | select(.type=="SALE" and .sourceReference==$ref)] | length' <<<"$MOVEMENTS")
[ "$SALE_MOVEMENTS" = "1" ] || fail "expected one SALE movement, got $SALE_MOVEMENTS"
DELTA=$(jq -r --arg ref "$SALE_REF" '.items[] | select(.type=="SALE" and .sourceReference==$ref) | .delta' <<<"$MOVEMENTS")
[ "$DELTA" = "-10" ] || fail "expected stock delta -10, got $DELTA"
BALANCE=$(curl -fsS "$API_BASE/outlets/$OUTLET/stock?search=MV%20Beans" \
  -H "Authorization: Bearer $TOKEN" | jq -r --arg id "$STOCK_ID" '.items[] | select(.id==$id) | .quantity')
[ "$BALANCE" = "90" ] || fail "expected balance 90, got $BALANCE"
pass "one SALE movement of -10 and balance 90"

DAY=$(TZ=Asia/Jakarta date +%F)
REPORT=$(curl -fsS "$API_BASE/outlets/$OUTLET/reports/daily?from=$DAY&to=$DAY" \
  -H "Authorization: Bearer $TOKEN")
jq -e --arg ref "$SALE_REF" '.saleCount >= 1' <<<"$REPORT" >/dev/null || fail "report sale count"
pass "daily report covers local day $DAY"

NO_REASON_CODE=$(curl -sS -o /tmp/mv-no-reason.json -w '%{http_code}' \
  -X POST "$API_BASE/outlets/$OUTLET/sales/$SALE_ID/reversals" "${AUTH[@]}" \
  -H "Idempotency-Key: $(uuid)" -d '{"reason":"","restock":[]}')
[ "$NO_REASON_CODE" = "400" ] || fail "empty reversal reason status $NO_REASON_CODE"
pass "empty reversal reason rejected with 400"

REVERSAL_KEY=$(uuid)
REVERSAL_BODY=$(jq -cn --arg s "$STOCK_ID" \
  '{reason:"MVP smoke reversal",restock:[{stockItemId:$s,quantity:"5"}]}')
REVERSAL_CODE=$(curl -sS -o /tmp/mv-reversal.json -w '%{http_code}' \
  -X POST "$API_BASE/outlets/$OUTLET/sales/$SALE_ID/reversals" "${AUTH[@]}" \
  -H "Idempotency-Key: $REVERSAL_KEY" -d "$REVERSAL_BODY")
[ "$REVERSAL_CODE" = "201" ] || fail "reversal status $REVERSAL_CODE: $(cat /tmp/mv-reversal.json)"
REVERSAL_REPLAY_CODE=$(curl -sS -o /tmp/mv-reversal-replay.json -w '%{http_code}' \
  -X POST "$API_BASE/outlets/$OUTLET/sales/$SALE_ID/reversals" "${AUTH[@]}" \
  -H "Idempotency-Key: $REVERSAL_KEY" -d "$REVERSAL_BODY")
[ "$REVERSAL_REPLAY_CODE" = "201" ] || fail "reversal replay status $REVERSAL_REPLAY_CODE"
cmp -s /tmp/mv-reversal.json /tmp/mv-reversal-replay.json || fail "reversal replay body differs"
SECOND_CODE=$(curl -sS -o /tmp/mv-reversal-second.json -w '%{http_code}' \
  -X POST "$API_BASE/outlets/$OUTLET/sales/$SALE_ID/reversals" "${AUTH[@]}" \
  -H "Idempotency-Key: $(uuid)" -d '{"reason":"second key must fail","restock":[]}')
[ "$SECOND_CODE" = "409" ] || fail "second reversal key status $SECOND_CODE"
pass "reversal is explicit, idempotent and one-per-sale"

echo "MVP SMOKE PASSED: sale=$SALE_REF total=$TOTAL stock_balance=$BALANCE day=$DAY"
