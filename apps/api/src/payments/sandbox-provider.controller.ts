import { Body, Controller, Get, HttpCode, Param, Post } from '@nestjs/common';
import { PaymentProvider } from '@prisma/client';
import { apiError } from '../common/api-error';
import { Public } from '../common/decorators/public.decorator';
import { SandboxEventDto, SandboxPaymentCreateDto } from './dto/sandbox-event.dto';
import { MockPaymentProviderService } from './mock-payment-provider.service';
import { PaymentConfigService } from './payment-config.service';

@Controller('sandbox/provider')
export class SandboxProviderController {
  constructor(
    private readonly config: PaymentConfigService,
    private readonly provider: MockPaymentProviderService,
  ) {}

  private assertEnabled(): void {
    if (this.config.provider !== PaymentProvider.MOCK) {
      throw apiError(404, 'NOT_FOUND', 'Sandbox provider endpoints are disabled');
    }
  }

  @Public()
  @Post('payments')
  @HttpCode(201)
  async create(@Body() dto: SandboxPaymentCreateDto): Promise<Record<string, unknown>> {
    this.assertEnabled();
    const payment = await this.provider.createPayment({
      idempotencyKey: dto.idempotencyKey,
      amountMinor: BigInt(dto.amountMinor),
      currency: dto.currency,
    });
    return this.serialize(payment);
  }

  @Public()
  @Get('payments/:providerRef')
  async read(@Param('providerRef') providerRef: string): Promise<Record<string, unknown>> {
    this.assertEnabled();
    const payment = await this.provider.fetchPayment(providerRef);
    return this.serialize(payment);
  }

  @Public()
  @Post('payments/:providerRef/events')
  @HttpCode(201)
  async event(
    @Param('providerRef') providerRef: string,
    @Body() dto: SandboxEventDto,
  ): Promise<Record<string, unknown>> {
    this.assertEnabled();
    return this.provider.createEvent(providerRef, dto.type, dto.eventId);
  }

  private serialize(payment: {
    providerRef: string;
    status: string;
    amountMinor: bigint;
    currency: string;
    qrPayload?: string | null;
    refundedMinor?: bigint;
  }): Record<string, unknown> {
    return {
      providerRef: payment.providerRef,
      status: payment.status,
      amountMinor: payment.amountMinor.toString(),
      currency: payment.currency,
      qrPayload: payment.qrPayload ?? null,
      refundedMinor: (payment.refundedMinor ?? 0n).toString(),
    };
  }
}
