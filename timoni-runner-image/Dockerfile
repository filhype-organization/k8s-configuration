FROM alpine:3.20
ARG TIMONI_VERSION=v0.26.0
ARG TARGETARCH=amd64
RUN apk add --no-cache ca-certificates wget \
 && wget -qO- "https://github.com/stefanprodan/timoni/releases/download/${TIMONI_VERSION}/timoni_${TIMONI_VERSION#v}_linux_${TARGETARCH}.tar.gz" \
    | tar xz -C /usr/local/bin timoni \
 && chmod +x /usr/local/bin/timoni \
 && timoni version
ENTRYPOINT ["timoni"]
