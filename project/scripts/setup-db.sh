#!/bin/bash
# setup-db.sh

set -e

FLAG_FILE=".setup-db-done"

if [ -f "$FLAG_FILE" ]; then
  echo "✅ Database setup already completed (flag: $FLAG_FILE). Skipping."
  exit 0
fi

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Database connection info
PGHOST="postgres"
PGPORT="5432"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"

# Utility functions
run_psql() {
    docker compose exec -T postgres psql -h localhost -p 5432 -U "$POSTGRES_USER" "$@"
}

run_psql_db() {
    local database=$1
    shift
    docker compose exec -T postgres psql -h localhost -p 5432 -U "$POSTGRES_USER" -d "$database" "$@"
}

# Check initial DB connectivity
check_db_connection() {
    echo "Checking PostgreSQL connectivity as user '$POSTGRES_USER'..."
    if ! run_psql -c "SELECT 1;" >/dev/null 2>&1; then
        echo "❌ Cannot connect to PostgreSQL as '$POSTGRES_USER'. Exiting."
        exit 1
    fi
    echo "✅ PostgreSQL is reachable and admin user login successful."
}

# R2R Setup
setup_r2r_db() {
    local R2R_USER="${R2R_POSTGRES_USER}"
    local R2R_PASSWORD="${R2R_POSTGRES_PASSWORD}"
    local R2R_DATABASE="${R2R_POSTGRES_DBNAME:-ragdb}"

    echo "Setting up R2R user and database..."

    run_psql -c "DROP DATABASE IF EXISTS $R2R_DATABASE;"
    run_psql -c "DROP USER IF EXISTS $R2R_USER;"

    run_psql -c "CREATE USER $R2R_USER WITH ENCRYPTED PASSWORD '$R2R_PASSWORD';"
    run_psql -c "ALTER USER $R2R_USER CREATEDB;"
    run_psql -c "CREATE DATABASE $R2R_DATABASE OWNER $R2R_USER;"
    run_psql -c "GRANT ALL PRIVILEGES ON DATABASE $R2R_DATABASE TO $R2R_USER;"
    run_psql_db "$R2R_DATABASE" -c "CREATE EXTENSION IF NOT EXISTS vector;"
    echo "✅ R2R Database '$R2R_DATABASE' created and configured."

    # Test connection
    run_psql_db "$R2R_DATABASE" -U "$R2R_USER" -c "SELECT 'R2R connection successful' as status;"
    run_psql_db "$R2R_DATABASE" -U "$R2R_USER" -c "SELECT vector_dims('[1,2,3]'::vector) as vector_test;"
}

# Hatchet Setup
setup_hatchet_db() {
    local HATCHET_USER="${HATCHET_POSTGRES_USER}"
    local HATCHET_PASSWORD="${HATCHET_POSTGRES_PASSWORD}"
    local HATCHET_DATABASE="${HATCHET_POSTGRES_DBNAME:-hatchet}"

    echo "Setting up Hatchet user and database..."

    run_psql -c "DROP DATABASE IF EXISTS $HATCHET_DATABASE;"
    run_psql -c "DROP USER IF EXISTS $HATCHET_USER;"

    run_psql -c "CREATE USER $HATCHET_USER WITH ENCRYPTED PASSWORD '$HATCHET_PASSWORD';"
    run_psql -c "ALTER USER $HATCHET_USER CREATEDB;"
    run_psql -c "CREATE DATABASE $HATCHET_DATABASE OWNER $HATCHET_USER;"
    run_psql -c "GRANT ALL PRIVILEGES ON DATABASE $HATCHET_DATABASE TO $HATCHET_USER;"
    echo "✅ Hatchet Database '$HATCHET_DATABASE' created and configured."

    # Test connection
    run_psql_db "$HATCHET_DATABASE" -U "$HATCHET_USER" -c "SELECT 'Hatchet connection successful' as status;"
}

# Main execution
main() {
    check_db_connection

    echo "===== Starting R2R setup ====="
    setup_r2r_db

    #echo "===== Starting Hatchet setup ====="
    #setup_hatchet_db

    echo "✅ All databases and users setup completed successfully!"

    # Write the flag file
    touch "$FLAG_FILE"

}


main
