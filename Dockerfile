# syntax=docker/dockerfile:1.7
FROM node:22-bookworm-slim

ARG OPENCLAW_VERSION=2026.2.26
ENV OPENCLAW_VERSION=${OPENCLAW_VERSION}
ENV OPENCLAW_HOME=/home/node/.openclaw
ENV OPENCLAW_GATEWAY_PORT=18789
ENV TMPDIR=/home/node/.openclaw/tmp

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl git gosu tini \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g --omit=dev "openclaw@${OPENCLAW_VERSION}" \
  && test "$(openclaw --version)" = "${OPENCLAW_VERSION}"

COPY docker/bootstrap.sh /usr/local/bin/bootstrap.sh
COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/bootstrap.sh /usr/local/bin/healthcheck.sh

RUN mkdir -p ${OPENCLAW_HOME} \
  && chmod 1777 /tmp \
  && chown -R node:node /home/node

USER root
WORKDIR /home/node

EXPOSE 18789
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/bootstrap.sh"]
CMD ["openclaw", "gateway", "--allow-unconfigured", "--bind", "lan"]
