# Consul Autopilot

Consul Autopilot is a small Consul server image for the Autopilot Pattern. It copies the Consul binary from the official HashiCorp Consul image into an Alpine base image and starts Consul with a generated server configuration.

This image is intended to provide the Consul infrastructure layer used by images built around the revived ContainerPilot project at [Autopilot-Pattern-Revisited/containerpilot](https://github.com/Autopilot-Pattern-Revisited/containerpilot).

## Image

The published image is:

```text
ghcr.io/autopilot-pattern-revisited/consul-autopilot:latest
```

The CI builds a multi-platform image for:

- `linux/amd64`
- `linux/arm64`

The Consul and Alpine versions can be changed when running the GitHub Actions workflow manually. The Dockerfile defaults are:

- Consul `1.22.7`
- Alpine `3.23.4`

## Usage

Start a local three-node Consul server cluster with Docker Compose:

```sh
docker compose up --build --scale consul=3
```

The compose file exposes the Consul HTTP API/UI on host ports `8500` through `8502`, one port per replica:

```sh
curl http://localhost:8500/v1/status/leader
```

The service uses Docker DNS to discover all `consul` containers, waits until `BOOTSTRAP_EXPECT` replicas are visible, writes `/consul.hcl`, and then starts `consul agent`.

## Configuration

Runtime configuration is provided through environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `BOOTSTRAP_EXPECT` | `1` | Number of Consul server containers expected before startup. |
| `CONSUL_HOSTNAME` | container hostname | DNS name used to discover peer containers. In compose this is `consul`. |
| `CONSUL_DATACENTER` | `dc1` | Consul datacenter name. |
| `CONSUL_NODE_ID` | container hostname | Consul node name and per-node data directory name. |
| `CONSUL_BIND_ADDR` | `0.0.0.0` | Consul bind address. |
| `CONSUL_LOG_LEVEL` | `INFO` | Consul log level. |
| `CONSUL_CLUSTER_DOMAIN` | `consul.` | Consul DNS domain. |
| `CONSUL_UI_PATH` | `/consul` | UI content path. |
| `EXCLUSIVE_DATA_DIR` | `false` | Use `/data` directly instead of `/data/$CONSUL_NODE_ID`. |

Data is stored under `/data`, which is declared as a Docker volume.

## CI

`.github/workflows/docker-image.yaml` builds and pushes to GHCR when a version tag in the form `vX.Y.Z` is pushed, such as `v1.0.0`. Published images are tagged with that Git tag and `latest`. Pull requests and manual workflow runs build the image without pushing it unless the workflow is run against a `vX.Y.Z` tag ref.

Manual workflow runs expose `consul_version` and `alpine_version` inputs, which are passed to the Dockerfile as `CONSUL_VERSION` and `ALPINE_VERSION` build args.

The workflow also attempts to mark the GHCR package public after publishing. If GitHub does not allow the repository token to change package visibility, set the package to public once in the GHCR package settings.

## Licensing

The source code authored for this repository is licensed under the Mozilla Public License 2.0. See [LICENSE](LICENSE).

The published container image also redistributes third-party software. In particular, it copies the Consul binary from the official HashiCorp Consul image. Consul is licensed separately by IBM/HashiCorp; current Consul releases such as the Dockerfile default, `1.22.7`, are under the Business Source License 1.1. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for details and upstream license links.
