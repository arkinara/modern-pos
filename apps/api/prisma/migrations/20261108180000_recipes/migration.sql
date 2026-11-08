-- CreateTable
CREATE TABLE "recipe_versions" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "variantId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "effectiveAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "recipe_versions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recipe_lines" (
    "id" UUID NOT NULL,
    "recipeVersionId" UUID NOT NULL,
    "stockItemId" UUID NOT NULL,
    "quantityPerSaleUnit" DECIMAL(20,6) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "recipe_lines_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "recipe_versions_businessId_idx" ON "recipe_versions"("businessId");

-- CreateIndex
CREATE INDEX "recipe_versions_outletId_variantId_version_idx" ON "recipe_versions"("outletId", "variantId", "version");

-- CreateIndex
CREATE UNIQUE INDEX "recipe_versions_variantId_outletId_version_key" ON "recipe_versions"("variantId", "outletId", "version");

-- CreateIndex
CREATE INDEX "recipe_lines_stockItemId_idx" ON "recipe_lines"("stockItemId");

-- CreateIndex
CREATE UNIQUE INDEX "recipe_lines_recipeVersionId_stockItemId_key" ON "recipe_lines"("recipeVersionId", "stockItemId");

-- AddForeignKey
ALTER TABLE "recipe_versions" ADD CONSTRAINT "recipe_versions_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recipe_versions" ADD CONSTRAINT "recipe_versions_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recipe_versions" ADD CONSTRAINT "recipe_versions_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "menu_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recipe_lines" ADD CONSTRAINT "recipe_lines_recipeVersionId_fkey" FOREIGN KEY ("recipeVersionId") REFERENCES "recipe_versions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recipe_lines" ADD CONSTRAINT "recipe_lines_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Domain invariants enforced by the database as well as the service layer.
ALTER TABLE "recipe_versions"
    ADD CONSTRAINT "recipe_versions_version_check" CHECK ("version" >= 1);

ALTER TABLE "recipe_lines"
    ADD CONSTRAINT "recipe_lines_quantity_check" CHECK ("quantityPerSaleUnit" > 0);

-- Published recipes are immutable: rows may be inserted but never changed or removed.
CREATE OR REPLACE FUNCTION modern_pos_recipe_append_only()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'published recipes are append-only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER recipe_versions_no_update
    BEFORE UPDATE ON "recipe_versions"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_recipe_append_only();

CREATE TRIGGER recipe_versions_no_delete
    BEFORE DELETE ON "recipe_versions"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_recipe_append_only();

CREATE TRIGGER recipe_lines_no_update
    BEFORE UPDATE ON "recipe_lines"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_recipe_append_only();

CREATE TRIGGER recipe_lines_no_delete
    BEFORE DELETE ON "recipe_lines"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_recipe_append_only();
