#!/bin/bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

NC='\033[0m' # No Color
RED='\033[1;31m' # Red
GREEN='\033[1;32m' # Green
CLUSTER_NAME="pizza-app"
SERVICE_NAME="pizza-app"
STACK_NAME_ECS="cf-ecs-pizza"
STACK_NAME_NETWORK="cf-base-network"


echo -e "${RED}Delete CloudFormation ECS stack${NC}"
aws ecs delete-service --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --force >/dev/null 2>&1
aws ecs stop-task --cluster "${CLUSTER_NAME}" --task $(aws ecs list-tasks --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --output text --query taskArns[0]) >/dev/null 2>&1
aws cloudformation delete-stack --stack-name "${STACK_NAME_ECS}"

echo -e "${RED}Delete CloudFormation base-network stack${NC}"
aws cloudformation delete-stack --stack-name "${STACK_NAME_NETWORK}"

echo -e "${GREEN}Done${NC}"
