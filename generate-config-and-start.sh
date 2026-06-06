#!/usr/bin/env bash

BOOTSTRAP_EXPECT=${BOOTSTRAP_EXPECT:-1}
CONSUL_HOSTNAME=${CONSUL_HOSTNAME:-`hostname -s`}
CONSUL_DATACENTER=${CONSUL_DATACENTER:-dc1}
CONSUL_NODE_ID=${CONSUL_NODE_ID:-`hostname -s`}
CONSUL_BIND_ADDR=${CONSUL_BIND_ADDR:-"0.0.0.0"}
CONSUL_LOG_LEVEL=${CONSUL_LOG_LEVEL:-INFO}
CONSUL_CLUSTER_DOMAIN=${CONSUL_CLUSTER_DOMAIN:-"consul."}
CONSUL_UI_PATH=${CONSUL_UI_PATH:-"/consul"}
DATA_DIRECTORY=/data
EXCLUSIVE_DATA_DIR=${EXCLUSIVE_DATA_DIR:-false}

function get_all_containers() {
    getent ahostsv4 $CONSUL_HOSTNAME | awk '{print $1}' | sort -u
}

function wait_for_all_containers() {
    while true; do
        local count=$(get_all_containers | wc -l)
        if [ "$count" -ge "$BOOTSTRAP_EXPECT" ]; then
            break
        fi
        echo "Waiting for $BOOTSTRAP_EXPECT containers to be available. Currently: $count"
        sleep 2
    done
}

wait_for_all_containers
ALL_CONTAINERS=$(get_all_containers)
echo "All containers are available: $ALL_CONTAINERS"
RECURSORS=$(awk '/^nameserver/ {printf "\"%s\",", $2}' /etc/resolv.conf)

if $EXCLUSIVE_DATA_DIR; then
    DATADIR=$DATA_DIRECTORY
else
    DATADIR="$DATA_DIRECTORY/$CONSUL_NODE_ID"
fi
mkdir -p "$DATADIR"

if [ "$BOOTSTRAP_EXPECT" -eq 1 ]; then
    BOOTSTRAP_LINE="bootstrap = true"
else
    BOOTSTRAP_LINE="bootstrap_expect = ${BOOTSTRAP_EXPECT}"
fi


cat > /consul.hcl <<EOF
datacenter = "${CONSUL_DATACENTER}"
data_dir = "${DATADIR}"
server = true
${BOOTSTRAP_LINE}
node_name = "${CONSUL_NODE_ID}"
bind_addr = "${CONSUL_BIND_ADDR}"
client_addr = "0.0.0.0"
log_level = "${CONSUL_LOG_LEVEL}"
domain = "${CONSUL_CLUSTER_DOMAIN}"
recursors = [
    ${RECURSORS}
]
ui_config = {
    enabled = true
    content_path = "${CONSUL_UI_PATH}"
}
retry_join = [
EOF

for ip in $(get_all_containers); do
    echo "  \"${ip}\"," >> /consul.hcl
done

cat >> /consul.hcl <<EOF
]
EOF

exec /bin/consul agent -config-file /consul.hcl "$@"
