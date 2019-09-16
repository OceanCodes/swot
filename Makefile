.PHONY: all service test image image-branch ecr-login push push-branch lint

all: service test

SHELL := /bin/bash
IMAGE_NAME = codeocean/swot
REGISTRY ?= 524950183868.dkr.ecr.us-east-1.amazonaws.com
TAG ?= $(shell ./make-tag.sh)
BRANCH ?= $(CIRCLE_BRANCH)
DIR = lib

service:
	cd $(DIR) && \
	CGO_ENABLED=0 go build -a -installsuffix nocgo -o swot-go .

test:
	cd $(DIR) && \
	go test -v

image:
	cd $(DIR) && \
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):latest
	if [ -n "$(TAG)" ]; then docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):$(TAG); fi

image-branch:
	if [ -n "$(BRANCH)" ]; then \
		cd $(DIR) && docker build -t $(REGISTRY)/$(IMAGE_NAME):$(BRANCH) .; \
	fi

ecr-login:
	`aws ecr get-login --region us-east-1 --no-include-email`

push: ecr-login
	if [ -n "$(TAG)" ]; then \
		docker push $(REGISTRY)/$(IMAGE_NAME):latest; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(TAG); \
	fi

push-branch: ecr-login
	if [ -n "$(BRANCH)" ]; then \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(BRANCH); \
	fi

lint:
	golangci-lint run
