#!/usr/bin/env bash
set -e

export cluster_name=mlops-dev

# shellcheck disable=SC1090
source "$(dirname $0)"/destroy-eks.sh cluster_name
