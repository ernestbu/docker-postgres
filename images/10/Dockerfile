# Postgres with ssl enabled
# Uses a self signed cert, not for production use
FROM postgres:10-alpine
LABEL maintainer "https://github.com/swistaczek"

RUN apk add --update openssl

ADD docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

CMD ["-c", "ssl=on"]