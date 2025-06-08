#!/bin/bash

# 1. Start postgres first
docker compose --profile step1 up -d
docker compose --profile step1 wait postgres

# 2. Run setup script directly in bash 
# (decision to run internal in script)
./scripts/setup-db.sh

# 3. Start step2 services: graph cluster, unstructured, minio, and rabbitmq
docker compose --profile step2 up -d

# 4. Start hatchet-migration , hatchet-setup-config, etc. 
docker compose --profile step1 --profile step2 --profile setup up -d

# 5. Start hatchet-engine and hatchet-engine-dashboard
docker compose --profile step1 --profile step2 --profile step3 up -d

# 6. Start r2r
docker compose --profile step1 --profile setup --profile step2 --profile step3 --profile step4 up -d

