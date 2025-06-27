#!/bin/bash
# Start SQL Server in background
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to start..."
sleep 20

# Execute all .sql files in /init-db
for f in /usr/src/app/SQL-Server/*.sql
do
  echo "Running $f..."
  /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -i "$f"
done

# Keep container alive
wait