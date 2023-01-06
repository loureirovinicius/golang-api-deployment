#!/bin/sh

export PGUSER=
export PGPASSWORD=
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=123456
export DB_NAME=todo_db
export API_PORT=9000
export HOST=db_service
export DB_PORT=5432

echo "CREATE DATABASE $DB_NAME;
CREATE USER $PGUSER;
ALTER USER $PGUSER WITH ENCRYPTED PASSWORD '$PGPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $PGUSER;
\\\c $DB_NAME;
CREATE TABLE todos(id serial primary key, title varchar, description text, done bool default false);
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO $PGUSER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO $PGUSER;" > ../sql/definition.sql

chmod 744 ../sql/definition.sql

envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/configs.yaml >> ../kubernetes/cloud-provider/configs.yaml
envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/configs.yaml >> ../kubernetes/local-cluster/configs.yaml

export PGUSER=$(echo -n "$PGUSER" | base64)
export PGPASSWORD=$(echo -n "$PGPASSWORD" | base64)
export POSTGRES_USER=$(echo -n "$POSTGRES_USER" | base64)
export POSTGRES_PASSWORD=$(echo -n "$POSTGRES_PASSWORD" | base64)

envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/secrets.yaml >> ../kubernetes/local-cluster/configs.yaml
envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/secrets.yaml >> ../kubernetes/cloud-provider/configs.yaml