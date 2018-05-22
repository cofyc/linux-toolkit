#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT
source $ROOT/hack/lib.sh

hosts=$(kubectl get nodes -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

INVENTORY=output/all.ini
$ROOT/hack/gen-ansible-inventory.sh > $INVENTORY

for h in $hosts; do
    echo "Operating on $h..."
    ansible -i $INVENTORY $h -m shell -a "apt-get update; apt-get install kubelet=1.7.16-38+8a4a5879c5a1a0-00"
    echo "Operating done."
done
