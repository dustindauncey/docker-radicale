FROM python:3-alpine
MAINTAINER Thomas Queste <tom@tomsquest.com>

# Install Radicale
# Bcrypt is for user password security and requires gcc for compiling
RUN apk add --no-cache \
    tini \
    su-exec \
    gcc \
    libffi-dev \
    musl-dev \
    && pip install radicale passlib[bcrypt] \
    && apk del \
    gcc \
    libffi-dev \
    musl-dev

# User with no home, no password
RUN adduser -s /bin/false -D -H radicale

WORKDIR /radicale
RUN mkdir -p /radicale/config /radicale/data && chown -R radicale /radicale
COPY config /radicale/config

VOLUME /radicale/config
VOLUME /radicale/data
EXPOSE 5232

# Tini starts our entrypoint which then starts Radicale
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]
CMD ["radicale", "--config", "/radicale/config/config"]
