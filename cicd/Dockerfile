FROM ubuntu:24.04

RUN apt-get update -y && apt-get upgrade -y && \
  apt-get install -y curl git unzip xz-utils zip libglu1-mesa \
  clang cmake git \
  ninja-build pkg-config \
  libgtk-3-dev liblzma-dev \
  libstdc++-12-dev wget

WORKDIR /opt

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.2-stable.tar.xz && \
  tar -xf flutter_linux_3.29.2-stable.tar.xz && \
  rm flutter_linux_3.29.2-stable.tar.xz

ENV PATH="/opt/flutter/bin:$PATH"

RUN git config --global --add safe.directory /opt/flutter && flutter --disable-analytics && flutter doctor

WORKDIR /root