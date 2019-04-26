#!/usr/bin/env bash
#
# Gitlab CI helper to deploy containerized applications into Docker Swarm

[[ "$TRACE" ]] && set -x

docker::stack::deploy() {
  true
}
