#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT
source $ROOT/hack/lib.sh

INVENTORY=output/all.ini
$ROOT/hack/gen-ansible-inventory.sh > $INVENTORY

for h in $hosts; do
    ansible -i $INVENTORY $h -a "kill $(ps -C kube-apiserver -opid --no-headers)"
    ansible -i $INVENTORY $h -a "kill $(ps -C kube-controller-manager -opid --no-headers)"
    ansible -i $INVENTORY $h -a "kill $(ps -C kube-scheduler -opid --no-headers)"
    kubectl -n kube-system get pods -l tier=control-plane
done
