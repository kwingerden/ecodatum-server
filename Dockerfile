FROM ubuntu:16.04

LABEL maintainer="Ken Wingerden <ken.wingerden@gmail.com>"
LABEL Description="Docker Container for EcoDatum's web application"

ARG CIPER_KEY
ARG APP_ROOT_USER_NAME
ARG APP_ROOT_USER_EMAIL
ARG APP_ROOT_USER_PASSWORD
ARG POSTGRESQL_PASSWORD

RUN apt-get update && \
    apt-get -y install curl && \
    curl -sL https://apt.vapor.sh | bash && \
    apt-get update && \
    apt-get -y install \
        postgresql \
        postgresql-client \
        postgresql-contrib \
        libbsd-dev \
        libpq-dev \
        vapor && \
    rm -r /var/lib/apt/lists/*;

WORKDIR /ecodatum-server

COPY bin bin
COPY Config Config
COPY Public Public
COPY Resources Resources
COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.swift

RUN ./bin/vapor-set-cipher-key $CIPER_KEY && \
    ./bin/vapor-set-app-root-user $APP_ROOT_USER_NAME $APP_ROOT_USER_EMAIL $APP_ROOT_USER_PASSWORD && \
    ./bin/vapor-set-postgresql-password $POSTGRESQL_PASSWORD && \
    ./bin/vapor-build-release

EXPOSE 8080

CMD ["./bin/vapor-run-production"]