#!/bin/sh

# ConfigMap and DDL script

if [ -f "../configs.env" ]; then
    set -a
    . ../configs.env
    set +a
fi

mkdir ../sql/

cat <<EOF > ../sql/definition.sql
CREATE DATABASE $DB_NAME;
CREATE USER $PGUSER;
ALTER USER $PGUSER WITH ENCRYPTED PASSWORD '$PGPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $PGUSER;
\c $DB_NAME $PGUSER;
CREATE TABLE todos(id serial primary key, title varchar, description text, done bool default false);
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO $PGUSER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO $PGUSER; 
EOF

chmod 744 ../sql/definition.sql

envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/configs.yaml >> ../kubernetes/cloud-provider/configs.yaml
envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/configs.yaml >> ../kubernetes/local-cluster/configs.yaml

# Secrets

export PGUSER=$(echo -n "$PGUSER" | base64)
export PGPASSWORD=$(echo -n "$PGPASSWORD" | base64)
export POSTGRES_USER=$(echo -n "$POSTGRES_USER" | base64)
export POSTGRES_PASSWORD=$(echo -n "$POSTGRES_PASSWORD" | base64)

envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/secrets.yaml >> ../kubernetes/local-cluster/configs.yaml
envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/secrets.yaml >> ../kubernetes/cloud-provider/configs.yaml