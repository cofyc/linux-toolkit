#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT
source $ROOT/hack/lib.sh

SERVER=${1:-}

if [ -z "$SERVER" ]; then
    echo "error: please specify server address"
    echo ""
    echo "Usage: $(basename $0) SERVER"
    echo ""
    exit 1
fi

# admin
O=system:masters
CN=kubernetes-admin
hack::gencert $DEFAULT_APISERVER_CA_CRT $DEFAULT_APISERVER_CA_KEY "$CN" "$O"
hack::genkubeconfig "$SERVER" "$CN"

# controller-manager
O=
CN=system:kube-controller-manager
hack::gencert $DEFAULT_APISERVER_CA_CRT $DEFAULT_APISERVER_CA_KEY "$CN" "$O"
hack::genkubeconfig "$SERVER" "$CN"

# scheduler
O=
CN=system:kube-scheduler
hack::gencert $DEFAULT_APISERVER_CA_CRT $DEFAULT_APISERVER_CA_KEY "$CN" "$O"
hack::genkubeconfig "$SERVER" "$CN"

# apiserver-kubelet-client
O=system:masters
CN=kube-apiserver-kubelet-client
hack::gencert $DEFAULT_APISERVER_CA_CRT $DEFAULT_APISERVER_CA_KEY "$CN" "$O"
hack::genkubeconfig "$SERVER" "$CN"

# front-proxy-client
O=
CN=front-proxy-client
hack::gencert $DEFAULT_APISERVER_FRONT_PROXY_CA_CRT $DEFAULT_APISERVER_FRONT_PROXY_CA_KEY "$CN" "$O"
hack::genkubeconfig "$SERVER" "$CN"
