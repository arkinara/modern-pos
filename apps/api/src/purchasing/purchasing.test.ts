import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Prisma, PurchaseOrderState, Role } from '@prisma/client';
import { PERMISSIONS, permissionsForRole } from '../auth/permissions';
import {
  assertPositiveQuantity,
  assertRepresentableQuantity,
  convertReceiptQuantity,
  countVariance,
  nextPurchaseOrderState,
  PurchasingUnit,
  transferInTransitQuantity,
} from './purchasing.logic';

const DECIMAL = (value: string): Prisma.Decimal => new Prisma.Decimal(value);

function status(error: unknown): number | null {
  return error instanceof HttpException ? error.getStatus() : null;
}

function code(error: unknown): string | null {
  return error instanceof HttpException
    ? ((error.getResponse() as { code?: string }).code ?? null)
    : null;
}

test('supplier units convert exactly into base units', () => {
  const result = convertReceiptQuantity(DECIMAL('12'), '4', PurchasingUnit.SUPPLIER, 0);
  assert.equal(result.baseDelta.toFixed(0), '48');
  assert.equal(result.supplierDelta.toFixed(6), '4.000000');
});

test('base units convert exactly back into supplier units', () => {
  const result = convertReceiptQuantity(DECIMAL('1000'), '1500', PurchasingUnit.BASE, 0);
  assert.equal(result.baseDelta.toFixed(0), '1500');
  assert.equal(result.supplierDelta.toFixed(6), '1.500000');
});

test('base quantity that does not divide into supplier packs is rejected, never rounded', () => {
  assert.throws(
    () => convertReceiptQuantity(DECIMAL('12'), '5', PurchasingUnit.BASE, 6),
    (error: unknown) => status(error) === 422 && code(error) === 'CONVERSION_NOT_EXACT',
  );
});

test('supplier quantity whose base result exceeds item precision is rejected', () => {
  assert.throws(
    () => convertReceiptQuantity(DECIMAL('0.333333'), '1', PurchasingUnit.SUPPLIER, 2),
    (error: unknown) => status(error) === 422 && code(error) === 'QUANTITY_PRECISION_EXCEEDED',
  );
});

test('conversion overflow is rejected before any ledger write', () => {
  assert.throws(
    () => convertReceiptQuantity(DECIMAL('1000000'), '10000000000000', PurchasingUnit.SUPPLIER, 6),
    (error: unknown) => status(error) === 422 && code(error) === 'CONVERSION_OVERFLOW',
  );
});

test('zero and negative receipt quantities are rejected with 400', () => {
  assert.throws(
    () => convertReceiptQuantity(DECIMAL('12'), '0', PurchasingUnit.SUPPLIER, 0),
    (error: unknown) => status(error) === 400,
  );
  assert.throws(
    () => assertPositiveQuantity(DECIMAL('-1'), 'quantity'),
    (error: unknown) => status(error) === 400,
  );
});

test('quantity precision guard rejects non-representable values', () => {
  assert.throws(
    () => assertRepresentableQuantity(DECIMAL('1.5'), 0, 'quantity'),
    (error: unknown) => status(error) === 422,
  );
  assert.doesNotThrow(() => assertRepresentableQuantity(DECIMAL('1.5'), 2, 'quantity'));
});

test('purchase order state only closes when every line is fully received', () => {
  assert.equal(
    nextPurchaseOrderState([
      { orderedBaseQuantity: DECIMAL('10'), receivedBaseQuantity: DECIMAL('4') },
      { orderedBaseQuantity: DECIMAL('2'), receivedBaseQuantity: DECIMAL('2') },
    ]),
    PurchaseOrderState.PARTIALLY_RECEIVED,
  );
  assert.equal(
    nextPurchaseOrderState([
      { orderedBaseQuantity: DECIMAL('10'), receivedBaseQuantity: DECIMAL('10') },
      { orderedBaseQuantity: DECIMAL('2'), receivedBaseQuantity: DECIMAL('2') },
    ]),
    PurchaseOrderState.RECEIVED,
  );
});

test('in-transit quantity is dispatched minus received and returns to zero after full receive', () => {
  assert.equal(
    transferInTransitQuantity([
      { dispatchedQuantity: DECIMAL('10'), receivedQuantity: DECIMAL('4') },
      { dispatchedQuantity: DECIMAL('2'), receivedQuantity: DECIMAL('2') },
    ]).toFixed(0),
    '6',
  );
  assert.equal(
    transferInTransitQuantity([
      { dispatchedQuantity: DECIMAL('10'), receivedQuantity: DECIMAL('10') },
      { dispatchedQuantity: DECIMAL('2'), receivedQuantity: DECIMAL('2') },
    ]).toFixed(0),
    '0',
  );
});

test('count variance is counted minus the system snapshot', () => {
  assert.equal(countVariance(DECIMAL('10'), DECIMAL('7')).toFixed(0), '-3');
  assert.equal(countVariance(DECIMAL('10'), DECIMAL('12')).toFixed(0), '2');
  assert.equal(countVariance(DECIMAL('10'), DECIMAL('10')).toFixed(0), '0');
});

test('cashier can record counts and waste but cannot manage transfer or purchasing records', () => {
  const cashier = permissionsForRole(Role.CASHIER);
  assert.ok(cashier.includes(PERMISSIONS.STOCK_COUNT));
  assert.ok(cashier.includes(PERMISSIONS.STOCK_WASTE));
  assert.ok(!cashier.includes(PERMISSIONS.STOCK_TRANSFER));
  assert.ok(!cashier.includes(PERMISSIONS.PURCHASE_ORDER_MANAGE));
  assert.ok(!cashier.includes(PERMISSIONS.SUPPLIER_MANAGE));
});

test('owner holds every purchasing and stock-control permission', () => {
  const owner = permissionsForRole(Role.OWNER);
  for (const permission of [
    PERMISSIONS.STOCK_COUNT,
    PERMISSIONS.STOCK_WASTE,
    PERMISSIONS.STOCK_TRANSFER,
    PERMISSIONS.PURCHASE_ORDER_MANAGE,
    PERMISSIONS.SUPPLIER_MANAGE,
  ]) {
    assert.ok(owner.includes(permission));
  }
});
