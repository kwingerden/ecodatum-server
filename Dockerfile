FROM ubuntu:16.04

LABEL maintainer="Ken Wingerden <ken.wingerden@gmail.com>"
LABEL Description="Docker Container for EcoDatum's web application"

ARG CIPER_KEY
ARG MYSQL_PASSWORD

RUN apt-get update && \
    apt-get -y install curl && \
    curl -sL https://apt.vapor.sh | bash && \
    apt-get update && \
    apt-get -y install cmysql vapor && \
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
    ./bin/vapor-set-mysql-password $MYSQL_PASSWORD && \
    ./bin/vapor-build-release

EXPOSE 8080

CMD ["./bin/vapor-run-production"]