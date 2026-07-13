FROM node:26-trixie

ARG PLAYWRIGHT_VERSION=1.59.1

LABEL org.opencontainers.image.source="https://github.com/DigitalTolk/docker-builder-playwright"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.description="Pre-built Playwright image (chromium + webkit) for use as a base in GitHub Actions"

ENV CI=true
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    openssh-client \
    build-essential \
  && npm install -g playwright@${PLAYWRIGHT_VERSION} \
  && playwright install --with-deps chromium webkit \
  && npm cache clean --force \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
