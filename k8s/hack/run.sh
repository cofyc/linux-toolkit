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
    #ansible -i $INVENTORY $h -m shell -a 'apt-get update -o Dir::Etc::sourcelist="sources.list.d/kirk.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"; apt-get install kubelet=1.9.7-22+d1c9c68c6b14d2-00'
    #ansible -i $INVENTORY $h -m shell -a 'docker volume prune -f'
    ansible -i $INVENTORY $h -m shell -a 'docker volume ls'
done
