-- Login is by email alone, so the normalized email must be unique across tenants.
DROP INDEX "users_businessId_email_key";

CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
