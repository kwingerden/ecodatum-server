FROM ubuntu:16.04

LABEL maintainer="Ken Wingerden <ken.wingerden@gmail.com>"
LABEL Description="Docker Container for EcoDatum's web application"

RUN apt-get update && \
    apt-get -y install curl && \
    curl -sL https://apt.vapor.sh | bash && \
    apt-get update && \
    apt-get -y install vapor && \
    rm -r /var/lib/apt/lists/*;

WORKDIR /ecodatum-server

COPY bin bin
COPY Config Config
COPY Public Public
COPY Resources Resources
COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.swift

RUN ./bin/build-release

EXPOSE 8080

CMD ["./bin/run-production"]