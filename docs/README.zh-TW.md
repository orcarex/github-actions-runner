[English](README.en.md) · **中文 (繁體)**

# GitHub Actions Self-Hosted Runner (Docker)

簡短說明
-----------------
這個專案提供一個簡單的 Docker-based GitHub Actions 自託管 runner 映像與 `docker-compose` 範例設定，方便在私有或公司基礎設施上快速啟動 runner。映像基於 `ubuntu:22.04`，預先安裝常用工具並包含 GitHub Actions Runner 二進位。

目標讀者
-----------------
- 想要快速在內部或雲端啟動 GitHub Actions self-hosted runner 的工程師
- 需要在 runner 裡執行 Docker-in-Docker（透過宿主的 Docker socket）或其他工具的 CI/CD 設定者

內容說明
-----------------
- `Dockerfile` - 建立 runner 映像檔，安裝 runner 與必要依賴
- `docker-compose.yml` - 範例服務設定 (服務名稱 `github-runner`)
- `entrypoint.sh` - container 啟動時用來註冊與啟動 runner 的腳本
- `.env` - (未追蹤) 建議放置必要的環境變數，例如 `RUNNER_TOKEN`
- `check-env.sh` - 簡單的本地檢查腳本，用來印出 env 變數（方便測試）

快速開始
-----------------
1. 複製專案並進入目錄：

```bash
git clone <repo-url>
cd github-actions-runner
```

2. 準備 `.env` 檔案（放在專案根目錄）。最少需要：

```env
# 範例 .env
RUNNER_TOKEN=ghp_...        # 從 GitHub repository/org 的 Runner 設定取得
RUNNER_NAME=runner-01       # container/runner 名稱，可選
RUNNER_LABELS="docker,X64,runner-01,self-hosted,Linux"
```

3. 使用 `docker-compose` 啟動：

```bash
# 以 foreground 運行
docker compose up --build

# 或在背景啟動
docker compose up -d --build
```

4. 停止並移除容器：

```bash
docker compose down
```

注意事項與安全性
-----------------
- `docker-compose.yml` 掛載了宿主的 Docker socket（`/var/run/docker.sock`）。這會給容器對宿主系統的高度控制權限（等同 root），請僅在信任的環境或已採取其他防護措施時使用。若不需要在 runner 裡啟動 Docker，請移除該掛載。
- `RUNNER_TOKEN` 是敏感憑證，請不要在公開儲存庫中直接提交 `.env`。建議使用 CI secret 或其他安全機制來提供 token。
- 在企業環境中，請檢查映像中安裝的套件與腳本，並依需求自行硬化映像。

如何工作（實作細節）
-----------------
- `Dockerfile` 以 root 建置映像，安裝依賴（curl,wget,git,jq,unzip,python,docker,openjdk 等），下載並解壓 GitHub Actions Runner。
- 啟動時 `entrypoint.sh` 會讀取 `.env`（使用 `set -a` 自動匯出），若尚未註冊（檢查 `.runner`），會執行 `./config.sh` 註冊 runner，之後執行 `./run.sh` 啟動 runner 程序。

環境變數（主要）
-----------------
- `RUNNER_TOKEN` (必填): 從 GitHub 取得的註冊 token。通常在 GitHub repo 或 org 的 Settings > Actions > Runners > New自託管 runner 產生。
- `RUNNER_NAME` (選填): 指定 runner 名稱，預設映像內使用 `runner-01`。
- `RUNNER_LABELS` (選填): 一組逗號分隔的 label，供 workflow 使用 `runs-on` 選取。

本地測試
-----------------
可以用 `test.sh` 來快速確認 `.env` 是否被正確讀入：

```bash
chmod +x test.sh
./test.sh
```

升級 Runner 版本
-----------------
若要升級 GitHub Actions Runner 的版本：
1. 在 `Dockerfile` 中更新下載連結版本號
2. 重新 build 映像：`docker compose build --no-cache` 或 `docker build` 然後重新部署

貢獻指南
-----------------
- 歡迎提出 issues 或 pull requests
- 請在 PR 中簡短描述變更目的與測試步驟
- 若新增功能或破壞性變更，請更新 `README.md` 並說明遷移步驟

範例工作流程片段（使用自託管 runner）
-----------------
在 GitHub Actions workflow 中使用自託管 runner 的範例：

```yaml
jobs:
  build:
    runs-on: [self-hosted, docker, X64]
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on self-hosted runner"
```

常見問題（FAQ）
-----------------
- 問：如何取得 `RUNNER_TOKEN`？
	答：到你的 repository 或 organization 的 Settings > Actions > Runners，新增一個 runner 並複製產生的 token。
- 問：可以在同一台主機啟動多個 runner 嗎？
	答：可以，請為每個 runner 設定不同的 `RUNNER_NAME` 與 `runner-work` 卷或子資料夾以避免衝突。

授權
-----------------
本專案採用 MIT License 授權。詳見 `LICENSE` 檔案。

聯絡 / 維護者
-----------------
若有問題請在 repository 中開 issue，或聯絡維護者（見 GitHub 頁面）。
