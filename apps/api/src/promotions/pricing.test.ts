import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { PromotionKind, PromotionStacking } from '@prisma/client';
import { applyPromotions, type PromotionRule } from './pricing';

const NOW = new Date('2026-06-01T12:00:00.000Z');
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';

function rule(overrides: Partial<PromotionRule> = {}): PromotionRule {
  return {
    id: '00000000-0000-4000-8000-0000000000f1',
    name: 'Ten percent',
    kind: PromotionKind.PERCENTAGE,
    percentageBps: 1000,
    amountMinor: null,
    minBasketMinor: 0n,
    startsAt: null,
    endsAt: null,
    active: true,
    stacking: PromotionStacking.EXCLUSIVE,
    priority: 0,
    outletId: null,
    eligibility: {},
    ...overrides,
  };
}

function lines(unitPriceMinor = 1000n, quantity = 1) {
  return [
    {
      variantId: '00000000-0000-4000-8000-000000000040',
      menuItemId: '00000000-0000-4000-8000-000000000030',
      unitPriceMinor,
      quantity,
    },
  ];
}

function codeOf(error: unknown): string | undefined {
  return error instanceof HttpException
    ? (error.getResponse() as { code: string }).code
    : undefined;
}

test('percentage promotion rounds half-up at exactly half a minor unit', () => {
  const result = applyPromotions(lines(1n, 10), [rule({ percentageBps: 500 })], {
    outletId: OUTLET_ID,
    now: NOW,
    customerEmail: null,
  });

  assert.equal(result.discountMinor, 1n);
  assert.equal(result.promotions[0]?.discountMinor, 1n);
});

test('fixed promotion larger than the basket is capped and never negative', () => {
  const result = applyPromotions(
    lines(1000n, 1),
    [
      rule({
        kind: PromotionKind.FIXED_AMOUNT,
        percentageBps: null,
        amountMinor: 5000n,
      }),
    ],
    { outletId: OUTLET_ID, now: NOW, customerEmail: null },
  );

  assert.equal(result.discountMinor, 1000n);
});

test('date window boundaries are inclusive and one millisecond outside is rejected', () => {
  const bounded = rule({
    startsAt: NOW,
    endsAt: NOW,
  });

  assert.equal(
    applyPromotions(lines(), [bounded], {
      outletId: OUTLET_ID,
      now: NOW,
      customerEmail: null,
    }).discountMinor,
    100n,
  );

  assert.throws(
    () =>
      applyPromotions(lines(), [bounded], {
        outletId: OUTLET_ID,
        now: new Date(NOW.getTime() - 1),
        customerEmail: null,
      }),
    (error: unknown) => codeOf(error) === 'PROMOTION_NOT_ELIGIBLE',
  );

  assert.throws(
    () =>
      applyPromotions(lines(), [bounded], {
        outletId: OUTLET_ID,
        now: new Date(NOW.getTime() + 1),
        customerEmail: null,
      }),
    (error: unknown) => codeOf(error) === 'PROMOTION_NOT_ELIGIBLE',
  );
});

test('eligibility checks outlet, item, variant, customer and minimum basket', () => {
  const rules = [
    rule({ id: 'a', outletId: OUTLET_ID, eligibility: { variantIds: [lines()[0]!.variantId] } }),
    rule({
      id: 'a',
      outletId: OUTLET_ID,
      eligibility: { menuItemIds: [lines()[0]!.menuItemId] },
    }),
    rule({
      id: 'a',
      outletId: OUTLET_ID,
      eligibility: { customerEmails: ['guest@example.test'] },
    }),
  ];

  assert.equal(
    applyPromotions(lines(), [rules[0]!], {
      outletId: OUTLET_ID,
      now: NOW,
      customerEmail: null,
    }).discountMinor,
    100n,
  );

  for (const candidate of [
    rule({ outletId: '00000000-0000-4000-8000-000000000099' }),
    rule({ eligibility: { variantIds: ['00000000-0000-4000-8000-0000000000aa'] } }),
    rule({ eligibility: { customerEmails: ['other@example.test'] } }),
    rule({ minBasketMinor: 2000n }),
  ]) {
    assert.throws(
      () =>
        applyPromotions(lines(1000n, 1), [candidate], {
          outletId: OUTLET_ID,
          now: NOW,
          customerEmail: 'guest@example.test',
        }),
      (error: unknown) => codeOf(error) === 'PROMOTION_NOT_ELIGIBLE',
    );
  }
});

test('stacking allows only compatible promotions and rejects duplicate ids', () => {
  const stackable = rule({
    id: 'stack',
    percentageBps: 500,
    stacking: PromotionStacking.STACKABLE,
  });
  const exclusive = rule({ id: 'exclusive', amountMinor: 100n, kind: PromotionKind.FIXED_AMOUNT, percentageBps: null });

  const combined = applyPromotions(lines(1000n, 1), [stackable, { ...stackable, id: 'stack2' }], {
    outletId: OUTLET_ID,
    now: NOW,
    customerEmail: null,
  });

  assert.equal(combined.discountMinor, 100n);

  assert.throws(
    () =>
      applyPromotions(lines(), [exclusive, stackable], {
        outletId: OUTLET_ID,
        now: NOW,
        customerEmail: null,
      }),
    (error: unknown) => codeOf(error) === 'PROMOTION_STACK_NOT_ALLOWED',
  );

  assert.throws(
    () =>
      applyPromotions(lines(), [stackable, { ...stackable }], {
        outletId: OUTLET_ID,
        now: NOW,
        customerEmail: null,
      }),
    (error: unknown) => codeOf(error) === 'PROMOTION_DUPLICATE',
  );
});

test('an inactive promotion is rejected', () => {
  assert.throws(
    () =>
      applyPromotions(lines(), [rule({ active: false })], {
        outletId: OUTLET_ID,
        now: NOW,
        customerEmail: null,
      }),
    (error: unknown) => codeOf(error) === 'PROMOTION_NOT_ELIGIBLE',
  );
});
