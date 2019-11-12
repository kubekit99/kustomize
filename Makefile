# This Makefile is (and must be) used by
# travis/pre-commit.sh to qualify pull requests.
#
# That script generates all the code that needs
# to be generated, and runs all the tests.
#
# Functionality in that script is gradually moving here.

MYGOBIN := $(shell go env GOPATH)/bin
TOOLSBIN := $(PWD)/hack/tools/bin
PATH := $(TOOLSBIN):$(MYGOBIN):$(PATH)
SHELL := env PATH=$(PATH) /bin/bash

.DEFAULT_GOAL := all

export GO111MODULE=on

.PHONY: all
all: pre-commit

# The pre-commit.sh script generates, lints and tests.
# It uses this makefile.  For more clarity, would like
# to stop that - any scripts invoked by targets here
# shouldn't "call back" to the makefile.
.PHONY: pre-commit
pre-commit:
	./travis/pre-commit.sh

# Version pinned by hack/tools/go.mod
$(TOOLSBIN)/golangci-lint:
	cd hack/tools; \
	GOBIN=$(TOOLSBIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint

# Version pinned by hack/tools/go.mod
$(TOOLSBIN)/mdrip:
	cd hack/tools; \
	GOBIN=$(TOOLSBIN) go install github.com/monopole/mdrip

# Version pinned by hack/tools/go.mod
$(TOOLSBIN)/stringer:
	cd hack/tools; \
	GOBIN=$(TOOLSBIN) go install golang.org/x/tools/cmd/stringer

# Version pinned by hack/tools/go.mod
$(TOOLSBIN)/goimports:
	cd hack/tools; \
	GOBIN=$(TOOLSBIN) go install golang.org/x/tools/cmd/goimports

# Version pinned by hacktools/go.mod
$(TOOLSBIN)/pluginator:
	cd hack/tools; \
	GOBIN=$(TOOLSBIN) go install sigs.k8s.io/kustomize/pluginator/v2
	# cd pluginator; \
	# GOBIN=$(TOOLSBIN) go install .

# Specific version tags for these utilities are pinned
# in ./hack/tools/go.mod, which seems to be as good a place as
# any to do so.  That's the reason for all the occurances
# of 'cd hack/tools;' in the dependencies; 'GOBIN=$(TOOLSBIN) go install' uses the
# local 'go.mod' to find the correct version to install.
# 
# Change 1: Unlike upstream version of api module, it can actually be used as a library
# without pulling 200 indirect dependencies on other modules used only during the
# test (blackfriday...)
# Change 2: This makefile does not change your go/bin with the version picked
# by the kustomize team
.PHONY: install-tools
install-tools: \
	$(TOOLSBIN)/goimports \
	$(TOOLSBIN)/golangci-lint \
	$(TOOLSBIN)/mdrip \
	$(TOOLSBIN)/pluginator \
	$(TOOLSBIN)/stringer

# Builtin plugins are generated code.
# Add new items here to create new builtins.
builtinplugins = \
	api/builtins/annotationstransformer.go \
	api/builtins/configmapgenerator.go \
	api/builtins/hashtransformer.go \
	api/builtins/imagetagtransformer.go \
	api/builtins/inventorytransformer.go \
	api/builtins/labeltransformer.go \
	api/builtins/legacyordertransformer.go \
	api/builtins/namespacetransformer.go \
	api/builtins/patchjson6902transformer.go \
	api/builtins/patchstrategicmergetransformer.go \
	api/builtins/patchtransformer.go \
	api/builtins/prefixsuffixtransformer.go \
	api/builtins/replicacounttransformer.go \
	api/builtins/secretgenerator.go \
	api/builtins/kindordertransformer.go \
	api/builtins/kindfiltertransformer.go

.PHONY: lint
lint: install-tools $(builtinplugins)
	cd api; $(TOOLSBIN)/golangci-lint run ./...
	cd kustomize; $(TOOLSBIN)/golangci-lint run ./...
	cd pluginator; $(TOOLSBIN)/golangci-lint run ./...

api/builtins/%.go: $(TOOLSBIN)/pluginator $(TOOLSBIN)/goimports
	@echo "generating $*"; \
	cd plugin/builtin/$*; \
	go generate .; \
	cd ../../../api/builtins; \
	$(TOOLSBIN)/goimports -w $*.go

.PHONY: generate
generate: $(builtinplugins)

.PHONY: unit-test-api
unit-test-api: $(builtinplugins)
	cd api; go test ./...

.PHONY: unit-test-plugins
unit-test-plugins:
	./hack/runPluginUnitTests.sh

.PHONY: unit-test-kustomize
unit-test-kustomize:
	cd kustomize; go test ./...

.PHONY: unit-test-all
unit-test-all: unit-test-api unit-test-kustomize unit-test-plugins

COVER_FILE=coverage.out

.PHONY: cover
cover:
	# The plugin directory eludes coverage, and is therefore omitted
	cd api && go test ./... -coverprofile=$(COVER_FILE) && \
	go tool cover -html=$(COVER_FILE)

.PHONY: unit-tests
unit-tests: unit-tests-api unit-tests-kustomize unit-tests-plugins

# linux only.
# This is for testing an example plugin that
# uses kubeval for validation.
# Don't want to add a hard dependence in go.mod file
# to github.com/instrumenta/kubeval.
# Instead, download the binary.
$(TOOLSBIN)/kubeval:
	d=$(shell mktemp -d); cd $$d; \
	wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz; \
	tar xf kubeval-linux-amd64.tar.gz; \
	mv kubeval $(TOOLSBIN); \
	rm -rf $$d

# linux only.
# This is for testing an example plugin that
# uses helm to inflate a chart for subsequent kustomization.
# Don't want to add a hard dependence in go.mod file
# to helm.
# Instead, download the binary.
$(TOOLSBIN)/helm:
	d=$(shell mktemp -d); cd $$d; \
	wget https://storage.googleapis.com/kubernetes-helm/helm-v2.16.0-linux-amd64.tar.gz; \
	tar -xvzf helm-v2.16.0-linux-amd64.tar.gz; \
	mv linux-amd64/helm $(TOOLSBIN); \
	rm -rf $$d

.PHONY: fmt-api
fmt-api:
	cd api; go fmt ./...

.PHONY: fmt-kustomize
fmt-kustomize:
	cd kustomize; go fmt ./...

.PHONY: fmt-pluginator
fmt-pluginator:
	cd pluginator; go fmt ./...

.PHONY: fmt-plugins
fmt-plugins:
	cd plugin/builtin/prefixsuffixtransformer && go fmt ./...
	cd plugin/builtin/replicacounttransformer && go fmt ./...
	cd plugin/builtin/patchstrategicmergetransformer && go fmt ./...
	cd plugin/builtin/imagetagtransformer && go fmt ./...
	cd plugin/builtin/namespacetransformer && go fmt ./...
	cd plugin/builtin/labeltransformer && go fmt ./...
	cd plugin/builtin/legacyordertransformer && go fmt ./...
	cd plugin/builtin/patchtransformer && go fmt ./...
	cd plugin/builtin/configmapgenerator && go fmt ./...
	cd plugin/builtin/inventorytransformer && go fmt ./...
	cd plugin/builtin/annotationstransformer && go fmt ./...
	cd plugin/builtin/secretgenerator && go fmt ./...
	cd plugin/builtin/patchjson6902transformer && go fmt ./...
	cd plugin/builtin/hashtransformer && go fmt ./...
	cd plugin/builtin/kindordertransformer && go fmt ./...
	cd plugin/builtin/kindfiltertransformer && go fmt ./...

.PHONY: fmt
fmt: fmt-api fmt-kustomize fmt-pluginator fmt-plugins

.PHONY: modules
modules:
	./hack/doGoMod.sh tidy

## --------------------------------------
## Binaries
## --------------------------------------

.PHONY: build-plugins
build-plugins:
	./plugin/buildPlugins.sh $(GOPATH)

.PHONY: build
build:
	cd pluginator && go build -o $(PLUGINATOR_NAME) .
	cd kustomize && go build -o $(KUSTOMIZE_NAME) ./main.go

.PHONY: install
install:
	cd pluginator && GOBIN=$(TOOLSBIN) go install $(PWD)/pluginator
	cd kustomize && GOBIN=$(MYGOBIN) go install $(PWD)/kustomize

.PHONY: clean
clean:
	rm -f api/$(COVER_FILE)
	rm -f $(builtinplugins)
	rm -f $(MYGOBIN)/pluginator
	rm -fr $(TOOLSBIN)

.PHONY: nuke
nuke: clean
	sudo rm -rf $(shell go env GOPATH)/pkg/mod/sigs.k8s.io
