FROM alpine:3.4

MAINTAINER sgtsquiggs

# set arch for s6 overlay
ARG S6_ARCH="${S6_ARCH:-amd64}"
ARG S6_VERSION="${S6_VERSION:-1.19.1.1}"

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
HOME="/root" \
TERM="xterm"

# download s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.gz /tmp/s6-overlay.tar.gz

RUN \
# install s6 overlay
    set -ex &&\
    tar xzf /tmp/s6-overlay.tar.gz -C / &&\
    rm -rf \
        /var/cache/apk/* \
        /tmp/* &&\

# install packages
    apk add --no-cache \
        bash \
        ca-certificates \
        coreutils \
        tzdata &&\
    apk add --no-cache \
        --repository http://dl-cdn.alpinelinux.org/alpine/v3.5/community \
        shadow &&\

# create abc user
    groupmod -g 1000 users &&\
    useradd -u 911 -U -d /config -s /bin/false abc &&\
    usermod -G users abc &&\

# make our folders
    mkdir -p \
        /app \
        /config \
        /defaults

# add local files
COPY root/ /

ENTRYPOINT ["/init"]
