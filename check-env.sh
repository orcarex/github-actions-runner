#!/bin/bash

# auto export all variables from .env
set -a
source .env
set +a

# check if already configured
echo "RUNNER_TOKEN: $RUNNER_TOKEN"
echo "RUNNER_NAME: $RUNNER_NAME"
echo "RUNNER_LABELS: $RUNNER_LABELS"