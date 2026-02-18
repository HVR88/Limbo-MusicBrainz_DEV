FROM alpine:3.20

RUN apk add --no-cache rsync

WORKDIR /bundle

COPY deploy-assets/admin /bundle/admin
COPY deploy-assets/docker-compose.yml /bundle/docker-compose.yml
COPY deploy-assets/example.env /bundle/example.env
COPY deploy-assets/README.md /bundle/README.md
COPY compose /bundle/compose
COPY default /bundle/default
COPY build/solr/scripts /bundle/build/solr/scripts
COPY VERSION /bundle/VERSION

COPY build/deploy-assets/sync-assets.sh /usr/local/bin/mbms-assets-sync
RUN chmod 0755 /usr/local/bin/mbms-assets-sync

ENTRYPOINT ["/usr/local/bin/mbms-assets-sync"]
