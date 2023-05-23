-- (optional) Check if the role exists before creating it
DO
$do$
BEGIN
   IF EXISTS (SELECT * FROM pg_roles WHERE rolname = 'postgres') THEN
      ALTER ROLE postgres PASSWORD 'postgres';
   ELSE
      CREATE ROLE postgres LOGIN PASSWORD 'postgres';
   END IF;
   ALTER ROLE postgres CREATEDB;
   ALTER ROLE postgres SUPERUSER;
END
$do$;
SELECT * FROM pg_roles WHERE rolname = 'postgres';

-- Create postgres database
CREATE DATABASE postgres;

-- Create processed_events table
CREATE TABLE processed_events (
   url VARCHAR
);
SELECT url FROM processed_events;
