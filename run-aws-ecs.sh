#!/bin/bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

NC='\033[0m' # No Color
RED='\033[1;31m' # Red
GREEN='\033[1;32m' # Green

if [ -x "$(command -v aws)" ]; then
   unset AWS_PROFILE
   export AWS_ACCESS_KEY_ID=foo # Set AWS Access Key ID
   export AWS_SECRET_ACCESS_KEY=bar # Set AWS Secret Access Key
   export AWS_DEFAULT_REGION=region # Set AWS Region
   # Run CloudFormation scripts
   echo -e "${GREEN}Run templates deployment...[It usually takes up to 10 minutes]${NC}"
   chmod +x ./infra/cloudformation-deploy.sh
   ./infra/cloudformation-deploy.sh cf-base-network && \
   ./infra/cloudformation-deploy.sh cf-ecs-pizza
else
   echo -e "${RED}Please install awscli and configure Access Keys [ https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html ]${NC}"
fi