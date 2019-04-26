# Description

**swarm-deploy-helper** is a tool to help build and deploy containerized applications into Docker Swarm using GitLab CI.

## Building Docker images

Example of `.gitlab-ci.yml` to build and release container image:

```
include:
  - remote: 'https://raw.githubusercontent.com/bborysenko/swarm-deploy-helper/master/templates/docker.gitlab-ci.yml'

stages:
  - build
  - release

build:docker:
  extends: .docker:image:build

release:docker:
  extends: .docker:image:release
```

## Google Container Registry

To be able to pull/push container images from/to [Google Container Registry](https://cloud.google.com/container-registry/) you have to create a service account and setup Gitlab CI environment variables.

1. Go to **IAM > Service Accounts** and create one with **Storage Admin** role.
2. Download a file contains the JSON private key for service account.
3. In Gitlab create project or group level [environment variables](https://gitlab.owox.com/help/ci/variables/README#variables) - `GOOGLE_PROJECT` - with name of Google Cloud project and `GOOGLE_SERVICE_KEY` with contents of service account private key which you downloaded previously.

## Reference

- [Authentication methods for Google Container Registry](https://cloud.google.com/container-registry/docs/advanced-authentication)
- [Using Google Compute Engine with Docker Machine](https://docs.docker.com/machine/drivers/gce/)
