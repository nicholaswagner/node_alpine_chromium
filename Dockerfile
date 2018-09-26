FROM node:8-alpine as node_alpine_chromium

# Includes a few extras that I like to have available.
# bash, gawk, sed, grep, bc, coreutils, and jq
RUN apk update && apk upgrade && \
    echo http://nl.alpinelinux.org/alpine/v3.8/community >> /etc/apk/repositories && \
    echo http://nl.alpinelinux.org/alpine/v3.8/main >> /etc/apk/repositories && \
    apk add --no-cache \
    zlib-dev \
    xvfb \
    xorg-server \
    dbus \
    ttf-freefont \
    chromium \
    nss \
    ca-certificates \
    dumb-init
# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
ENTRYPOINT ["dumb-init", "--"]


FROM node_alpine_chromium as app_developer

RUN apk update && apk upgrade && \
    apk add --no-cache \
    bash gawk sed grep bc coreutils jq

#   I like running things from /app
RUN mkdir -p /app /app/logs

# Add a non privileged user
RUN addgroup -S appuser && adduser -S -g appuser appuser \
    && mkdir -p /home/appuser/Downloads \
    && chown -R appuser:appuser /home/appuser \
    && chown -R appuser:appuser /app

# Run everything after as user.
USER appuser
WORKDIR  /app

# ... add your project files, run yarn install, etc
