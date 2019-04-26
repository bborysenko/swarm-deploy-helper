# Description

swarm-deploy-helper is a tool to help build and deploy containerized applications into Docker Swarm using GitLab CI.

## Building Docker images

Example:

```
include:
  - remote: 'https://raw.githubusercontent.com/bborysenko/swarm-deploy-helper/master/templates/docker.gitlab-ci.yml'

docker:
  extends: .docker:image:build
```
