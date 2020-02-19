#!/bin/bash
set -x

curl -X POST https://circleci.com/api/v2/project/gh/OceanCodes/sanity/pipeline?circle-token=$CIRCLE_TOKEN \
	-H "Content-Type: application/json"
