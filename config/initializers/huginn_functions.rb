# The schema (db/schema.rb) declares GIN indexes that depend on the IMMUTABLE
# helper functions f_unaccent/f_tsvector, but those functions are only created
# by migrations. When bootstrapping a fresh database (db:migrate / db:prepare)
# Rails loads db/schema.rb before running pending migrations, so the extensions
# and functions must already exist. This initializer idempotently guarantees
# them on boot.
ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS unaccent")

ActiveRecord::Base.connection.execute(<<~SQL)
  CREATE OR REPLACE FUNCTION public.f_unaccent(text)
  RETURNS text AS $$
    SELECT public.unaccent('public.unaccent', $1)
  $$
  LANGUAGE sql IMMUTABLE PARALLEL SAFE;
SQL

ActiveRecord::Base.connection.execute(<<~SQL)
  CREATE OR REPLACE FUNCTION public.f_tsvector(text)
  RETURNS tsvector AS $$
    SELECT to_tsvector('portuguese', $1)
  $$
  LANGUAGE sql IMMUTABLE PARALLEL SAFE;
SQL
