#!/bin/bash

set -o pipefail # trace ERR through pipes
set -o errtrace # trace ERR through 'time command' and other functions
set -o nounset  ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit  ## set -e : exit the script if any statement returns a non-true return value

NC='\033[0m' # No Color
RED='\033[1;31m' # Red
GREEN='\033[1;32m' # Green
REGISTRY="matchden/pizza-sample-app" # Need to change registry!
IMAGE_TAG="latest"
DOCKERFILE_PATH="./docker/Dockerfile"

# Check if Docker is installed
if [ -x "$(command -v docker)" ]; then
   echo ">> Build the image"
   docker build -t ${REGISTRY}:${IMAGE_TAG} -f ${DOCKERFILE_PATH} . || exit 1
   echo "Push the image to registry"
   docker push ${REGISTRY}:${IMAGE_TAG} || exit 2
   echo "> Clear"
   docker rmi ${REGISTRY}:${IMAGE_TAG}  >/dev/null 2>&1
   echo -e "${GREEN}Done${NC}"
else
   echo -e "${RED}Please install docker [ https://docs.docker.com/engine/install ]${NC}"
fi
