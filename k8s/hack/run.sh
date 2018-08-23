#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT
source $ROOT/hack/lib.sh

hosts=$(kubectl get nodes -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

script=$ROOT/$1

if [ ! -e "$script" ]; then
    echo "error: $script not found"
    exit 1
fi

INVENTORY=output/all.ini
$ROOT/hack/gen-ansible-inventory.sh > $INVENTORY

src=$script
dst=/tmp/ansbile.script.$$
for h in $hosts; do
    ansible -i $INVENTORY $h -m copy -a "src=$src dest=$dst"
    ansible -i $INVENTORY $h -m shell -a "bash $dst"
done
