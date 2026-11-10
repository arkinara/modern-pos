# Migration, backup and restore

Status: migration deploy, backup, destroy and restore were executed against a scratch
database on 2026-11-10. This document contains the commands and the observed row-count
comparison. No production database was touched.

## Scope

- Prisma migrations for schema changes.
- Logical PostgreSQL backup with `pg_dump` custom format.
- Restore into a clean database with `pg_restore`.
- Row-count verification after restore.
- Explicit limits: no point-in-time recovery, no off-host copy, no retention schedule,
  no encryption-at-rest procedure in this ticket.

## Migration deploy

Run migrations before starting an API build that expects the new schema:

```bash
pnpm --filter @modern-pos/api migrate:deploy
```

Observed on this VPS after all Phase 1 migrations were already applied:

```text
Datasource "db": PostgreSQL database "modern_pos", schema "public" at "localhost:5432"
11 migrations found in prisma/migrations
No pending migrations to apply.
```

For a fresh staging database, run the same command after
`docker compose up -d postgres`.

## Backup

The PostgreSQL service in `docker-compose.yml` is named `postgres`. From the repository
root:

```bash
mkdir -p <backup-directory>
docker compose exec -T postgres pg_dump \
  -U pos -d modern_pos -Fc \
  > <backup-directory>/modern_pos-$(date -u +%Y%m%dT%H%M%SZ).dump
```

`-Fc` writes the custom or directory-restorable format and compresses it. Keep backups
outside the Docker volume and outside the application host in a real deployment.

Verify the dump can be listed:

```bash
docker compose exec -T postgres pg_restore -l < <backup-directory>/modern-pos.dump | head
```

If the API is taking writes, `pg_dump` produces a consistent snapshot but the restore
will not include transactions committed after the dump started. A production backup
policy must define the acceptable recovery point objective.

## Restore into a clean database

The following is the procedure used for the dry run. It is destructive only for the
target database named in `createdb` / `dropdb`.

```bash
SCRATCH=modern_pos_restore
DUMP=/tmp/modern_pos.dump

# 1. Dump the source.
docker compose exec -T postgres pg_dump -U pos -d modern_pos -Fc > "$DUMP"

# 2. Remove any previous scratch database.
docker compose exec -T postgres dropdb -U pos --if-exists "$SCRATCH"

# 3. Create an empty target.
docker compose exec -T postgres createdb -U pos "$SCRATCH"

# 4. Restore the dump into the empty target.
docker compose exec -T postgres pg_restore \
  -U pos -d "$SCRATCH" --no-owner --no-privileges \
  < "$DUMP"

# 5. Verify row counts (see the comparison below).
```

To restore the primary database in an emergency, stop API and web writers first,
take a fresh backup, then restore into the primary database name. Do not run the
primary restore while the API is connected.

## Executed dry run

Environment: Ubuntu 24.04 arm64, PostgreSQL 17.6 in Docker, synthetic demo data only.
The dry-run database was `modern_pos_t18_restore`. The real `modern_pos` database was
the source and was never dropped or modified by the dry run.

Commands actually run:

```bash
SRC=modern_pos
SCRATCH=modern_pos_t18_restore
DUMP=/tmp/t18-modern_pos.dump

docker exec modern-pos-postgres dropdb -U pos --if-exists "$SCRATCH"
docker exec modern-pos-postgres createdb -U pos "$SCRATCH"
docker exec modern-pos-postgres pg_dump -U pos -d "$SRC" -Fc -f /tmp/t18-modern_pos.dump
docker cp modern-pos-postgres:/tmp/t18-modern_pos.dump "$DUMP"
docker exec modern-pos-postgres dropdb -U pos "$SCRATCH"
docker exec modern-pos-postgres createdb -U pos "$SCRATCH"
docker cp "$DUMP" modern-pos-postgres:/tmp/t18-modern_pos.dump
docker exec modern-pos-postgres pg_restore -U pos -d "$SCRATCH" \
  --no-owner --no-privileges /tmp/t18-modern_pos.dump
```

Observed output:

```text
scratch_created=modern_pos_t18_restore
-rw-r--r-- 1 root root 119213 Nov 10 19:09 /tmp/t18-modern_pos.dump
scratch_after_drop=0
restore_exit=0
ROW_COUNTS_MATCH=yes
scratch_cleaned=0
```

Row-count comparison after restore:

```text
businesses           source=2    restored=2    MATCH
categories           source=3    restored=3    MATCH
checkout_requests    source=16   restored=16   MATCH
menu_items           source=4    restored=4    MATCH
menu_variants        source=5    restored=5    MATCH
order_lines          source=25   restored=25   MATCH
orders               source=23   restored=23   MATCH
outlets              source=3    restored=3    MATCH
payment_records      source=18   restored=18   MATCH
print_jobs           source=4    restored=4    MATCH
printers             source=2    restored=2    MATCH
quotes               source=21   restored=21   MATCH
recipe_lines         source=8    restored=8    MATCH
recipe_versions      source=4    restored=4    MATCH
sale_lines           source=20   restored=20   MATCH
sale_reversals       source=8    restored=8    MATCH
sales                source=18   restored=18   MATCH
stock_balances       source=8    restored=8    MATCH
stock_items          source=5    restored=5    MATCH
stock_movements      source=41   restored=41   MATCH
users                source=6    restored=6    MATCH
```

The counts were taken after the ticket #18 verification sales, reversals and print-job
mirror rows were created. They are synthetic verification data, not production data.

## Restore verification checklist

After any restore:

```bash
docker compose exec -T postgres psql -U pos -d <database> -c \
  'select count(*) from sales; select count(*) from stock_movements; select count(*) from users;'
```

Then:

1. Start the API and call `GET /health`.
2. Sign in as an owner.
3. Open `/sales` and `/reports` for a known synthetic day.
4. Confirm one sale reference and one stock balance match the pre-backup values.
5. Record the dump file name, restore time, database name and operator.

## Known limits

- No automated scheduled backup is implemented.
- No off-host backup is configured.
- No restore drill has been run on managed production infrastructure.
- A logical restore does not prove point-in-time recovery.
- The dry run used container-local paths; a production host needs a separate durable
  backup target.
