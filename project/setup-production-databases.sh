#!/bin/bash
# setup-production-databases.sh

set -e

echo "Setting up PostgreSQL databases and users for production..."

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Database connection info (admin user)
PGHOST="postgres"  # Use container name instead of localhost
PGPORT="5432"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"

# Function to run psql commands inside the postgres container
run_psql() {
    docker compose exec -T postgres psql -h localhost -p 5432 -U "$POSTGRES_USER" "$@"
}

# Function to run psql commands on a specific database
run_psql_db() {
    local database=$1
    shift
    docker compose exec -T postgres psql -h localhost -p 5432 -U "$POSTGRES_USER" -d "$database" "$@"
}

echo "Connecting as admin user: $POSTGRES_USER"

# =================================================================
# R2R User and Database Setup
# =================================================================

# R2R User and Database
R2R_USER="${R2R_POSTGRES_USER}"
R2R_PASSWORD="${R2R_POSTGRES_PASSWORD}"
R2R_DATABASE="${R2R_POSTGRES_DBNAME:-ragdb}"

echo "Creating R2R user: $R2R_USER"
run_psql -c "
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$R2R_USER') THEN
        CREATE USER $R2R_USER WITH ENCRYPTED PASSWORD '$R2R_PASSWORD';
        ALTER USER $R2R_USER CREATEDB;
    END IF;
END
\$\$;
" || echo "Failed to create R2R user"

echo "Creating R2R database: $R2R_DATABASE"
# Check if database exists, if not create it
if ! run_psql -lqt | cut -d \| -f 1 | grep -qw "$R2R_DATABASE"; then
    echo "Database $R2R_DATABASE does not exist, creating it..."
    run_psql -c "CREATE DATABASE $R2R_DATABASE OWNER $R2R_USER;" || echo "Failed to create R2R database"
else
    echo "Database $R2R_DATABASE already exists"
fi

run_psql -c "
GRANT ALL PRIVILEGES ON DATABASE $R2R_DATABASE TO $R2R_USER;
" || echo "Failed to grant R2R privileges"

echo "Enabling vector extension on R2R database..."
run_psql_db "$R2R_DATABASE" -c "
CREATE EXTENSION IF NOT EXISTS vector;
" || echo "Failed to enable vector extension"

echo "R2R Database setup complete!"

echo ""
echo "=== PRODUCTION DATABASE SUMMARY ==="
echo "PostgreSQL Admin: $POSTGRES_USER / [password in .env]"
echo "R2R User: $R2R_USER / [password in .env]"
echo "R2R Database: $R2R_DATABASE (owner: $R2R_USER)"
echo "===================================="

echo ""
echo "Testing connections..."

echo "Testing R2R database connection..."
docker compose exec -T postgres psql -h localhost -p 5432 -U "$R2R_USER" -d "$R2R_DATABASE" -c "SELECT 'R2R connection successful' as status;" || echo "❌ R2R connection failed"

echo "Testing vector extension..."
docker compose exec -T postgres psql -h localhost -p 5432 -U "$R2R_USER" -d "$R2R_DATABASE" -c "SELECT vector_dims('[1,2,3]'::vector) as vector_test;" || echo "❌ Vector extension test failed"

# =================================================================
# Hatchet User and Database Setup
# =================================================================

# Hatchet User and Database  
HATCHET_USER="${HATCHET_POSTGRES_USER}"
HATCHET_PASSWORD="${HATCHET_POSTGRES_PASSWORD}"
HATCHET_DATABASE="${HATCHET_POSTGRES_DBNAME:-hatchet}"

echo "Creating Hatchet user: $HATCHET_USER"
run_psql -c "
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$HATCHET_USER') THEN
        CREATE USER $HATCHET_USER WITH ENCRYPTED PASSWORD '$HATCHET_PASSWORD';
        ALTER USER $HATCHET_USER CREATEDB;
    END IF;
END
\$\$;
" || echo "Failed to create Hatchet user"

echo "Creating Hatchet database: $HATCHET_DATABASE"
# Check if database exists, if not create it
if ! run_psql -lqt | cut -d \| -f 1 | grep -qw "$HATCHET_DATABASE"; then
    echo "Database $HATCHET_DATABASE does not exist, creating it..."
    run_psql -c "CREATE DATABASE $HATCHET_DATABASE OWNER $HATCHET_USER;" || echo "Failed to create Hatchet database"
else
    echo "Database $HATCHET_DATABASE already exists"
fi

run_psql -c "
GRANT ALL PRIVILEGES ON DATABASE $HATCHET_DATABASE TO $HATCHET_USER;
" || echo "Failed to grant Hatchet privileges"

echo ""
echo "=== PRODUCTION DATABASE SUMMARY ==="
echo "Hatchet User: $HATCHET_USER / [password in .env]" 
echo "Hatchet Database: $HATCHET_DATABASE (owner: $HATCHET_USER)"
echo "===================================="

echo ""
echo "Testing connections..."

echo "Testing Hatchet database connection..."
docker compose exec -T postgres psql -h localhost -p 5432 -U "$HATCHET_USER" -d "$HATCHET_DATABASE" -c "SELECT 'Hatchet connection successful' as status;" || echo "❌ Hatchet connection failed"

echo ""
echo "✅ Production database setup complete!"