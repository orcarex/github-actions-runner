# **English** · [中文 (繁體)](README.zh-TW.md)

# GitHub Actions Self-Hosted Runner (Docker)

Overview
--------
This repository provides a lightweight Docker-based GitHub Actions self-hosted runner image and a sample `docker-compose` setup to quickly run a runner on private infrastructure or in the cloud. The image is built from `ubuntu:22.04`, installs common tooling, and includes the GitHub Actions Runner binary.

Audience
--------
- Engineers who want to quickly run a self-hosted GitHub Actions runner on internal or cloud hosts.
- CI/CD maintainers who need Docker-in-Docker support (via the host Docker socket) or other tools inside the runner.

Repository Contents
-------------------
- `Dockerfile` - Builds the runner image and installs required dependencies.
- `docker-compose.yml` - Example service definition (`github-runner`).
- `entrypoint.sh` - Entrypoint script that registers and starts the runner when the container starts.
- `.env` - (not tracked) Recommended place for runtime environment variables such as `RUNNER_TOKEN`.
- `test.sh` - Small helper script to print environment variables for quick verification.

Quickstart
----------
1. Clone the repository and change into the directory:

```bash
git clone <repo-url>
cd github-actions-runner
```

2. Create a `.env` file at the repository root with at least the following values:

```env
# example .env
RUNNER_TOKEN=ghp_...        # Token from GitHub (see below)
RUNNER_NAME=runner-01       # Optional runner/container name
RUNNER_LABELS="docker,X64,runner-01,self-hosted,Linux"
```

3. Start the runner using docker-compose:

```bash
# Run in foreground (shows logs)
docker compose up --build

# Or run in background
docker compose up -d --build
```

4. Stop and remove containers:

```bash
docker compose down
```

Security Notes
--------------
- The `docker-compose.yml` mounts the host Docker socket (`/var/run/docker.sock`) into the container. This gives the container high privileges on the host (equivalent to root). Only enable this in trusted environments or when additional containment is in place. Remove the socket mount if the runner does not need to run Docker.
- `RUNNER_TOKEN` is sensitive. Do not commit `.env` to a public repository. Use repository/org secrets or a secure secret management workflow when possible.
- Review and harden the image and installed packages for production or corporate environments.

How it Works
------------
- The `Dockerfile` installs dependencies (curl, wget, git, jq, unzip, python, docker, openjdk, etc.) and downloads/extracts the GitHub Actions Runner.
- On container start `entrypoint.sh` sources `.env` (with `set -a`), checks for existing registration (looks for `.runner`) and runs `./config.sh` to register the runner when needed. It then runs `./run.sh` to start the runner process.

Environment Variables (main)
---------------------------
- `RUNNER_TOKEN` (required): A registration token obtained from GitHub (Repository or Organization Settings → Actions → Runners → Add a new self-hosted runner).
- `RUNNER_NAME` (optional): The runner name to register; default example is `runner-01`.
- `RUNNER_LABELS` (optional): Comma-separated labels used in workflows via `runs-on`.

Local Testing
-------------
Use `test.sh` to quickly verify that `.env` is loaded correctly:

```bash
chmod +x test.sh
./test.sh
```

Upgrading the Runner Binary
--------------------------
To upgrade the GitHub Actions Runner version:
1. Update the download URL/version in the `Dockerfile`.
2. Rebuild the image and redeploy: `docker compose build --no-cache` (or `docker build`) then `docker compose up --build`.

Contributing
------------
- Issues and pull requests are welcome.
- Describe the change and testing steps in your PR.
- For breaking changes or new features, update the README and document migration steps.

Example Workflow Snippet (using self-hosted runner)
--------------------------------------------------
Use a workflow that targets the self-hosted runner labels:

```yaml
jobs:
  build:
    runs-on: [self-hosted, docker, X64]
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on self-hosted runner"
```

FAQ
---
- Q: How do I get `RUNNER_TOKEN`?
  A: Create a new self-hosted runner from your repository or organization settings (Settings → Actions → Runners) and copy the generated token.
- Q: Can I run multiple runners on the same host?
  A: Yes. Give each runner a unique `RUNNER_NAME` and separate `_work` directories or volume mounts to avoid conflicts.

License
-------
This project is licensed under the MIT License. See the `LICENSE` file for details.

Maintainers / Contact
---------------------
Open an issue in the repository for questions or contact the maintainers on the project GitHub page.