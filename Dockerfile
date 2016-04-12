FROM buildpack-deps:trusty-curl
MAINTAINER Software Craftsmen GmbH und CoKG <office@software-craftsmen.at>

# The go.cd package pulls in openjdk-7
RUN apt-get update && \
    apt-get install -y openssh-client git && \
    echo "deb https://download.go.cd /" | sudo tee /etc/apt/sources.list.d/gocd.list && \
    apt-get install -y  apt-transport-https && \
    wget -O - https://download.go.cd/GOCD-GPG-KEY.asc | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y go-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i -e 's/DAEMON=Y/DAEMON=N/' /etc/default/go-server

ADD cruise-config.xml cruise-config.xml
ADD docker-entrypoint.sh docker-entrypoint.sh

RUN mkdir -p /var/lib/go-server/addons /var/log/go-server /etc/go /go-addons && \
    chown -R go:go /var/lib/go-server /var/log/go-server /etc/go /go-addons /var/go cruise-config.xml && \
    chmod +x docker-entrypoint.sh

VOLUME /var/lib/go-server
VOLUME /var/log/go-server
VOLUME /etc/go
VOLUME /go-addons
VOLUME /var/go

EXPOSE 8153 8154

USER go

CMD ./docker-entrypoint.sh
