.PHONY: service test image image-branch push push-branch

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
	docker tag -f $(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):latest
	if [ -n "$(TAG)" ]; then docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):$(TAG); fi

image-branch:
	if [ -n "$(BRANCH)" ]; then \
		cd $(DIR) && docker build -t $(REGISTRY)/$(IMAGE_NAME):$(BRANCH) .; \
	fi

push:
	if [ -n "$(TAG)" ]; then \
		`aws ecr get-login --region us-east-1`; \
		docker push $(REGISTRY)/$(IMAGE_NAME):latest | cat; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(TAG) | cat; \
	fi

push-branch:
	if [ -n "$(BRANCH)" ]; then \
		`aws ecr get-login --region us-east-1`; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(BRANCH) | cat; \
	fi

lint:
	gometalinter ./...
