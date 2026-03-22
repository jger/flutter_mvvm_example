# Linux + Flutter + GTK + Xvfb — mirrors CI for integration_test (-d linux).
FROM ubuntu:22.04

ARG FLUTTER_VERSION
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    build-essential clang cmake ninja-build pkg-config \
    libgtk-3-dev libblkid-dev liblzma-dev \
    xvfb \
    fonts-noto fonts-noto-color-emoji \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN flutter config --no-analytics --enable-linux-desktop && \
    flutter precache --linux && \
    dart --disable-analytics

WORKDIR /app
