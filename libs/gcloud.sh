#!/usr/bin/env bash

[[ "$TRACE" ]] && set -x

#######################################
# Authorize access to Google Cloud with a service account
#######################################
gcloud:auth() {
  export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcloud-service-key.json"
  echo "$GOOGLE_SERVICE_KEY" > "$GOOGLE_APPLICATION_CREDENTIALS"
  gcloud auth activate-service-account --key-file "$GOOGLE_APPLICATION_CREDENTIALS"
}
