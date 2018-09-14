#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
#apt-get update -y
apt-get update -o Dir::Etc::sourcelist="sources.list.d/kirk.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
apt-get install -y kubelet=1.9.7-41+4e5d7182bd8ac0-00
