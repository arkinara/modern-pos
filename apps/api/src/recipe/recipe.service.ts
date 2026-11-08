import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { RecipeWriteDto } from './dto/recipe-write.dto';

export interface RecipeLineResponse {
  stockItemId: string;
  quantityPerSaleUnit: string;
}

export interface RecipeResponse {
  id: string;
  variantId: string;
  version: number;
  lines: RecipeLineResponse[];
}

type DbClient = Prisma.TransactionClient | PrismaService;

interface StockItemScale {
  id: string;
  quantityScale: number;
}

const ZERO = new Prisma.Decimal(0);

function isUniqueViolation(error: unknown): boolean {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

@Injectable()
export class RecipeService {
  constructor(private readonly prisma: PrismaService) {}

  async get(outletId: string, variantId: string, user: AuthenticatedUser): Promise<RecipeResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    await this.requireVariant(this.prisma, outletId, user.businessId, variantId);

    const recipe = await this.prisma.recipeVersion.findFirst({
      where: { outletId, variantId, businessId: user.businessId },
      orderBy: { version: 'desc' },
      include: {
        lines: {
          orderBy: { stockItemId: 'asc' },
          include: { stockItem: { select: { quantityScale: true } } },
        },
      },
    });

    if (!recipe) {
      throw apiError(404, 'NOT_FOUND', 'Recipe not found');
    }

    return this.toRecipe(recipe);
  }

  async publish(
    outletId: string,
    variantId: string,
    dto: RecipeWriteDto,
    user: AuthenticatedUser,
  ): Promise<RecipeResponse> {
    try {
      return await this.prisma.$transaction((tx) =>
        this.publishInTransaction(tx, outletId, variantId, dto, user),
      );
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw apiError(
          409,
          'VERSION_CONFLICT',
          'Another recipe version was published first; reload the latest recipe and retry',
        );
      }

      throw error;
    }
  }

  private async publishInTransaction(
    tx: Prisma.TransactionClient,
    outletId: string,
    variantId: string,
    dto: RecipeWriteDto,
    user: AuthenticatedUser,
  ): Promise<RecipeResponse> {
    await this.requireOutlet(tx, outletId, user.businessId);
    await this.requireVariant(tx, outletId, user.businessId, variantId);

    const latest = await tx.recipeVersion.findFirst({
      where: { outletId, variantId, businessId: user.businessId },
      orderBy: { version: 'desc' },
      select: { version: true },
    });
    const currentVersion = latest?.version ?? 0;

    if (dto.expectedVersion !== currentVersion) {
      throw apiError(
        409,
        'VERSION_CONFLICT',
        'Recipe was changed by another request; reload the latest version and retry',
      );
    }

    const duplicate = this.findDuplicateStockItem(dto.lines.map((line) => line.stockItemId));

    if (duplicate) {
      throw apiError(400, 'VALIDATION_ERROR', 'A stock item can appear only once per recipe', {
        details: { stockItemId: duplicate },
      });
    }

    const items = await this.requireStockItems(
      tx,
      user.businessId,
      dto.lines.map((line) => line.stockItemId),
    );

    const normalizedLines = dto.lines.map((line) => {
      const quantity = new Prisma.Decimal(line.quantityPerSaleUnit);
      const item = items.get(line.stockItemId.toLowerCase());

      if (!item) {
        throw apiError(404, 'NOT_FOUND', 'Stock item not found');
      }

      if (quantity.lessThanOrEqualTo(ZERO)) {
        throw apiError(400, 'VALIDATION_ERROR', 'quantityPerSaleUnit must be greater than zero');
      }

      if (quantity.decimalPlaces() > item.quantityScale) {
        throw apiError(
          400,
          'VALIDATION_ERROR',
          'quantityPerSaleUnit has more decimals than the stock item quantityScale allows',
          { details: { stockItemId: item.id } },
        );
      }

      return {
        stockItemId: item.id,
        quantityPerSaleUnit: quantity,
      };
    });

    const recipe = await tx.recipeVersion.create({
      data: {
        businessId: user.businessId,
        outletId,
        variantId,
        version: currentVersion + 1,
        lines: {
          create: normalizedLines,
        },
      },
      include: {
        lines: {
          orderBy: { stockItemId: 'asc' },
          include: { stockItem: { select: { quantityScale: true } } },
        },
      },
    });

    return this.toRecipe(recipe);
  }

  private findDuplicateStockItem(ids: string[]): string | null {
    const seen = new Set<string>();

    for (const id of ids) {
      const normalized = id.toLowerCase();
      if (seen.has(normalized)) {
        return id;
      }
      seen.add(normalized);
    }

    return null;
  }

  private async requireStockItems(
    client: DbClient,
    businessId: string,
    ids: string[],
  ): Promise<Map<string, StockItemScale>> {
    const items = await client.stockItem.findMany({
      where: { id: { in: ids }, businessId },
      select: { id: true, quantityScale: true },
    });

    return new Map(items.map((item) => [item.id.toLowerCase(), item]));
  }

  private async requireOutlet(
    client: DbClient,
    outletId: string,
    businessId: string,
  ): Promise<void> {
    const outlet = await client.outlet.findFirst({
      where: { id: outletId, businessId },
      select: { id: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }

  private async requireVariant(
    client: DbClient,
    outletId: string,
    businessId: string,
    variantId: string,
  ): Promise<void> {
    const variant = await client.menuVariant.findFirst({
      where: {
        id: variantId,
        menuItem: { businessId },
        outletMenus: { some: { outletId } },
      },
      select: { id: true },
    });

    if (!variant) {
      throw apiError(404, 'NOT_FOUND', 'Variant not found');
    }
  }

  private toRecipe(recipe: {
    id: string;
    variantId: string;
    version: number;
    lines: {
      stockItemId: string;
      quantityPerSaleUnit: Prisma.Decimal;
      stockItem: { quantityScale: number };
    }[];
  }): RecipeResponse {
    return {
      id: recipe.id,
      variantId: recipe.variantId,
      version: recipe.version,
      lines: recipe.lines.map((line) => ({
        stockItemId: line.stockItemId,
        quantityPerSaleUnit: line.quantityPerSaleUnit.toFixed(line.stockItem.quantityScale),
      })),
    };
  }
}
