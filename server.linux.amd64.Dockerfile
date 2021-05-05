ARG AAA=1.10.1

# build drone server
FROM golang:1.14.4-alpine as builder
# RUN apk add -U --no-cache ca-certificates
WORKDIR /build
RUN apk add -U --no-cache alpine-sdk \
    && git clone git://github.com/drone/drone.git \
    && cd drone \
    && echo "$AAA" \
    && git checkout "v$AAA" \
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

COPY --from=builder /go/bin/drone-server /bin/
ENTRYPOINT ["/bin/drone-server"]
