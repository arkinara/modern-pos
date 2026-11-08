import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { RecipeWriteDto } from './dto/recipe-write.dto';
import { RecipeService, type RecipeResponse } from './recipe.service';

@Controller('outlets/:outletId/variants/:variantId/recipe')
export class RecipeController {
  constructor(private readonly recipes: RecipeService) {}

  @Roles(Role.OWNER)
  @Get()
  get(
    @Param('outletId') outletId: string,
    @Param('variantId') variantId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<RecipeResponse> {
    return this.recipes.get(outletId, variantId, user);
  }

  @Roles(Role.OWNER)
  @Put()
  publish(
    @Param('outletId') outletId: string,
    @Param('variantId') variantId: string,
    @Body() dto: RecipeWriteDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<RecipeResponse> {
    return this.recipes.publish(outletId, variantId, dto, user);
  }
}
