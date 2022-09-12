#编译deb的
ARG GO_IMAGE
ARG BUILD_IMAGE

FROM ${GO_IMAGE} AS golang

FROM ${BUILD_IMAGE}

RUN echo "deb http://mirrors.aliyun.com/debian/ buster main non-free contrib"                       > /etc/apt/sources.list && \
    echo "deb-src http://mirrors.cloud.aliyuncs.com/debian/ buster main non-free contrib"           >>/etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.aliyuncs.com/debian-security buster/updates main"                >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.cloud.aliyuncs.com/debian-security buster/updates main"            >>/etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.aliyuncs.com/debian/ buster-updates main non-free contrib"       >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.cloud.aliyuncs.com/debian/ buster-updates main non-free contrib"   >>/etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.aliyuncs.com/debian/ buster-backports main non-free contrib"     >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.cloud.aliyuncs.com/debian/ buster-backports main non-free contrib" >>/etc/apt/sources.list 

RUN apt-get update && apt-get install -y git make

ENV GOPROXY=direct
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

COPY --from=golang /usr/local/go /usr/local/go

ARG BUILD_DIR
COPY build/deb/build-deb/ /usr/local/bin/

RUN chmod +x /usr/local/bin/build-deb

WORKDIR /root/

ENTRYPOINT [ "build-deb" ]

