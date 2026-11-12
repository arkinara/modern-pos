import { Module } from '@nestjs/common';
import { MockPaymentProviderService } from './mock-payment-provider.service';
import { PaymentConfigService } from './payment-config.service';
import { PaymentWebhookController, PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { QrisPaymentProviderService } from './qris-payment-provider.service';
import { SandboxProviderController } from './sandbox-provider.controller';

@Module({
  controllers: [PaymentsController, PaymentWebhookController, SandboxProviderController],
  providers: [
    PaymentConfigService,
    MockPaymentProviderService,
    QrisPaymentProviderService,
    PaymentsService,
  ],
  exports: [PaymentsService, PaymentConfigService],
})
export class PaymentsModule {}
