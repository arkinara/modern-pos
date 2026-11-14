import { Body, Controller, Get, HttpCode, Param, Post, Put, Query } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CustomerCreateDto,
  CustomerListQueryDto,
  RetentionPolicyUpdateDto,
} from './dto/customer.dto';
import {
  CustomerListResponse,
  CustomerResponse,
  CustomersService,
  PurgeResponse,
  RetentionPolicyResponse,
} from './customers.service';

@Roles(Role.OWNER)
@Controller('outlets/:outletId/customers')
export class CustomersController {
  constructor(private readonly customers: CustomersService) {}

  @Get()
  list(
    @Param('outletId') outletId: string,
    @Query() query: CustomerListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<CustomerListResponse> {
    return this.customers.list(outletId, query, user);
  }

  @Post()
  @HttpCode(201)
  create(
    @Param('outletId') outletId: string,
    @Body() dto: CustomerCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<CustomerResponse> {
    return this.customers.create(outletId, dto, user);
  }

  @Get('retention-policy')
  getPolicy(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<RetentionPolicyResponse> {
    return this.customers.getPolicy(outletId, user);
  }

  @Put('retention-policy')
  updatePolicy(
    @Param('outletId') outletId: string,
    @Body() dto: RetentionPolicyUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<RetentionPolicyResponse> {
    return this.customers.updatePolicy(outletId, dto, user);
  }

  @Post('purge')
  @HttpCode(200)
  purge(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PurgeResponse> {
    return this.customers.purge(outletId, user);
  }

  @Get(':customerId')
  get(
    @Param('outletId') outletId: string,
    @Param('customerId') customerId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<CustomerResponse> {
    return this.customers.get(outletId, customerId, user);
  }
}
