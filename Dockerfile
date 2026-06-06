
ARG CONSUL_VERSION=1.22.7
ARG ALPINE_VERSION=3.23.4

FROM hashicorp/consul:${CONSUL_VERSION} AS consul-source
FROM alpine:${ALPINE_VERSION} AS final

COPY --from=consul-source /bin/consul /bin/consul
RUN apk add bash tini curl
COPY --chmod=755 generate-config-and-start.sh /generate-config-and-start.sh

VOLUME /data
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8500 8600 8600/udp
HEALTHCHECK --interval=3s --timeout=3s --start-period=10s --retries=5 CMD test -n "$(curl -fsS http://127.0.0.1:8500/v1/status/leader)" || exit 1
ENTRYPOINT ["/sbin/tini"]
CMD ["/generate-config-and-start.sh"]