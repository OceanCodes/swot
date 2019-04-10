#! /bin/bash
set -x

# First, avoid redundant sanity builds by canceling existing builds
BUILDS=`curl -sSLf https://circleci.com/api/v1.1/project/github/OceanCodes/sanity\?circle-token\=${CIRCLE_TOKEN} | jq/jq -c 'map(select(.status | contains("not_running") or contains("running"))) | .[].build_num'`

if [ -n "$BUILDS" ]; then
    while read -r build_num; do
        curl -X POST https://circleci.com/api/v1.1/project/github/OceanCodes/sanity/${build_num}/cancel?circle-token=${CIRCLE_TOKEN}
    done <<< "$BUILDS"
fi

curl \
	--header "Content-Type: application/json" \
	--data '{"build_parameters": {"TRIGGER": "ide"}}' \
	--request POST \
	https://circleci.com/api/v1/project/OceanCodes/sanity/tree/master?circle-token=$CIRCLE_TOKEN
