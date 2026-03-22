FROM ubuntu:22.04

ARG FLUTTER_VERSION
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    libgtk-3-dev libblkid-dev \
    fonts-noto fonts-noto-color-emoji \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN flutter precache --no-android --no-ios --no-web && \
    flutter config --no-analytics && \
    dart --disable-analytics

WORKDIR /app
