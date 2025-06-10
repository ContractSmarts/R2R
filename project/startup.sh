#!/bin/bash

# 1. Start postgres first
#docker compose --profile postgres up -d
#docker compose --profile postgres wait postgres

docker compose up -d postgres

# 2. Run setup script directly in bash 
# (decision to run internal in script)
./scripts/setup-db.sh

# 3. Start step2 services: graph cluster, unstructured, minio, and rabbitmq
docker compose up -d minio graph_clustering unstructured hatchet-rabbitmq

# 4. Start hatchet-migration , hatchet-setup-config, etc. 
docker compose --profile postgres --profile step2 --profile hatchet up -d

# 5. Start hatchet-engine and hatchet-engine-dashboard
docker compose --profile postgres --profile step2 --profile hatchet --profile r2r up -d

## 6. Start r2r
#docker compose --profile step1 --profile setup --profile step2 --profile step3 --profile step4 up -d

