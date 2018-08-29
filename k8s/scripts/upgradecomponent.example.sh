#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

IMAGE=

docker pull "$IMAGE"

cp /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/kube-scheduler.yaml

sed -i "s#image: .*#image: ${IMAGE}#g" /tmp/kube-scheduler.yaml

diff -u /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/kube-scheduler.yaml

cp /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml
