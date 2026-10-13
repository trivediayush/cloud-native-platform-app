# Cloud-Native Platform App

> **Project status: Concluded at the current implementation stage (13 October 2026).**  
> This repository documents the application and CI/container work completed for a larger cloud-native platform project. It is not a claim that every originally planned platform component was completed.

## Overview

A small Flask HTTP application packaged as a non-root container, built and published to Amazon ECR through GitHub Actions. It was used to exercise the application delivery path in an Amazon EKS environment managed through a separate GitOps repository.

## Application endpoints

| Endpoint | Purpose | Response observed |
|---|---|---|
| `/` | Application identity and version | `application`, `status`, and `version` fields |
| `/health` | Basic health check | `{"status":"healthy"}` |

The deployed application returned version `1.0.1` during final verification.

## Technology used

- Python 3.12
- Flask 3.1.3
- Containerfile / OCI container image
- Podman for local image build and inspection
- Amazon ECR
- GitHub Actions
- GitHub Actions OIDC role assumption for AWS access
- Trivy vulnerability scanning
- Amazon EKS for runtime deployment (deployment configuration lives in the GitOps repository)

## Container hardening implemented

The current `Containerfile`:
- Uses `python:3.12-slim-trixie` as the base image.
- Runs `apt-get update` and `apt-get upgrade` during the image build, then removes apt package lists.
- Installs Python dependencies from `requirements.txt`.
- Pins pip to `26.2.0`.
- Creates and runs as non-root user UID `10001`.
- Exposes port `8080`.

Review the actual `Containerfile` and `requirements.txt` for the authoritative build configuration.

## CI workflow

The GitHub Actions workflow (`.github/workflows/ci.yml`) includes application checks, a Trivy image scan, and publishing to Amazon ECR on the configured branch. The Trivy scan was configured as non-blocking (`exit-code: "0"`) so remaining findings did not prevent publishing.

The security-updated application image was built and published with Git commit tag:

`3a45fea620449548ecedfa960f7aecffbe1f1766`

The recorded ECR image digest was:

`sha256:35e4d74e987f33e36633caabed94b4783c5b475d3bc76d043e67a6c90400f8e7`

These values describe the image recorded during the project work; check ECR for current registry state.

## Security scan status and known limitations

At the time of the recorded scan for the `1.0.3` local image:
- Debian OS packages: 0 Critical, 44 High, 58 Medium, 61 Low findings.
- Python packages: 0 Critical, 4 High, 2 Medium findings.

The Python findings included reported advisories involving `msgpack`, `setuptools`, and `urllib3`. The attempted transitive dependency upgrades were not confirmed as applied, so this README does **not** claim those findings were fixed. The OS-level findings also remained. The scan was non-blocking, and the image was published despite these findings.

For a production deployment, refresh the base image and dependencies, rebuild, and review a fresh scan before use.

## Runtime verification recorded

The application was deployed in EKS through the GitOps repository. During final checks:
- The `/` endpoint returned version `1.0.1` with status `running`.
- The `/health` endpoint returned `healthy`.
- Two application replicas were Ready.
- A deleted application pod was recreated by the Deployment controller.
- A sequential availability check returned 60/60 HTTP 200 responses.
- The test did not trigger HPA scale-out; the HPA remained at two replicas.

Detailed test notes were committed to the GitOps repository at `docs/reliability-test-evidence.txt`.

## Repository boundary

This repository owns the Flask application, container build definition, dependency manifest, and CI workflow. Kubernetes Helm values and Argo CD application configuration were maintained in the separate repository:

[cloud-native-platform-gitops](https://github.com/trivediayush/cloud-native-platform-gitops)

## Project conclusion

The project was intentionally concluded at its current stage on 13 October 2026. It demonstrates a working application container and a CI-to-ECR-to-EKS delivery path, but it should not be presented as a fully completed production platform. The larger planned observability scope (including OpenTelemetry, Loki, and Tempo) was not implemented or verified during this project.
