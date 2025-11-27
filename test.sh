#!/bin/bash

# 自动导出 .env 中的所有变量
set -a
source .env
set +a

echo "RUNNER_TOKEN: $RUNNER_TOKEN"
echo "RUNNER_NAME: $RUNNER_NAME"