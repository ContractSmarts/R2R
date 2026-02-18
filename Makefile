# Configuration
IMAGE_NAME := csmarts/r2r
VERSION := 3.7.0
FULL_TAG := $(IMAGE_NAME):$(VERSION)
EXPORT_FILE := r2r_custom_$(VERSION).tar.gz

.PHONY: help build recreate export all clean

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the custom R2R Docker image
	@echo "--- 📦 Building $(FULL_TAG) ---"
	docker build -t $(FULL_TAG) ./py -f ./py/Dockerfile

recreate: ## Restart the R2R service with the new image
	@echo "--- 🔄 Recreating R2R Container ---"
	docker compose up -d --force-recreate r2r
	@echo "✨ System updated. Checking logs..."
	docker logs --tail 20 -f r2r

export: ## Export the image to a compressed tarball for customer VMs
	@echo "--- 📤 Exporting to $(EXPORT_FILE) ---"
	docker save $(FULL_TAG) | gzip > $(EXPORT_FILE)
	@echo "✅ Export complete: $(EXPORT_FILE)"

all: build export ## Run build and then export (standard release flow)
	@echo "🏁 Build and Export finished successfully."

deploy: build recreate ## Build and immediately update the local system
	@echo "🚀 Local deployment complete."

clean: ## Remove the exported tarball
	rm -f $(EXPORT_FILE)
