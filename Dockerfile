FROM alpine:3.7

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"

# Build argument to set Mattermost edition
ARG edition=team
ARG MATTERMOST_VERSION=5.4.0
ARG PUID=2000
ARG PGID=2000

# Install some needed packages
RUN apk add --no-cache \
	ca-certificates \
	curl \
	jq \
	libc6-compat \
	libffi-dev \
	linux-headers \
	mailcap \
	netcat-openbsd \
	xmlsec-dev \
	&& rm -rf /tmp/*

# Get Mattermost
RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins \
    && if [ "$edition" = "team" ] ; then curl https://releases.mattermost.com/$MATTERMOST_VERSION/mattermost-team-$MATTERMOST_VERSION-linux-amd64.tar.gz | tar -xvz ; \
      else curl https://releases.mattermost.com/$MATTERMOST_VERSION/mattermost-$MATTERMOST_VERSION-linux-amd64.tar.gz | tar -xvz ; fi \
    && cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json \
    && addgroup -g ${PGID} mattermost \
    && adduser -D -u ${PUID} -G mattermost -h /mattermost -D mattermost \
    && chown -R mattermost:mattermost /mattermost /config.json.save /mattermost/plugins /mattermost/client/plugins

USER mattermost

#Healthcheck to make sure container is ready
HEALTHCHECK CMD curl --fail http://localhost:8000

# Configure entrypoint and command
COPY entrypoint.sh /
COPY mattermost.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["/mattermost.sh"]

# Expose port 8000 of the container
EXPOSE 8000

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
