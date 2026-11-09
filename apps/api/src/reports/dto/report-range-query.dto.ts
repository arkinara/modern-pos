import { IsString, Matches } from 'class-validator';

export const REPORTS_DATE_ONLY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

export class ReportRangeQueryDto {
  @IsString()
  @Matches(REPORTS_DATE_ONLY_PATTERN)
  from!: string;

  @IsString()
  @Matches(REPORTS_DATE_ONLY_PATTERN)
  to!: string;
}
