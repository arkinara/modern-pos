import { Injectable } from '@nestjs/common';
import { Role, StockPolicy } from '@prisma/client';
import type { Prisma } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { CategoryCreateDto } from './dto/category-create.dto';
import { CatalogArchiveDto } from './dto/catalog-archive.dto';
import { MenuCreateDto } from './dto/menu-create.dto';
import { MenuListQueryDto } from './dto/menu-list-query.dto';
import { MenuUpdateDto } from './dto/menu-update.dto';
import { MenuVariantUpdateDto } from './dto/menu-variant-update.dto';

export interface CategoryResponse {
  id: string;
  name: string;
  version: number;
  archived: boolean;
}

export interface VariantResponse {
  id: string;
  name: string;
  priceMinor: number;
  stockPolicy: StockPolicy;
  revision: number;
  enabled: boolean;
  availableUnits: number | null;
}

export interface MenuResponse {
  id: string;
  name: string;
  description: string;
  categoryId: string;
  revision: number;
  archived: boolean;
  variants: VariantResponse[];
}

export interface MenuPageResponse {
  items: MenuResponse[];
  nextCursor: string | null;
}

type MenuRecord = Prisma.MenuItemGetPayload<{
  include: {
    variants: {
      include: { outletMenus: { select: { outletId: true; enabled: true } } };
    };
  };
}>;

type VariantRecord = Prisma.MenuVariantGetPayload<{
  include: { outletMenus: { select: { outletId: true; enabled: true } } };
}>;

@Injectable()
export class CatalogService {
  constructor(private readonly prisma: PrismaService) {}

  async listCategories(outletId: string, user: AuthenticatedUser): Promise<CategoryResponse[]> {
    await this.requireOutlet(outletId, user.businessId);

    const categories = await this.prisma.category.findMany({
      where: { businessId: user.businessId },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });

    return categories.map((category) => ({
      id: category.id,
      name: category.name,
      version: 1,
      archived: category.archivedAt !== null,
    }));
  }

  async createCategory(
    outletId: string,
    dto: CategoryCreateDto,
    user: AuthenticatedUser,
  ): Promise<CategoryResponse> {
    await this.requireOutlet(outletId, user.businessId);

    const last = await this.prisma.category.findFirst({
      where: { businessId: user.businessId },
      orderBy: { sortOrder: 'desc' },
      select: { sortOrder: true },
    });

    const category = await this.prisma.category.create({
      data: {
        businessId: user.businessId,
        name: dto.name,
        sortOrder: (last?.sortOrder ?? 0) + 10,
      },
    });

    return {
      id: category.id,
      name: category.name,
      version: 1,
      archived: category.archivedAt !== null,
    };
  }

  async listMenu(
    outletId: string,
    query: MenuListQueryDto,
    user: AuthenticatedUser,
  ): Promise<MenuPageResponse> {
    await this.requireOutlet(outletId, user.businessId);

    const isOwner = user.role === Role.OWNER;
    const limit = query.limit ?? 25;
    const search = query.search?.trim();

    const variantScope = isOwner
      ? { outletMenus: { some: { outletId } } }
      : { active: true, outletMenus: { some: { outletId, enabled: true } } };

    const where: Prisma.MenuItemWhereInput = {
      businessId: user.businessId,
      variants: { some: variantScope },
      ...(isOwner
        ? {}
        : {
            archivedAt: null,
            category: { archivedAt: null },
          }),
      ...(search
        ? {
            OR: [
              { name: { contains: search, mode: 'insensitive' as const } },
              { description: { contains: search, mode: 'insensitive' as const } },
            ],
          }
        : {}),
    };

    const rows = await this.prisma.menuItem.findMany({
      where,
      orderBy: [{ id: 'asc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: {
        variants: {
          where: variantScope,
          orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
          include: {
            outletMenus: { where: { outletId }, select: { outletId: true, enabled: true } },
          },
        },
      },
    });

    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => this.toMenu(row)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async createMenu(
    outletId: string,
    dto: MenuCreateDto,
    user: AuthenticatedUser,
  ): Promise<MenuResponse> {
    await this.requireOutlet(outletId, user.businessId);

    const menuId = await this.prisma.$transaction(async (tx) => {
      await this.requireCategory(tx, dto.categoryId, user.businessId);

      const menu = await tx.menuItem.create({
        data: {
          businessId: user.businessId,
          categoryId: dto.categoryId,
          name: dto.name,
          description: dto.description,
        },
      });

      for (const variant of dto.variants) {
        const created = await tx.menuVariant.create({
          data: {
            menuItemId: menu.id,
            name: variant.name,
            priceMinor: BigInt(variant.priceMinor),
            stockPolicy: variant.stockPolicy,
          },
        });

        await tx.outletMenu.create({
          data: { outletId, variantId: created.id, enabled: true },
        });
      }

      return menu.id;
    });

    return this.menuByIdOrThrow(outletId, menuId, user);
  }

  async updateMenu(
    outletId: string,
    menuId: string,
    dto: MenuUpdateDto,
    user: AuthenticatedUser,
  ): Promise<MenuResponse> {
    await this.requireOutlet(outletId, user.businessId);

    await this.prisma.$transaction(async (tx) => {
      const existing = await this.findMenuInOutlet(tx, outletId, menuId, user.businessId);

      if (existing.revision !== dto.revision) {
        throw apiError(409, 'VERSION_CONFLICT', 'Menu was changed by another request');
      }

      await this.requireCategory(tx, dto.categoryId, user.businessId);

      const updated = await tx.menuItem.updateMany({
        where: { id: menuId, businessId: user.businessId, revision: dto.revision },
        data: {
          name: dto.name,
          description: dto.description,
          categoryId: dto.categoryId,
          revision: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Menu was changed by another request');
      }
    });

    return this.menuByIdOrThrow(outletId, menuId, user);
  }

  async archiveMenu(
    outletId: string,
    menuId: string,
    dto: CatalogArchiveDto,
    user: AuthenticatedUser,
  ): Promise<void> {
    await this.requireOutlet(outletId, user.businessId);

    await this.prisma.$transaction(async (tx) => {
      const existing = await this.findMenuInOutlet(tx, outletId, menuId, user.businessId);

      if (existing.revision !== dto.revision) {
        throw apiError(409, 'VERSION_CONFLICT', 'Menu was changed by another request');
      }

      if (existing.archivedAt !== null) {
        return;
      }

      const updated = await tx.menuItem.updateMany({
        where: {
          id: menuId,
          businessId: user.businessId,
          revision: dto.revision,
          archivedAt: null,
        },
        data: { archivedAt: new Date(), revision: { increment: 1 } },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Menu was changed by another request');
      }
    });
  }

  async updateVariant(
    outletId: string,
    variantId: string,
    dto: MenuVariantUpdateDto,
    user: AuthenticatedUser,
  ): Promise<VariantResponse> {
    await this.requireOutlet(outletId, user.businessId);

    await this.prisma.$transaction(async (tx) => {
      const existing = await tx.menuVariant.findFirst({
        where: {
          id: variantId,
          menuItem: { businessId: user.businessId },
          outletMenus: { some: { outletId } },
        },
        select: { id: true, revision: true },
      });

      if (!existing) {
        throw apiError(404, 'NOT_FOUND', 'Variant not found');
      }

      if (existing.revision !== dto.revision) {
        throw apiError(409, 'VERSION_CONFLICT', 'Variant was changed by another request');
      }

      const updated = await tx.menuVariant.updateMany({
        where: { id: variantId, revision: dto.revision },
        data: {
          name: dto.name,
          priceMinor: BigInt(dto.priceMinor),
          stockPolicy: dto.stockPolicy,
          active: dto.enabled,
          revision: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Variant was changed by another request');
      }
    });

    const variant = await this.prisma.menuVariant.findFirst({
      where: {
        id: variantId,
        menuItem: { businessId: user.businessId },
        outletMenus: { some: { outletId } },
      },
      include: { outletMenus: { where: { outletId }, select: { outletId: true, enabled: true } } },
    });

    if (!variant) {
      throw apiError(404, 'NOT_FOUND', 'Variant not found');
    }

    return this.toVariant(variant);
  }

  private async requireOutlet(outletId: string, businessId: string): Promise<void> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId },
      select: { id: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }

  private async requireCategory(
    tx: Prisma.TransactionClient,
    categoryId: string,
    businessId: string,
  ): Promise<void> {
    const category = await tx.category.findFirst({
      where: { id: categoryId, businessId, archivedAt: null },
      select: { id: true },
    });

    if (!category) {
      throw apiError(404, 'NOT_FOUND', 'Category not found');
    }
  }

  private async findMenuInOutlet(
    tx: Prisma.TransactionClient,
    outletId: string,
    menuId: string,
    businessId: string,
  ): Promise<{ id: string; revision: number; archivedAt: Date | null }> {
    const menu = await tx.menuItem.findFirst({
      where: {
        id: menuId,
        businessId,
        variants: { some: { outletMenus: { some: { outletId } } } },
      },
      select: { id: true, revision: true, archivedAt: true },
    });

    if (!menu) {
      throw apiError(404, 'NOT_FOUND', 'Menu not found');
    }

    return menu;
  }

  private async menuByIdOrThrow(
    outletId: string,
    menuId: string,
    user: AuthenticatedUser,
  ): Promise<MenuResponse> {
    const menu = await this.prisma.menuItem.findFirst({
      where: {
        id: menuId,
        businessId: user.businessId,
        variants: { some: { outletMenus: { some: { outletId } } } },
      },
      include: {
        variants: {
          where: { outletMenus: { some: { outletId } } },
          orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
          include: {
            outletMenus: { where: { outletId }, select: { outletId: true, enabled: true } },
          },
        },
      },
    });

    if (!menu) {
      throw apiError(404, 'NOT_FOUND', 'Menu not found');
    }

    return this.toMenu(menu);
  }

  private toMenu(menu: MenuRecord): MenuResponse {
    return {
      id: menu.id,
      name: menu.name,
      description: menu.description,
      categoryId: menu.categoryId,
      revision: menu.revision,
      archived: menu.archivedAt !== null,
      variants: menu.variants.map((variant) => this.toVariant(variant)),
    };
  }

  private toVariant(variant: VariantRecord): VariantResponse {
    return {
      id: variant.id,
      name: variant.name,
      priceMinor: Number(variant.priceMinor),
      stockPolicy: variant.stockPolicy,
      revision: variant.revision,
      enabled: variant.active,
      availableUnits: null,
    };
  }
}
