import { Body, Controller, Get, HttpCode, Param, Patch, Post, Query } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CatalogService,
  type CategoryResponse,
  type MenuPageResponse,
  type MenuResponse,
  type VariantResponse,
} from './catalog.service';
import { CatalogArchiveDto } from './dto/catalog-archive.dto';
import { CategoryCreateDto } from './dto/category-create.dto';
import { MenuCreateDto } from './dto/menu-create.dto';
import { MenuListQueryDto } from './dto/menu-list-query.dto';
import { MenuUpdateDto } from './dto/menu-update.dto';
import { MenuVariantUpdateDto } from './dto/menu-variant-update.dto';

@Controller('outlets/:outletId')
export class CatalogController {
  constructor(private readonly catalog: CatalogService) {}

  @Get('categories')
  listCategories(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<CategoryResponse[]> {
    return this.catalog.listCategories(outletId, user);
  }

  @Roles(Role.OWNER)
  @Post('categories')
  createCategory(
    @Param('outletId') outletId: string,
    @Body() dto: CategoryCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<CategoryResponse> {
    return this.catalog.createCategory(outletId, dto, user);
  }

  @Get('menu')
  listMenu(
    @Param('outletId') outletId: string,
    @Query() query: MenuListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<MenuPageResponse> {
    return this.catalog.listMenu(outletId, query, user);
  }

  @Roles(Role.OWNER)
  @Post('menu')
  createMenu(
    @Param('outletId') outletId: string,
    @Body() dto: MenuCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<MenuResponse> {
    return this.catalog.createMenu(outletId, dto, user);
  }

  @Roles(Role.OWNER)
  @Patch('menu/:menuId')
  updateMenu(
    @Param('outletId') outletId: string,
    @Param('menuId') menuId: string,
    @Body() dto: MenuUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<MenuResponse> {
    return this.catalog.updateMenu(outletId, menuId, dto, user);
  }

  @Roles(Role.OWNER)
  @Post('menu/:menuId/archive')
  @HttpCode(204)
  archiveMenu(
    @Param('outletId') outletId: string,
    @Param('menuId') menuId: string,
    @Body() dto: CatalogArchiveDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<void> {
    return this.catalog.archiveMenu(outletId, menuId, dto, user);
  }

  @Roles(Role.OWNER)
  @Patch('variants/:variantId')
  updateVariant(
    @Param('outletId') outletId: string,
    @Param('variantId') variantId: string,
    @Body() dto: MenuVariantUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<VariantResponse> {
    return this.catalog.updateVariant(outletId, variantId, dto, user);
  }
}
