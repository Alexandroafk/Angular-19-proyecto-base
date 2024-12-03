#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REQUIRED_VARS=("DATABASE_HOST" "DATABASE_PORT" "DATABASE_USER" "DATABASE_PASSWORD" "POSTGRES_DB" "DB_SQL_FILE")
for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    echo -e "${RED}Error: La variable de entorno $VAR no está definida.${NC}"
    exit 1
  fi
done

echo -e "${YELLOW}Iniciando reinicio de la base de datos '${POSTGRES_DB}' en el host '${DATABASE_HOST}:${DATABASE_PORT}'...${NC}"
if ! PGPASSWORD="$DATABASE_PASSWORD" psql -U "$DATABASE_USER" -h "$DATABASE_HOST" -p "$DATABASE_PORT" -d postgres -c '\q' 2>/dev/null; then
  echo -e "${RED}Error: No se puede conectar a la base de datos. Verifica las variables de entorno y la conexión.${NC}"
  exit 1
fi

echo -e "${YELLOW}Cerrando conexiones activas a la base de datos '${POSTGRES_DB}'...${NC}"
PGPASSWORD="$DATABASE_PASSWORD" psql -U "$DATABASE_USER" -h "$DATABASE_HOST" -p "$DATABASE_PORT" -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '${POSTGRES_DB}' AND pid <> pg_backend_pid();" || {
  echo -e "${RED}Error: No se pudieron cerrar las conexiones activas.${NC}"
  exit 1
}
echo -e "${GREEN}Conexiones activas cerradas.${NC}"

echo -e "${YELLOW}Eliminando la base de datos '${POSTGRES_DB}' si existe...${NC}"
PGPASSWORD="$DATABASE_PASSWORD" psql -U "$DATABASE_USER" -h "$DATABASE_HOST" -p "$DATABASE_PORT" -d postgres -c "DROP DATABASE IF EXISTS \"$POSTGRES_DB\";" || {
  echo -e "${RED}Error: No se pudo eliminar la base de datos '${POSTGRES_DB}'.${NC}"
  exit 1
}
echo -e "${GREEN}Base de datos eliminada.${NC}"

echo -e "${YELLOW}Creando la base de datos '${POSTGRES_DB}'...${NC}"
PGPASSWORD="$DATABASE_PASSWORD" psql -U "$DATABASE_USER" -h "$DATABASE_HOST" -p "$DATABASE_PORT" -d postgres -c "CREATE DATABASE \"$POSTGRES_DB\";" || {
  echo -e "${RED}Error: No se pudo crear la base de datos '${POSTGRES_DB}'.${NC}"
  exit 1
}
echo -e "${GREEN}Base de datos creada exitosamente.${NC}"

SQL_FILE_PATH="${WORKDIR}/.devcontainer/sql/${DB_SQL_FILE}.sql"
if [ -n "$DB_SQL_FILE" ] && [ -f "$SQL_FILE_PATH" ]; then
  echo -e "${YELLOW}Restaurando la base de datos desde el archivo '$SQL_FILE_PATH'...${NC}"

  pg_restore -U "$DATABASE_USER" -h "$DATABASE_HOST" -p "$DATABASE_PORT" -d "$POSTGRES_DB" "$SQL_FILE_PATH" || {
    echo -e "${RED}Error: La restauración desde el archivo SQL falló.${NC}"
    exit 1
  }

  echo -e "${GREEN}Base de datos restaurada exitosamente.${NC}"
else
  echo -e "${YELLOW}No se realizará la restauración desde un archivo SQL, DB_SQL_FILE no está definido o el archivo no existe.${NC}"
fi


echo -e "${YELLOW}Completado.${NC}"
