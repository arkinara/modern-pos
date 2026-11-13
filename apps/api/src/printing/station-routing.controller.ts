import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  Param,
  Patch,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { StationJobListQueryDto } from './dto/station-job-list-query.dto';
import { StationJobStateDto } from './dto/station-job-write.dto';
import { StationJobWriteDto } from './dto/station-job-write.dto';
import { StationRoutingWriteDto } from './dto/station-routing-write.dto';
import { StationUpdateDto } from './dto/station-update.dto';
import { StationWriteDto } from './dto/station-write.dto';
import {
  StationJobPageResponse,
  StationJobResponse,
  StationResponse,
  StationRouteResponse,
  StationRoutingService,
} from './station-routing.service';

@Controller('outlets/:outletId')
export class StationRoutingController {
  constructor(private readonly stations: StationRoutingService) {}

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('stations')
  listStations(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationResponse[]> {
    return this.stations.listStations(outletId, user);
  }

  @Roles(Role.OWNER)
  @Post('stations')
  @HttpCode(201)
  createStation(
    @Param('outletId') outletId: string,
    @Body() dto: StationWriteDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationResponse> {
    return this.stations.createStation(outletId, dto, user);
  }

  @Roles(Role.OWNER)
  @Put('stations/:stationId')
  updateStation(
    @Param('outletId') outletId: string,
    @Param('stationId') stationId: string,
    @Body() dto: StationUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationResponse> {
    return this.stations.updateStation(outletId, stationId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('station-routing')
  listRoutes(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationRouteResponse[]> {
    return this.stations.listRoutes(outletId, user);
  }

  @Roles(Role.OWNER)
  @Put('station-routing')
  replaceRoutes(
    @Param('outletId') outletId: string,
    @Body() dto: StationRoutingWriteDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationRouteResponse[]> {
    return this.stations.replaceRoutes(outletId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('orders/:orderId/station-jobs')
  @HttpCode(201)
  createJobs(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: StationJobWriteDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationJobResponse[]> {
    return this.stations.createJobs(outletId, orderId, key, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('stations/:stationId/jobs')
  listJobs(
    @Param('outletId') outletId: string,
    @Param('stationId') stationId: string,
    @Query() query: StationJobListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationJobPageResponse> {
    return this.stations.listJobs(outletId, stationId, query, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Patch('station-jobs/:jobId')
  updateJobState(
    @Param('outletId') outletId: string,
    @Param('jobId') jobId: string,
    @Body() dto: StationJobStateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationJobResponse> {
    return this.stations.updateJobState(outletId, jobId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('station-jobs/:jobId/retry')
  retryJob(
    @Param('outletId') outletId: string,
    @Param('jobId') jobId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationJobResponse> {
    return this.stations.retryJob(outletId, jobId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('station-jobs/:jobId/reprints')
  @HttpCode(201)
  reprintJob(
    @Param('outletId') outletId: string,
    @Param('jobId') jobId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StationJobResponse> {
    return this.stations.reprintJob(outletId, jobId, key, user);
  }
}
