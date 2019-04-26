FROM alpine:3.9

ARG DOCKER_VERSION
ARG DOCKER_COMPOSE_VERSION
ARG DOCKER_MACHINE_VERSION
ARG CONTAINER_STRUCTURE_TEST_VERSION
ARG GLIBC_VERSION
ARG YQ_VERSION

RUN set -eux; \
    \
    # Set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
    [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf; \
    \
    # Install bash & other utilities
    apk add --no-cache \
      bash \
      bc \
      ca-certificates \
      coreutils \
      curl \
      gawk \
      git \
      grep \
      gzip \
      jq \
      openssl \
      openssh \
      sed \
      tar

# Install yq (https://github.com/mikefarah/yq)
RUN set -eux; \
    \
    YQ_URL=https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64 ;\
    wget -q -O /usr/local/bin/yq $YQ_URL; \
    chmod +x /usr/local/bin/yq

# Install glibc on Alpine (required by docker-compose)
RUN set -eux; \
    \
    apk add --no-cache libgcc; \
    \
    URL_KEY=https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
    URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk; \
    curl -fsSL --retry 3 -o /etc/apk/keys/sgerrand.rsa.pub $URL_KEY; \
    curl -fsSL --retry 3 -o glibc.apk $URL; \
    apk add --no-cache glibc.apk; \
    ln -s /lib/libz.so.1 /usr/glibc-compat/lib/; \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib; \
    ln -s /usr/lib/libgcc_s.so.1 /usr/glibc-compat/lib; \
    rm /etc/apk/keys/sgerrand.rsa.pub glibc.apk

# Install docker (client only to reduce image size)
RUN set -eux; \
    \
    URL=https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz; \
    curl -fsSL --retry 3 -o docker.tgz $URL; \
    tar -xf docker.tgz --strip-components 1 --directory /usr/local/bin/ docker/docker; \
    rm docker.tgz; \
	  \
	  docker --version

# Install docker-compose
RUN set -eux; \
    \
    URL=https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-Linux-x86_64; \
    curl -fsSL --retry 3 -o /usr/local/bin/docker-compose $URL; \
    chmod +x /usr/local/bin/docker-compose; \
    \
    docker-compose --version

# Install docker-machine
RUN set -eux; \
    \
    URL=https://github.com/docker/machine/releases/download/v$DOCKER_MACHINE_VERSION/docker-machine-Linux-x86_64; \
    curl -fsSL --retry 3 -o /usr/local/bin/docker-machine $URL; \
    chmod +x /usr/local/bin/docker-machine; \
    \
    docker-machine --version

# Install container-structure-test (https://github.com/GoogleContainerTools/container-structure-test/)
RUN set -eux; \
    \
    URL=https://storage.googleapis.com/container-structure-test/v${CONTAINER_STRUCTURE_TEST_VERSION}/container-structure-test-linux-amd64; \
    curl -fsSL --retry 3 -o /usr/local/bin/container-structure-test $URL; \
    chmod +x /usr/local/bin/container-structure-test; \
    \
    container-structure-test version

ENV DOCKER_VERSION=${DOCKER_VERSION} \
    DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION} \
    DOCKER_MACHINE_VERSION=${DOCKER_MACHINE_VERSION} \
    CONTAINER_STRUCTURE_TEST_VERSION=${CONTAINER_STRUCTURE_TEST_VERSION}

ENV CI_SCRIPTS=/usr/local/gitlab-ci \
    CI_SCRIPTS_BIN=/usr/local/gitlab-ci/bin \
    CI_SCRIPTS_LIBS=/usr/local/gitlab-ci/libs

ENV PATH=$CI_SCRIPTS_BIN:$PATH

COPY libs $CI_SCRIPTS/libs
