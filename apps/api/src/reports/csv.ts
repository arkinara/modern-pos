export interface CsvSaleRow {
  reference: string;
  completedAtUtc: string;
  completedAtLocal: string;
  timezone: string;
  state: string;
  currency: string;
  currencyExponent: number;
  itemName: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: number;
  lineSubtotalMinor: number;
  saleSubtotalMinor: number;
  saleServiceMinor: number;
  saleTaxMinor: number;
  saleTotalMinor: number;
  paymentKind: string | null;
  paymentStatus: string | null;
  paymentAmountMinor: number | null;
  tenderedMinor: number | null;
  changeMinor: number | null;
  paymentReference: string | null;
  rowType: 'SALE' | 'REVERSAL' | 'REFUND';
  reversalReason: string | null;
}

export const CSV_COLUMNS = [
  'reference',
  'completedAtUtc',
  'completedAtLocal',
  'timezone',
  'state',
  'currency',
  'currencyExponent',
  'itemName',
  'variantName',
  'quantity',
  'unitPriceMinor',
  'lineSubtotalMinor',
  'saleSubtotalMinor',
  'saleServiceMinor',
  'saleTaxMinor',
  'saleTotalMinor',
  'paymentKind',
  'paymentStatus',
  'paymentAmountMinor',
  'tenderedMinor',
  'changeMinor',
  'paymentReference',
  'rowType',
  'reversalReason',
] as const;

const FORMULA_TRIGGER = /^[=+\-@\t\r]/;

/**
 * Spreadsheet applications treat these leading characters as formulas.
 * Prefix a single quote so an imported file never executes item text.
 */
function formulaSafe(value: string): string {
  return FORMULA_TRIGGER.test(value) ? `'${value}` : value;
}

function quote(value: string): string {
  const safe = formulaSafe(value);

  if (/[",\r\n]/.test(safe)) {
    return `"${safe.replaceAll('"', '""')}"`;
  }

  return safe;
}

function cell(value: string | number | null): string {
  return value === null ? '' : typeof value === 'number' ? String(value) : quote(value);
}

export function toCsv(rows: CsvSaleRow[]): string {
  const header = CSV_COLUMNS.join(',');
  const body = rows.map((row) =>
    [
      row.reference,
      row.completedAtUtc,
      row.completedAtLocal,
      row.timezone,
      row.state,
      row.currency,
      row.currencyExponent,
      row.itemName,
      row.variantName,
      row.quantity,
      row.unitPriceMinor,
      row.lineSubtotalMinor,
      row.saleSubtotalMinor,
      row.saleServiceMinor,
      row.saleTaxMinor,
      row.saleTotalMinor,
      row.paymentKind,
      row.paymentStatus,
      row.paymentAmountMinor,
      row.tenderedMinor,
      row.changeMinor,
      row.paymentReference,
      row.rowType,
      row.reversalReason,
    ]
      .map(cell)
      .join(','),
  );

  return `${[header, ...body].join('\r\n')}\r\n`;
}
