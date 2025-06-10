#!/bin/bash

# 1. Start postgres first
#docker compose --profile postgres up -d
#docker compose --profile postgres wait postgres

docker compose up -d postgres

# 2. Run setup script directly in bash 
# (decision to run internal in script)
./scripts/setup-db.sh

# 3. Start other services: graph cluster, unstructured, minio
docker compose up -d minio graph_clustering unstructured

# 4. Start r2r
docker compose up -d r2r
