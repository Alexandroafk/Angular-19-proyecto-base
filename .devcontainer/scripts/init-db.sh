#!/bin/bash
set -e

# Verificar que la base de datos no tenga tablas
if ! psql -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT 1 FROM pg_catalog.pg_tables WHERE schemaname = 'public'" | grep -q 1; then
  echo "Base de datos vacía, restaurando"
else
  echo "Base de datos tiene almenos una tabla, no se restaura"
  exit 0
fi

# Verifica si el archivo de sql existe
if [ -n "$DB_SQL_FILE" ] && [ -f /tmp/${DB_SQL_FILE}.sql ]; then
  echo "Restaurando base de datos desde archivo .sql"
  pg_restore -U $POSTGRES_USER -d $POSTGRES_DB /tmp/${DB_SQL_FILE}.sql
  echo "Base de datos restaurada"
else
  echo "No se realizará la restauración desde un archivo .sql, DB_SQL_FILE no está definido o el archivo no existe."
fi