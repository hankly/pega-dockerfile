#!/bin/bash
. ~/.bash_profile
pg_ctl start -l /var/lib/pgsql/9.4/pgstartup.log

sleep 3

psql --command "ALTER USER postgres WITH PASSWORD 'postgres';"
psql --command "CREATE DATABASE prpc WITH OWNER = postgres ENCODING = 'UTF8' TABLESPACE = pg_default LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' CONNECTION LIMIT = -1;"
psql --command "ALTER ROLE postgres IN DATABASE prpc SET search_path = pegarules, pegadata;"
psql --command "CREATE ROLE pegadata LOGIN ENCRYPTED PASSWORD 'md53d879fa3e037a1a389ff6d61da15381e' SUPERUSER INHERIT CREATEDB NOCREATEROLE NOREPLICATION;"
psql --command "CREATE ROLE pegarules LOGIN ENCRYPTED PASSWORD 'md543f2fe59c9fee2e2fa57dba080c59b04' SUPERUSER INHERIT CREATEDB NOCREATEROLE NOREPLICATION;"
psql -d prpc --command "CREATE SCHEMA pegadata AUTHORIZATION pegadata;"
psql -d prpc --command "GRANT ALL ON SCHEMA pegadata TO pegadata;"
psql -d prpc --command "GRANT ALL ON SCHEMA pegadata TO public;"
psql -d prpc --command "CREATE SCHEMA pegarules AUTHORIZATION pegarules;"
psql -d prpc --command "GRANT ALL ON SCHEMA pegarules TO pegarules;"
psql -d prpc --command "GRANT ALL ON SCHEMA pegarules TO public;"
psql -d prpc < /var/lib/pgsql/9.4/install.sql
pg_ctl stop
exec postgres "$@"
