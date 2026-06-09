# Root Cause: "No API key found in request" from Supabase

## Error

```json
{"message":"No API key found in request","hint":"No `apikey` request header or url param was found."}
```

## Actual cause

Any table created with raw `psql` (or a migration that doesn't include `GRANT` statements) has **no PostgreSQL-level grants** for the `anon` / `authenticated` roles.

PostgREST enforces role permissions **before** evaluating RLS policies. When neither role has `USAGE` on the schema or `SELECT`/`INSERT` on the table, PostgREST rejects the request and returns the misleading "No API key found" error instead of "permission denied".

The `venues` table was created via raw `psql`, so every request to it was rejected at the PostgREST auth layer regardless of the valid session token being present in the request.

## Fix

```sql
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE <table> TO authenticated;
GRANT SELECT ON TABLE <table> TO anon;
```

## Why courts/bookings/slots didn't have this problem

Tables created through the Supabase migration system (or Supabase Studio) automatically receive the necessary grants. Only tables created directly via `psql` as the `postgres` superuser are missing them.

## Prevention

Always include `GRANT` statements when writing raw SQL migrations for new tables:

```sql
CREATE TABLE venues (...);

-- Required — without these, PostgREST rejects all requests
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE venues TO authenticated;
GRANT SELECT ON TABLE venues TO anon;
```
