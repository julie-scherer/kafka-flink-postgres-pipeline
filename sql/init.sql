-- (optional) Check if the role exists before creating it
-- DO $$BEGIN
--   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'postgres') THEN
--     CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres';
--     ALTER ROLE postgres CREATEDB;
--   END IF;
-- END$$;

-- Check if the table exists before creating it
CREATE TABLE processed_events (
    url VARCHAR
);

SELECT url FROM processed_events;
