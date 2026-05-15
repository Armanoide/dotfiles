#!/bin/bash

set -e

cd "$(dirname "$0")"

source .env

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "SCRIPT_DIR: $SCRIPT_DIR"

DIR_NAME_HINDSIGHT="hindsight_"
SRC_HINDSIGHT="$SCRIPT_DIR/../../dev/$DIR_NAME_HINDSIGHT"

if [ "$(whoami)" != 'opencode' ]; then
  SRC_HINDSIGHT="$PATH_CONTEXT/$DIR_NAME_HINDSIGHT"
fi


echo "Building hindsight:latest from $SRC_HINDSIGHT"
docker build \
  -f Dockerfile \
  -t hindsight:latest \
  --build-arg INCLUDE_API=true \
  --build-arg INCLUDE_CP=true \
  --build-arg INCLUDE_LOCAL_MODELS=true \
  --build-arg PRELOAD_ML_MODELS=true \
  "$SRC_HINDSIGHT"
