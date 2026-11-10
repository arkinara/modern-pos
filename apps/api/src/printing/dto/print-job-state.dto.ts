import { IsIn, IsInt, IsOptional, IsString, IsUUID, MaxLength, Min } from 'class-validator';

export const PRINT_JOB_STATES = ['QUEUED', 'SENDING', 'SENT', 'FAILED', 'UNKNOWN'] as const;
export type PrintJobStateValue = (typeof PRINT_JOB_STATES)[number];

export class PrintJobStateDto {
  @IsUUID()
  deviceId!: string;

  @IsString()
  @IsIn(PRINT_JOB_STATES)
  state!: PrintJobStateValue;

  @IsInt()
  @Min(0)
  attempts!: number;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  lastError!: string | null;
}
