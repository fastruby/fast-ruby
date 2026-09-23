# Image for Rubies without an official Docker image: the nightly head builds
# (the same ones ruby/setup-ruby uses) and TruffleRuby 22.
FROM ubuntu:24.04

ARG RUBY=ruby-head
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl build-essential git \
      libyaml-dev libssl-dev libffi-dev libgmp-dev libreadline-dev zlib1g-dev \
 && case "$RUBY" in jruby-*) apt-get install -y --no-install-recommends openjdk-21-jre-headless ;; esac \
 && rm -rf /var/lib/apt/lists/*

# The head builds are compiled with this prefix, so they must live here.
WORKDIR /home/runner/.rubies

RUN case "$TARGETARCH" in \
      amd64) builder_arch=x64; oracle_arch=amd64 ;; \
      arm64) builder_arch=arm64; oracle_arch=aarch64 ;; \
      *) echo "unsupported arch: $TARGETARCH" >&2; exit 1 ;; \
    esac \
 && case "$RUBY" in \
      ruby-head|jruby-head|truffleruby-head) \
        url="https://github.com/ruby/${RUBY%%-*}-dev-builder/releases/latest/download/$RUBY-ubuntu-24.04-$builder_arch.tar.gz" ;; \
      truffleruby-22.*) \
        version="${RUBY#truffleruby-}"; \
        url="https://github.com/oracle/truffleruby/releases/download/vm-$version/truffleruby-$version-linux-$oracle_arch.tar.gz" ;; \
      *) echo "unsupported RUBY: $RUBY" >&2; exit 1 ;; \
    esac \
 && curl -fsSL "$url" | tar xz \
 && if [ ! -d "$RUBY" ]; then mv truffleruby-* "$RUBY"; fi \
 && if [ -x "$RUBY/lib/truffle/post_install_hook.sh" ]; then "$RUBY/lib/truffle/post_install_hook.sh"; fi

ENV PATH=/home/runner/.rubies/${RUBY}/bin:$PATH

RUN ruby -v

WORKDIR /app
