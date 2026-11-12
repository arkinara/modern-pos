import { Transform } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';
import { trim } from '../../common/transforms';
import { MAX_SAFE_MINOR_NUMBER } from '../../sales/money';

export class SandboxEventDto {
  @IsIn(['payment.pending', 'payment.succeeded', 'payment.failed'])
  type!: 'payment.pending' | 'payment.succeeded' | 'payment.failed';

  @IsOptional()
  @Transform(trim)
  @IsString()
  eventId?: string;
}

export class SandboxPaymentCreateDto {
  @IsUUID()
  idempotencyKey!: string;

  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  amountMinor!: number;

  @IsString()
  currency!: string;
}
