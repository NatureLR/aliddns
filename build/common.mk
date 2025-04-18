# 全局配置
PROJECT := aliddns
ARCHS   := amd64 arm64
OSS     := linux windows darwin
# 判断当前commit是否有tag如果有tag则显示tag没有则显示 commit次数.哈希
# 如果没有手动指定标签就使用自动生成的标签
# git describe --tags --always --dirty="-dev"
VERSION     = $(shell echo "$(shell git log --oneline |wc -l).$(shell git log -n1 --pretty=format:%h)" | sed 's/ //g')
TAG         = $(shell git log -n1 --pretty=format:%h |git tag --contains)
ifneq ($(TAG),)
VERSION     = $(shell git tag --sort=committerdate |tail -1)
endif

# go 参数
GOOS       ?= $(shell go env GOOS)
GOARCH     ?= $(shell go env GOARCH)
# 使用本地go版本作为go版本
# GOVERSION  ?= $(shell go version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
GOVERSION  ?= 1.24

# 目录
ROOT_DIR   := $(realpath $(CURDIR))
BUILD_DIR  := $(ROOT_DIR)/build
INSTALL_DIR:= /usr/local/bin
OUTPUT     := artifacts
OUTPUT_DIR := $(ROOT_DIR)/$(OUTPUT)
BIN_DIR    := $(OUTPUT_DIR)/bin
RPM_DIR    := $(OUTPUT_DIR)/rpm
DEB_DIR    := $(OUTPUT_DIR)/deb
TGZ_DIR    := $(OUTPUT_DIR)/tgz
RPMBUILD   := /root/rpmbuild
PRJVER     := $(PROJECT)-$(VERSION)

# go 注入参数
GO_PATH      := $(shell cat $(ROOT_DIR)/go.mod |grep module |cut -b 8-)
X_VERSION    := -X '$(GO_PATH)/pkg/versions.xVersion=$(VERSION)'
X_GIT_COMMIT := -X '$(GO_PATH)/pkg/versions.xGitCommit=$$(git rev-parse HEAD)'
X_BUILT      := -X '$(GO_PATH)/pkg/versions.xBuilt=$$(date "+%Y-%m-%d %H:%M:%S")'
LDFLAG       := "-s -w $(X_VERSION) $(X_GIT_COMMIT) $(X_BUILT)"
GO_OUTPUT    := $(BIN_DIR)/$(PRJVER)-$(GOOS)-$(GOARCH)
ifeq ($(GOOS),windows)
GO_OUTPUT    := $(BIN_DIR)/$(PRJVER)-$(GOOS)-$(GOARCH).exe
endif
BUILD        := go build -ldflags $(LDFLAG) -o $(GO_OUTPUT) $(ROOT_DIR)

# RPM
RPM_BUILD := rpmbuild \
	-ba \
	--define '_version $(VERSION)' \
	SPECS/$(PROJECT).spec

TGZ_CMD   :=tar --exclude $(PROJECT)/$(OUTPUT) -czf $(PRJVER).tar.gz $(PROJECT)
TGZ       := mkdir -p $(TGZ_DIR) && cd $(CURDIR)/../ && $(TGZ_CMD) &&  mv $(PRJVER).tar.gz $(TGZ_DIR)
CHECK_TGZ := if [ ! -f "$(TGZ_DIR)/$(PRJVER).tar.gz" ]; then echo tgz文件不存在创建tgz包;$(MAKE) tgz;fi

# docker
GO_IMAGE         ?= golang:$(GOVERSION)-buster
# 产生镜像时用于运行的镜像
GO_RUN_IMAGE     ?= alpine:latest
GO_BUILD_IMAGE   ?= golang:$(GOVERSION)-alpine
GO_BASE_IMAGE    ?= golang:$(GOVERSION)-buster
RPM_BUILD_IMAGE  ?= centos:7
DEB_BUILD_IMAGE  ?= debian:buster

# 自己的仓库
DOCKER_REPO       = 
IMAGE_ADDR        = $(DOCKER_REPO)/$(PROJECT):$(VERSION)
IMAGE_ADDR_LATEST = $(DOCKER_REPO)/$(PROJECT):latest
ifeq ($(DOCKER_REPO),)
IMAGE_ADDR        = $(PROJECT):$(VERSION)
IMAGE_ADDR_LATEST = $(PROJECT):latest
endif

DOCKER_BUILD     := docker build \
	-t $(IMAGE_ADDR) \
	-t $(IMAGE_ADDR_LATEST) \
	--build-arg RUN_IMAGE=$(GO_RUN_IMAGE) \
	--build-arg BUILD_IMAGE=$(GO_BUILD_IMAGE) \
	-f $(BUILD_DIR)/Dockerfile \
	$(ROOT_DIR) 
RPM_DOCKER_BUILD := docker build \
	-t rpmbuild \
	-f $(BUILD_DIR)/rpm/Dockerfile \
	--build-arg GO_IMAGE=$(GO_BASE_IMAGE) \
	--build-arg BUILD_IMAGE=$(RPM_BUILD_IMAGE) \
	.
RPM_DOCKER_RUN   := docker run \
	--rm \
	-v $(RPM_DIR)/RPMS:$(RPMBUILD)/RPMS/ \
	-v $(RPM_DIR)/SRPMS:$(RPMBUILD)/SRPMS/ \
	-v $(TGZ_DIR):$(RPMBUILD)/SOURCES/ \
	-v $(BUILD_DIR)/rpm:$(RPMBUILD)/SPECS/ \
	$(RPM_BUILD)
DEB_DOCKER_BUILD := docker build \
	-t debbuild \
	-f $(BUILD_DIR)/deb/Dockerfile \
	--build-arg GO_IMAGE=$(GO_BASE_IMAGE) \
	--build-arg BUILD_DIR=$(BUILD_DIR)/deb \
	--build-arg BUILD_IMAGE=$(DEB_BUILD_IMAGE)\
	.
DEB_DOCKER_RUN   := docker run \
	--rm \
	-e PROJECT=$(PROJECT) \
	-e VERSION=$(VERSION) \
	-v $(CURDIR):/data debbuild

# 颜色
RED    := $(shell tput -Txterm setaf 1)
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
VIOLET := $(shell tput -Txterm setaf 5)
AQUA   := $(shell tput -Txterm setaf 6)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
