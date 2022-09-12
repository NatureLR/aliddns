# rpm构建环境
ARG GO_IMAGE
ARG BUILD_IMAGE

# 从此镜像中获取go
FROM ${GO_IMAGE} AS golang

FROM ${BUILD_IMAGE}

# 安装rpmbuild 工具
RUN  yum install -y rpm-build rpmlint yum-utils rpmdevtools make git 
RUN  rpmdev-setuptree

WORKDIR /root/rpmbuild

# 从golang官方镜像中拷贝到centos镜像
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin
COPY --from=golang /usr/local/go /usr/local/go

ENTRYPOINT ["/bin/rpmbuild"]
