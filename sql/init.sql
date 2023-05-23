-- (optional) Check if the role exists before creating it
DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles WHERE rolname = 'postgres') THEN
      ALTER ROLE postgres WITH PASSWORD 'postgres';
   ELSE
      CREATE ROLE postgres LOGIN PASSWORD 'postgres';
   END IF;
   ALTER ROLE postgres CREATEDB;
END
$do$;

-- Check if the table exists before creating it
CREATE TABLE processed_events (
    url VARCHAR
);

SELECT url FROM processed_events;
