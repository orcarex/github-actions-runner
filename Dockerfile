FROM ubuntu:22.04

# 设置 UTF-8 环境
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 安装依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    unzip \
    build-essential \
    python3 \
    python3-pip \
    docker.io \
    openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# 配置 Git UTF-8
RUN git config --global core.quotepath false

# 创建 runner 用户
RUN useradd -m -s /bin/bash runner

# 设置工作目录
WORKDIR /home/runner

# 下载并安装 GitHub Actions Runner
RUN curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64.tar.gz && \
    rm actions-runner-linux-x64.tar.gz && \
    ./bin/installdependencies.sh

# 1. 作为 root 复制文件
COPY entrypoint.sh /home/runner/entrypoint.sh
COPY .env /home/runner/.env

# 2. 作为 root 修改权限
RUN chmod +x /home/runner/entrypoint.sh

# 3. 作为 root 修复所有权
RUN chown -R runner:runner /home/runner

# 创建工作目录并设置正确权限
RUN mkdir -p /home/runner/_work && \
    chmod 755 /home/runner/_work

# 修复所有权限（确保 runner 用户可以读写所有目录）
RUN chown -R runner:runner /home/runner && \
    chmod -R u+rwx /home/runner


USER runner

ENTRYPOINT ["/home/runner/entrypoint.sh"]