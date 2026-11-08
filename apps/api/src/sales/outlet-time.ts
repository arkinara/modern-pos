import { apiError } from '../common/api-error';

interface DateParts {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
}

function zonedParts(date: Date, timeZone: string): DateParts {
  const formatter = new Intl.DateTimeFormat('en-US', {
    timeZone,
    hour12: false,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  });

  const parts = formatter.formatToParts(date);
  const read = (type: Intl.DateTimeFormatPartTypes): number =>
    Number(parts.find((part) => part.type === type)?.value ?? 0);

  return {
    year: read('year'),
    month: read('month'),
    day: read('day'),
    hour: read('hour') === 24 ? 0 : read('hour'),
    minute: read('minute'),
    second: read('second'),
  };
}

function offsetMilliseconds(date: Date, timeZone: string): number {
  const parts = zonedParts(date, timeZone);
  const asUtc = Date.UTC(
    parts.year,
    parts.month - 1,
    parts.day,
    parts.hour,
    parts.minute,
    parts.second,
  );
  const truncated = Math.floor(date.getTime() / 1000) * 1000;
  return asUtc - truncated;
}

export function parseDateOnly(value: string): { year: number; month: number; day: number } {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);

  if (!match) {
    throw apiError(400, 'VALIDATION_ERROR', 'Date must use the YYYY-MM-DD format');
  }

  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const probe = new Date(Date.UTC(year, month - 1, day));

  if (
    probe.getUTCFullYear() !== year ||
    probe.getUTCMonth() !== month - 1 ||
    probe.getUTCDate() !== day
  ) {
    throw apiError(400, 'VALIDATION_ERROR', 'Date is not a valid calendar date');
  }

  return { year, month, day };
}

export function addDays(
  date: { year: number; month: number; day: number },
  days: number,
): { year: number; month: number; day: number } {
  const next = new Date(Date.UTC(date.year, date.month - 1, date.day + days));
  return {
    year: next.getUTCFullYear(),
    month: next.getUTCMonth() + 1,
    day: next.getUTCDate(),
  };
}

export function startOfDayUtc(
  date: { year: number; month: number; day: number },
  timeZone: string,
): Date {
  const guess = Date.UTC(date.year, date.month - 1, date.day);
  const firstOffset = offsetMilliseconds(new Date(guess), timeZone);
  const first = guess - firstOffset;
  const secondOffset = offsetMilliseconds(new Date(first), timeZone);
  return new Date(guess - secondOffset);
}

export function localDateRangeUtc(
  from: string | undefined,
  to: string | undefined,
  timeZone: string,
): { gte?: Date; lt?: Date } {
  const range: { gte?: Date; lt?: Date } = {};

  if (from) {
    range.gte = startOfDayUtc(parseDateOnly(from), timeZone);
  }

  if (to) {
    range.lt = startOfDayUtc(addDays(parseDateOnly(to), 1), timeZone);
  }

  if (range.gte && range.lt && range.gte.getTime() >= range.lt.getTime()) {
    throw apiError(400, 'VALIDATION_ERROR', 'from must be on or before to');
  }

  return range;
}
