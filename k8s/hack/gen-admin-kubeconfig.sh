#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT
source $ROOT/hack/lib.sh

O=system:masters
CN=kubernetes-admin
SERVER=$1

hack::gencert $O $CN
hack::genkubeconfig $SERVER $CN
