#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source sh-grains/grains.sh

if [[ "$GRAIN_OS" != "Ubuntu" ]]; then
    echo "error: it only support Ubuntu now, current os: $GRAIN_OS"
    exit 1
fi

ENDPOINT=http://oj776fute.bkt.clouddn.com/~kernel-ppa/

VERSION=${1:-}

if [[ -z "$VERSION" ]]; then
    echo "error: version not specified, e.g. v4.9.42"
    exit 2
fi

# TODO
