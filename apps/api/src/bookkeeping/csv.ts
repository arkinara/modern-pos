const FORMULA_TRIGGER = /^[=+\-@\t\r]/;

function quote(value: string): string {
  const safe = FORMULA_TRIGGER.test(value) ? `'${value}` : value;
  return /[",\r\n]/.test(safe) ? `"${safe.replaceAll('"', '""')}"` : safe;
}

function cell(value: string | number | null): string {
  return value === null ? '' : typeof value === 'number' ? String(value) : quote(value);
}

/** RFC 4180 CSV with CRLF line endings and formula-safe text cells. */
export function buildCsv(
  headers: readonly string[],
  rows: readonly (readonly (string | number | null)[])[],
): string {
  const lines = [headers.map(cell).join(',')];

  for (const row of rows) {
    lines.push(row.map(cell).join(','));
  }

  return `${lines.join('\r\n')}\r\n`;
}
