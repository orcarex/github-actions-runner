#!/bin/bash

# auto export all variables from .env
set -a
source .env
set +a

# check if already configured
if [ ! -f ".runner" ]; then
  echo "Configuring runner..."
  ./config.sh \
    --url https://github.com/HDRenewables \
    --token $RUNNER_TOKEN \
    --name $RUNNER_NAME \
    --work _work \
    --labels $RUNNER_LABELS \
    --unattended \
    --replace
else
  echo "Runner already configured, skipping config step"
fi

# 启动 runner
echo "Starting runner..."
./run.sh