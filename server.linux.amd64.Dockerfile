# build drone server
FROM golang:1.14.4-alpine as builder
ENV DRONE_SERVER_VERSION="1.10.1"
WORKDIR /build
RUN apk add -U --no-cache alpine-sdk \
    && git clone git://github.com/drone/drone.git \
    && cd drone \
    && git checkout "v${DRONE_SERVER_VERSION}" \
    && go build -tags "nolimit" ./cmd/drone-server

# build final image
FROM alpine AS dist
LABEL maintainer="rnicrosoft <>"
LABEL Name="Drone server" Version=${DRONE_SERVER_VERSION}
EXPOSE 80 443
VOLUME /data

ENV GODEBUG netdns=go
ENV XDG_CACHE_HOME /data
ENV DRONE_DATABASE_DRIVER sqlite3
ENV DRONE_DATABASE_DATASOURCE /data/database.sqlite
ENV DRONE_RUNNER_OS=linux
ENV DRONE_RUNNER_ARCH=amd64
ENV DRONE_SERVER_PORT=:80
ENV DRONE_SERVER_HOST=localhost

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /build/drone/drone-server /bin/
ENTRYPOINT ["/bin/drone-server"]
