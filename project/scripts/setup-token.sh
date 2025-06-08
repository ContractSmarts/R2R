#!/bin/bash

set -e
echo 'Starting token creation process...'

# In your setup-token.sh script, make sure it uses the correct host
export HATCHET_CLIENT_HOST=hatchet-engine
export HATCHET_CLIENT_PORT=7077

# Extract tenant ID from database.yaml config file
CONFIG_FILE="/hatchet/config/database.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file $CONFIG_FILE not found" >&2
    exit 1
fi

echo "Reading tenant ID from $CONFIG_FILE..."

# Extract the defaultTenantId from the YAML file
TENANT_ID=$(grep "defaultTenantId:" "$CONFIG_FILE" | sed 's/.*defaultTenantId: *//' | sed 's/^["'"'"']//' | sed 's/["'"'"']$//')

if [ -z "$TENANT_ID" ]; then
    echo 'Error: Could not extract defaultTenantId from database.yaml' >&2
    echo 'Config file contents:'
    cat "$CONFIG_FILE"
    exit 1
fi

echo "Using tenant ID from config: $TENANT_ID"

# Debug: Check if Hatchet admin command exists and is executable
echo "Checking hatchet-admin command..."
if ! command -v /hatchet/hatchet-admin >/dev/null 2>&1; then
    echo "Error: /hatchet/hatchet-admin not found or not executable"
    ls -la /hatchet/
    exit 1
fi

# Debug: Test basic connectivity first
echo "Testing basic hatchet-admin connectivity..."
timeout 30 /hatchet/hatchet-admin --help || echo "Help command failed or timed out"

# Debug: Try to list existing tokens first
echo "Attempting to list existing tokens..."
timeout 30 /hatchet/hatchet-admin token list --config /hatchet/config --tenant-id "$TENANT_ID" 2>&1 || echo "Token list failed or timed out"

# Debug: Check if we can connect to the database
echo "Testing database connectivity..."
timeout 10 /hatchet/hatchet-admin tenant list --config /hatchet/config 2>&1 || echo "Tenant list failed or timed out"

# Attempt to create token with timeout
echo 'Creating API token with 60 second timeout...'
if ! timeout 60 /hatchet/hatchet-admin token create --config /hatchet/config --tenant-id "$TENANT_ID" > /tmp/token_output.txt 2>&1; then
    echo "Error: Token creation timed out or failed after 60 seconds"
    echo "Command output:"
    cat /tmp/token_output.txt 2>/dev/null || echo "No output captured"
    
    # Additional debugging
    echo "Checking network connectivity:"
    ping -c 3 postgres || echo "Cannot ping postgres"
    ping -c 3 hatchet-rabbitmq || echo "Cannot ping hatchet-rabbitmq"
    
    echo "Checking if services are responding:"
    nc -z postgres 5432 && echo "PostgreSQL is reachable" || echo "PostgreSQL is not reachable"
    nc -z hatchet-rabbitmq 5672 && echo "RabbitMQ is reachable" || echo "RabbitMQ is not reachable"
    
    exit 1
fi

TOKEN_OUTPUT=$(cat /tmp/token_output.txt)
echo 'Token creation output:'
echo "$TOKEN_OUTPUT"

# Extract the token
TOKEN=$(echo "$TOKEN_OUTPUT" | grep -Eo 'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*')

if [ -z "$TOKEN" ]; then
    echo 'Error: Failed to extract token. Full command output:' >&2
    echo "$TOKEN_OUTPUT" >&2
    exit 1
fi

echo "$TOKEN" > /tmp/hatchet_api_key
echo 'Token created and saved to /tmp/hatchet_api_key'

# Copy token to final destination
echo -n "$TOKEN" > /hatchet_api_key/api_key.txt
echo 'Token copied to /hatchet_api_key/api_key.txt'

echo 'Hatchet API key has been saved successfully'
echo 'Token length:' ${#TOKEN}
echo 'Token (first 20 chars):' ${TOKEN:0:20}

echo 'Token generation completed successfully!'
