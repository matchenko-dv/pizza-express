#!/bin/bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

NC='\033[0m' # No Color
RED='\033[1;31m' # Red
GREEN='\033[1;32m' # Green
URL="localhost:8081"

# Check if docker-compose is installed
if [ -x "$(command -v docker-compose)" ]; then
   # Up containers as deamons
   docker-compose up -d
   # Check service URL
   while :; do
     sleep 20
     curl -sS --fail -o /dev/null "${URL}" && break
   done
   echo -e "Service ${URL} is in ${GREEN}RUNNING${NC} state"
else
   echo -e "${RED}Please install docker-compose [ https://docs.docker.com/compose/install ]${NC}"
fi