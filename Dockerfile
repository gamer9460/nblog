FROM peaceiris/hugo:v0.110.0-mod AS builder

WORKDIR /app
COPY . .
RUN git submodule update --init && hugo --minify --enableGitInfo

FROM nginx:1.23-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/nginx/nginx.conf /etc/nginx/
COPY --from=builder /app/nginx/app.conf /etc/nginx/conf.d
COPY --from=builder /app/public .
EXPOSE 8080
ENTRYPOINT ["nginx", "-g", "daemon off;"]