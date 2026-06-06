# Third-Party Notices

This repository contains source code for the Consul Autopilot image and also builds a container image that redistributes third-party software.

The repository source code authored for this project is licensed under the Mozilla Public License 2.0. See [LICENSE](LICENSE).

## Consul

The built image copies `/bin/consul` from the official `hashicorp/consul:${CONSUL_VERSION}` image.

Consul is not authored by this project and is not licensed under this repository's MPL 2.0 license. Consul versions `1.17.0` and later are licensed by IBM/HashiCorp under the Business Source License 1.1, with the license parameters published in the Consul repository:

- Consul license: https://github.com/hashicorp/consul/blob/main/LICENSE
- HashiCorp licensing FAQ: https://www.hashicorp.com/license-faq

The Dockerfile default currently uses Consul `1.22.7`, so the bundled Consul binary is covered by the Consul Business Source License terms unless the build is configured to use a different Consul version with different licensing.

Users of this image are responsible for complying with the Consul license terms for the Consul version included in the image.

## Alpine Linux and Packages

The built image is based on `alpine:${ALPINE_VERSION}` and installs Alpine packages including `bash`, `tini`, and `curl`.

Those packages are not authored by this project and are distributed under their respective upstream licenses. Alpine package metadata can be inspected inside a built image with:

```sh
docker run --rm ghcr.io/autopilot-pattern-revisited/consul-autopilot:latest apk info -vv
```
