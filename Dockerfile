# use a builder image for building cloudflare
FROM golang:1.17.1 as builder
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    TARGET_GOOS=linux \
    TARGET_GOARCH=arm64

WORKDIR /go/src/github.com/cloudflare/cloudflared/

# copy our sources into the builder image
COPY . .

# compile cloudflared
RUN make cloudflared

# use a distroless base image with glibc
FROM docker.io/arm64v8/alpine

# copy our compiled binary
COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

RUN adduser -D nonroot

USER nonroot

VOLUME [ "/home/nonroot/.cloudflared", "/etc/cloudflared" ]

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
