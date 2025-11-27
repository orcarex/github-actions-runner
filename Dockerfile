FROM ubuntu:22.04

# set UTF-8 environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# install dependencies
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

# configure Git UTF-8
RUN git config --global core.quotepath false

# create runner user
RUN useradd -m -s /bin/bash runner

# set working directory
WORKDIR /home/runner

# download and install GitHub Actions Runner
RUN curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64.tar.gz && \
    rm actions-runner-linux-x64.tar.gz && \
    ./bin/installdependencies.sh

# 1. Copy files as root
COPY entrypoint.sh /home/runner/entrypoint.sh
COPY .env /home/runner/.env

# 2. Change permissions as root
RUN chmod +x /home/runner/entrypoint.sh

# 3. Change ownership as root
RUN chown -R runner:runner /home/runner

# Create working directory and set correct permissions
RUN mkdir -p /home/runner/_work && \
    chmod 755 /home/runner/_work

# Fix all permissions (ensure runner user can read and write all directories)
RUN chown -R runner:runner /home/runner && \
    chmod -R u+rwx /home/runner


USER runner

ENTRYPOINT ["/home/runner/entrypoint.sh"]