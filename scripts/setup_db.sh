#!/bin/bash

DB_HOST="localhost"
DB_USER="rh"
DB_NAME="rh"
DB_PASS="rh_pwd"

SQL_FILE1="sql/schema.sql"
SQL_FILE2="sql/prepopulate.sql"

# Check if SQL files exist
if [[ ! -f "$SQL_FILE1" || ! -f "$SQL_FILE2" ]]; then
    echo "One or both SQL files not found!"
    exit 1
fi

echo "Importing schema..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE1" || {
    echo "Error: Failed to execute $SQL_FILE1"
    exit 1
}

echo "Prepopulating data..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE2" || {
    echo "Error: Failed to execute $SQL_FILE2"
    exit 1
}

echo "Database setup completed successfully."
