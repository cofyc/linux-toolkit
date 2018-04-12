#!/bin/bash

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

source $ROOT/hack/logging.sh

CFSSL_BIN=$ROOT/output/bin/cfssl
CFSSLJSON_BIN=$ROOT/output/bin/cfssljson
CFSSLCERTINFO_BIN=$ROOT/output/cfssl-certinfo

function hack::get_cfssl_bins() {
    local VERSION=R1.2
    mkdir -p output/bin
    for b in cfssl cfssljson cfssl-certinfo; do
        curl -L https://pkg.cfssl.org/${VERSION}/${b}_linux-amd64 -o output/bin/$b
        chmod +x output/bin/$b
    done
}

function hack::gencert() {
    local O=$1
    local CN=$2

    local csrjson=$ROOT/output/${CN}.json

cat <<EOF > ${csrjson}
{
    "CN": "${CN}",
    "hosts": [],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "O": "${O}"
        }
    ]
}
EOF

    cd $ROOT/output
    $CFSSL_BIN gencert \
        -ca /etc/kubernetes/pki/ca.crt -ca-key /etc/kubernetes/pki/ca.key \
        -config $ROOT/hack/client-config.json \
        ${csrjson} | $CFSSLJSON_BIN -bare $CN
    mv "$CN-key.pem" $CN.key
    mv "$CN.pem" $CN.crt
    cd $ROOT
}

function hack::genkubeconfig() {
    local cluster=kubernetes
    local server=$1
    local cn=$2
    local USER=$cn
    local KUBECONFIG=output/$USER.conf

    # Clear first.
    test -f $KUBECONFIG && rm $KUBECONFIG

    # Configure cluster.
    kubectl --kubeconfig $KUBECONFIG config set-cluster $cluster --server=$server --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs

    # Configure client.
    kubectl --kubeconfig $KUBECONFIG config set-credentials $USER --client-certificate=output/${CN}.crt --client-key=output/${CN}.key --embed-certs

    # Configure context
    kubectl --kubeconfig $KUBECONFIG config set-context $USER@kubernetes --cluster=kubernetes --user=$USER
    kubectl --kubeconfig $KUBECONFIG config use-context $USER@kubernetes
}
