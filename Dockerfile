FROM alpine:1.23 AS builder
ARG VERSION=0.110.0
ADD https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-amd64.tar.gz /hugo.tar.gz
RUN tar -zxvf hugo.tar.gz && \
    rm -rf hugo.tar.gz && \
    apk add --no-cache git
WORKDIR /app
COPY . .
RUN git submodule update --init && \
    /hugo --minify --enableGitInfo

FROM nginx:1.23-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/public .
ENTRYPOINT ["nginx", "-g", "daemon off;"]