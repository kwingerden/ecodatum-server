FROM ubuntu:16.04

LABEL maintainer="Ken Wingerden <ken.wingerden@gmail.com>"
LABEL Description="Docker Container for EcoDatum's web application"

RUN apt-get update && \
    apt-get -y install curl && \
    curl -sL https://apt.vapor.sh | bash && \
    apt-get update && \
    apt-get -y install vapor && \
    swift build --configuration release && \
    rm -r /var/lib/apt/lists/*;

EXPOSE 8080

CMD [".build/release/Run", "serve", "--env=production"]