import { Module } from '@nestjs/common';
import { ChannelConfigService } from './channel-config.service';
import { ChannelRegistryService } from './channel-registry.service';
import { ChannelWebhookController, OrderingController } from './ordering.controller';
import { OrderingService } from './ordering.service';

@Module({
  controllers: [OrderingController, ChannelWebhookController],
  providers: [ChannelConfigService, ChannelRegistryService, OrderingService],
  exports: [OrderingService, ChannelConfigService],
})
export class OrderingModule {}
