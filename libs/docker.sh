#!/usr/bin/env bash
#
# Gitlab CI helper to build containerized applications

#######################################
# Override Gitlab CI predefined variables
#
# For master branch:
#   $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
#   $CI_REGISTRY_IMAGE:latest
#
# For feautre branches:
#   $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:$CI_COMMIT_SHORT_SHA
#   $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:latest
#
# For tags:
#   $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
#
# Globals:
#   CI_REGISTRY_IMAGE
#   CI_COMMIT_REF_SLUG
#   CI_COMMIT_SHORT_SHA
#   CI_COMMIT_TAG
#
# Arguments:
#   None
#
# Returns:
#   None
#######################################
docker:env:override() {
  if [[ "$CI_COMMIT_REF_SLUG" != "master" ]]; then
    export CI_REGISTRY_IMAGE+=/$CI_COMMIT_REF_SLUG
  fi

  if [[ -z "$CI_COMMIT_TAG" ]]; then
    export CI_REGISTRY_IMAGE+=:$CI_COMMIT_SHORT_SHA
  else
    export CI_REGISTRY_IMAGE+=:$CI_COMMIT_TAG
  fi
}

#######################################
# Login to Container Registry
#######################################
docker:registry:login() {
  true
}

#######################################
# Build Docker image
# Globals:
#   BUILD_CACHE_FROM
#   BUILD_TARGET
#   BUILD_ARG_XXXX
#   BUILD_DOCKERFILE
#   BUILD_CONTEXT
# Arguments:
#   None
# Returns:
#   None
#######################################
docker:image:build() {

  docker:env:override

  # Overide CI_REGISTRY_IMAGE to support building multiple images
  if [[ $BUILD_DOCKERFILE == *"."* ]]; then
    CI_REGISTRY_IMAGE="${CI_REGISTRY_IMAGE%:*}/${BUILD_DOCKERFILE##*.}:${CI_REGISTRY_IMAGE##*:}"
  fi

  # By default we use latest image as a cache
  BUILD_CACHE_FROM=${BUILD_CACHE_FROM:+${CI_REGISTRY_IMAGE%:*}:latest}

  local cmd="docker build --pull "

  if [[ -n $BUILD_CACHE_FROM ]]; then
    cmd+="--cache-from $BUILD_CACHE_FROM"
  fi

  if [[ -n $BUILD_TARGET ]]; then
    ( set -x; docker image pull "$BUILD_CACHE_FROM" ) || true
    cmd="--target $BUILD_CACHE_FROM"
  fi

  while IFS='=' read -r name value ; do
    if [[ -z $value ]]; then
      cmd+="--build-arg $name "
    else
      cmd+="--build-arg $name=$value "
    fi
  done < <(env | grep ^BUILD_ARG | cut -d'_' -f3- | sort )

  cmd+="--tag $CI_REGISTRY_IMAGE "
  cmd+="--file ${BUILD_DOCKERFILE:-Dockerfile} "
  cmd+="${BUILD_CONTEXT:-.}"

  ( set -x; $cmd)
}

docker:compose:build() {
  true
}

docker:image:test() {
  true
}

docker:image:push() {
  true
}

docker:image:tag() {
  true
}
