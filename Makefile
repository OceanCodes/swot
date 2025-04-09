SHELL := /bin/bash
SERVICE_NAME := swot
IMAGE_NAME := codeocean/$(SERVICE_NAME)
PROD_REGISTRY ?= 524950183868.dkr.ecr.us-east-1.amazonaws.com
BUILD_REGISTRY ?= 590183797266.dkr.ecr.us-east-1.amazonaws.com
TAG ?= $(shell ./make-tag.sh)
COMMIT ?= $(if $(CIRCLE_SHA1),$(CIRCLE_SHA1),$(shell git rev-parse --verify HEAD))
BRANCH ?= $(if $(CIRCLE_BRANCH),$(CIRCLE_BRANCH),$(shell git rev-parse --abbrev-ref HEAD))
PROD_IMAGE_TAG = $(PROD_REGISTRY)/$(IMAGE_NAME):$(TAG)
BUILD_IMAGE_TAG = $(BUILD_REGISTRY)/$(IMAGE_NAME):$(TAG)
TAGS := -t $(PROD_IMAGE_TAG) -t $(BUILD_IMAGE_TAG)
ifeq ($(BRANCH),master)
	TAGS := $(TAGS) -t $(PROD_REGISTRY)/$(IMAGE_NAME):latest -t $(BUILD_REGISTRY)/$(IMAGE_NAME):latest
else ifeq ($(BRANCH),main)
	TAGS := $(TAGS) -t $(PROD_REGISTRY)/$(IMAGE_NAME):latest -t $(BUILD_REGISTRY)/$(IMAGE_NAME):latest
endif

.PHONY: all
all: service client test

.PHONY: show-tag
show-tag:
	@echo $(TAG)

.PHONY: service
service:
	cd lib && \
	for arch in amd64 arm64; do \
		CGO_ENABLED=0 GOOS=linux GOARCH=$${arch} go build -o $(SERVICE_NAME)-go.$${arch} -a -installsuffix nocgo -ldflags \
			"-X 'github.com/OceanCodes/common/services.Version=$(TAG)' \
			-X 'github.com/OceanCodes/common/services.Commit=$(COMMIT)'" \
			.; \
	done && \
	cp $(SERVICE_NAME)-go.amd64 $(SERVICE_NAME)-go

.PHONY: client
client:
	if [ -d "client" ]; then \
		cd client && \
		go build; \
	fi

.PHONY: test
test:
	if [ -d "test" ]; then \
		cd test && \
		go test -v; \
	fi

.PHONY: image
image: ecr-login
	cd lib && \
	docker context create ctx && \
	docker buildx create --name multiarch-builder --driver docker-container --use ctx && \
	docker buildx build --push --platform linux/amd64,linux/arm64 $(TAGS) .

.PHONY: ecr-login
ecr-login:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(PROD_REGISTRY)

	aws --profile build-cicd ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(BUILD_REGISTRY)

.PHONY: lint
lint:
	golangci-lint run $(LINTFLAGS)
