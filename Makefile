# 主文件
include ./build/common.mk

##@ General

.PHONY: help
help: ## 显示make帮助
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: clean
clean: ## 清理编译输出
	@rm -rf $(OUTPUT_DIR)

.PHONY: swag
swag: ## 生成swagger文档
	@swag init --parseDependency --parseInternal
	
.PHONY: doc
doc: swag ## 生成swagger文档和
	@go run . doc

##@ Build

.PHONY: build
build: ## 本地编译当前系统和架构
	@echo $(GREEN)编译$(GOOS)/$(GOARCH)
	@$(BUILD)
	@cp $(GO_OUTPUT) $(BIN_DIR)/$(PROJECT)

.PHONY: run
run: ## 直接运行不编译
	go run $(ROOT_DIR)

.PHONY: build-all
build-all: ## 多平台多架构
	@for os in $(OSS);do \
		for arch in $(ARCHS);do \
			GOOS=$$os GOARCH=$$arch make build; \
		done \
	done

.PHONY: build-in-docker
build-in-docker: ## 在docker里的编译选项
	@CGO_ENABLED=0 go build -ldflags $(LDFLAG) $(ROOT_DIR)

all: build-all docker tgz rpm deb ## 编译打包所有

##@ Deploy
.PHONY: install
install: build ## 安装到系统PATH
	@cp $(GO_OUTPUT) /usr/local/bin/$(PROJECT)

.PHONY: uninstall
uninstall: ## 卸载安装
	@rm -rf /usr/local/bin/$(PROJECT)

##@ Packag

.PHONY: docker
docker: ## 编译docker镜像
	@echo $(GREEN)构建docker镜像
	@$(DOCKER_BUILD)
	@echo $(YELLOW)镜像地址:
	@echo $(IMAGE_ADDR)
	@echo $(IMAGE_ADDR_LATEST)

.PHONY: tgz
tgz: ## 打包为tar包
	@echo $(GREEN)打包为tgz
	@$(TGZ)

.PHONY: rpm
rpm: ## 打包为rpm包
	@echo $(GREEN)打包rpm
	@mkdir -p $(RPM_DIR)/RPMS $(RPM_DIR)/SRPMS
	@$(CHECK_TGZ)
	@$(RPM_DOCKER_BUILD)
	@$(RPM_DOCKER_RUN)

.PHONY: deb
deb: ## 打包为deb包
	@echo $(GREEN)打包deb
	@mkdir -p $(DEB_DIR)
	@$(CHECK_TGZ)
	@$(DEB_DOCKER_BUILD)
	@$(DEB_DOCKER_RUN)

