import { Body, Controller, Get, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PERMISSIONS } from '../auth/permissions';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/permissions.decorator';
import {
  PurchaseOrderCreateDto,
  PurchaseOrderListQueryDto,
  PurchaseOrderReceiptDto,
  StockCountCreateDto,
  StockCountListQueryDto,
  SupplierCreateDto,
  SupplierListQueryDto,
  TransferCreateDto,
  TransferListQueryDto,
  TransferReceiveDto,
  WasteCreateDto,
  WasteListQueryDto,
} from './dto/purchasing.dto';
import {
  PurchaseOrderPageResponse,
  PurchaseOrderReceiptResponse,
  PurchaseOrderResponse,
  PurchasingService,
  StockCountPageResponse,
  StockCountResponse,
  SupplierPageResponse,
  SupplierResponse,
  TransferMutationResponse,
  TransferPageResponse,
  TransferResponse,
  WastePageResponse,
  WasteResponse,
} from './purchasing.service';

@Controller('outlets/:outletId')
export class PurchasingController {
  constructor(private readonly purchasing: PurchasingService) {}

  @RequirePermission(PERMISSIONS.SUPPLIER_MANAGE)
  @Get('suppliers')
  listSuppliers(
    @Param('outletId') outletId: string,
    @Query() query: SupplierListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<SupplierPageResponse> {
    return this.purchasing.listSuppliers(outletId, query, user);
  }

  @RequirePermission(PERMISSIONS.SUPPLIER_MANAGE)
  @Post('suppliers')
  createSupplier(
    @Param('outletId') outletId: string,
    @Body() dto: SupplierCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<SupplierResponse> {
    return this.purchasing.createSupplier(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.PURCHASE_ORDER_MANAGE)
  @Get('purchase-orders')
  listPurchaseOrders(
    @Param('outletId') outletId: string,
    @Query() query: PurchaseOrderListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PurchaseOrderPageResponse> {
    return this.purchasing.listPurchaseOrders(outletId, query, user);
  }

  @RequirePermission(PERMISSIONS.PURCHASE_ORDER_MANAGE)
  @Post('purchase-orders')
  createPurchaseOrder(
    @Param('outletId') outletId: string,
    @Body() dto: PurchaseOrderCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PurchaseOrderResponse> {
    return this.purchasing.createPurchaseOrder(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.PURCHASE_ORDER_MANAGE)
  @Post('purchase-orders/:purchaseOrderId/receipts')
  receivePurchaseOrder(
    @Param('outletId') outletId: string,
    @Param('purchaseOrderId') purchaseOrderId: string,
    @Body() dto: PurchaseOrderReceiptDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PurchaseOrderReceiptResponse> {
    return this.purchasing.receivePurchaseOrder(outletId, purchaseOrderId, dto, user);
  }

  @RequirePermission(PERMISSIONS.PURCHASE_ORDER_MANAGE)
  @Post('purchase-orders/:purchaseOrderId/cancel')
  @HttpCode(200)
  cancelPurchaseOrder(
    @Param('outletId') outletId: string,
    @Param('purchaseOrderId') purchaseOrderId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PurchaseOrderResponse> {
    return this.purchasing.cancelPurchaseOrder(outletId, purchaseOrderId, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_COUNT)
  @Get('stock-counts')
  listStockCounts(
    @Param('outletId') outletId: string,
    @Query() query: StockCountListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StockCountPageResponse> {
    return this.purchasing.listStockCounts(outletId, query, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_COUNT)
  @Post('stock-counts')
  createStockCount(
    @Param('outletId') outletId: string,
    @Body() dto: StockCountCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StockCountResponse> {
    return this.purchasing.createStockCount(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_WASTE)
  @Get('stock-wastes')
  listWaste(
    @Param('outletId') outletId: string,
    @Query() query: WasteListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<WastePageResponse> {
    return this.purchasing.listWaste(outletId, query, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_WASTE)
  @Post('stock-wastes')
  recordWaste(
    @Param('outletId') outletId: string,
    @Body() dto: WasteCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<WasteResponse> {
    return this.purchasing.recordWaste(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_TRANSFER)
  @Get('transfers')
  listTransfers(
    @Param('outletId') outletId: string,
    @Query() query: TransferListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<TransferPageResponse> {
    return this.purchasing.listTransfers(outletId, query, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_TRANSFER)
  @Post('transfers')
  createTransfer(
    @Param('outletId') outletId: string,
    @Body() dto: TransferCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<TransferResponse> {
    return this.purchasing.createTransfer(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_TRANSFER)
  @Post('transfers/:transferId/dispatch')
  @HttpCode(201)
  dispatchTransfer(
    @Param('outletId') outletId: string,
    @Param('transferId') transferId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<TransferMutationResponse> {
    return this.purchasing.dispatchTransfer(outletId, transferId, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_TRANSFER)
  @Post('transfers/:transferId/receive')
  @HttpCode(201)
  receiveTransfer(
    @Param('outletId') outletId: string,
    @Param('transferId') transferId: string,
    @Body() dto: TransferReceiveDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<TransferMutationResponse> {
    return this.purchasing.receiveTransfer(outletId, transferId, dto, user);
  }

  @RequirePermission(PERMISSIONS.STOCK_TRANSFER)
  @Post('transfers/:transferId/cancel')
  @HttpCode(200)
  cancelTransfer(
    @Param('outletId') outletId: string,
    @Param('transferId') transferId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<TransferResponse> {
    return this.purchasing.cancelTransfer(outletId, transferId, user);
  }
}
