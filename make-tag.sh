#! /bin/bash

BRANCH=${CIRCLE_BRANCH:=`git rev-parse --abbrev-ref HEAD`}

if [[ ${BRANCH} != "master" ]] && [[ ${BRANCH} != "main" ]] && [[ ${BRANCH} != release/* ]] && [[ ${BRANCH} != hotfix/* ]]; then
    echo ${BRANCH////-}
    exit
fi

COMMIT=${CIRCLE_SHA1:=`git rev-parse --verify HEAD`}

echo `date +%F`-${COMMIT:0:7}
