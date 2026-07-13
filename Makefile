PLAYWRIGHT_VERSION := $(shell jq -r .dependencies.playwright package.json)
IMAGE_NAME         ?= ghcr.io/digitaltolk/docker-builder-playwright
IMAGE_TAG          ?= $(PLAYWRIGHT_VERSION)

.DEFAULT_GOAL := help
.PHONY: help build test shell version push clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "Targets:\n"} /^[a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the docker image
	docker build \
		--build-arg PLAYWRIGHT_VERSION=$(PLAYWRIGHT_VERSION) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		-t $(IMAGE_NAME):latest \
		.

test: build ## Smoke test the built image
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) playwright --version
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) node --version

shell: ## Run an interactive shell in the image
	docker run --rm -it -v $(PWD):/workspace $(IMAGE_NAME):$(IMAGE_TAG) bash

version: ## Print the playwright version pinned by this build
	@echo $(PLAYWRIGHT_VERSION)

push: ## Push the image to the registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(IMAGE_NAME):latest

clean: ## Remove built local tags
	-docker rmi $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest
