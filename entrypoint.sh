#!/bin/bash

# 自动导出 .env 中的所有变量
set -a
source .env
set +a

# 检查是否已配置
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