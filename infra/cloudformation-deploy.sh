#!/bin/bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

NC='\033[0m' # No Color
RED='\033[1;31m' # Red
GREEN='\033[1;32m' # Green

# Deploy / Update the Project stage
TEMPLATE=${1}
test -s "./infra/${TEMPLATE}.yaml" || { echo -e "${RED}The template file ${TEMPLATE}.yaml empty or not exist${NC}"; exit 1; }

# Auto-export variables

PATH="/usr/local/bin:${PATH}" # use /usr/local/bin/aws if exist
PARAMETERS_DEPLOY=""
PARAMETERS_UPDATE=""

if [ ! -z "`aws cloudformation describe-stacks --stack-name=${TEMPLATE} 2>/dev/null | jq -r '.Stacks[0].StackStatus'`" ]
  then
    echo "${PARAMETERS_UPDATE}" | tr ' ' '\n' | sort
    echo
    echo "Create the change set..."
    aws cloudformation create-change-set \
        --stack-name="${TEMPLATE}" \
        --change-set-name="${TEMPLATE}-`date +\"%Y%m%d%H%M%S\"`" \
        --template-body="file://./infra/${TEMPLATE}.yaml" \
        --capabilities="CAPABILITY_IAM" \
        --capabilities="CAPABILITY_NAMED_IAM" \
#        --parameters ${PARAMETERS_UPDATE} | jq -r ".Id"
    echo
    echo -e "${GREEN}Done${NC}"
    exit 0
fi

echo "${PARAMETERS_DEPLOY}" | tr ' ' '\n' | sort
echo
echo -e "${GREEN}Deploy the template...${NC}"
if aws cloudformation deploy \
    --stack-name="${TEMPLATE}" \
    --template-file="./infra/${TEMPLATE}.yaml" \
    --capabilities="CAPABILITY_IAM" \
    --capabilities="CAPABILITY_NAMED_IAM" \
#    --parameter-overrides ${PARAMETERS_DEPLOY}
  then
    # Get Load Balancer External URL
    aws cloudformation describe-stacks \
        --stack-name="${TEMPLATE}" \
        --query="Stacks[0].Outputs[?OutputKey=='ExternalUrl'].OutputValue" \
        --output=text > externaldns.log
    # Add port to end of URL
    ex +"%s/$/:8081/g" -cwq externaldns.log
    echo -e "${GREEN}Your app URL: $(cat externaldns.log)${NC}"
fi

echo -e  "${GREEN}Done${NC}"