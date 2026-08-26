# Gitea API 协作流程（PR / Release）

本仓库托管在自建 Gitea 上，所有 PR 和 Release 操作均可通过 Gitea API 自动完成，无需打开网页。本文档适用于 clsswjz-gui、clsswjz-server、clsswjz-agent 三个项目（同一 Gitea 实例、同一组织 `opensource`）。

## 前置条件

- Gitea 实例：`http://139.224.41.190:13888`（API 根路径 `/api/v1`）
- 认证：使用本机 git 凭据中已存储的 token（凭据由 `git credential fill` 提供，**不要把用户名/密码/Token 写进任何文件或命令行历史**）

获取认证的方式（脚本内使用，凭据不落盘）：

```bash
# 从 git 凭据助手读取（credential.helper = store）
CRED=$(printf "protocol=http\nhost=139.224.41.190:13888\n" | git credential fill)
TOKEN_USER=$(echo "$CRED" | grep '^username=' | cut -d= -f2)
TOKEN=$(echo "$CRED" | grep '^password=' | cut -d= -f2)
AUTH="-u $TOKEN_USER:$TOKEN"
```

## API 速查

### 创建 PR

```bash
curl -s -X POST $AUTH -H "Content-Type: application/json" \
  -d '{
    "title": "fix: xxx",
    "head": "fix/my-branch",
    "base": "main",
    "body": "## 变更说明\n\n- ..."
  }' \
  "$GITEA/api/v1/repos/opensource/<repo>/pulls"
```

响应中的 `number` 即 PR 编号，`html_url` 是页面链接。

### 查看 PR 状态

```bash
curl -s $AUTH "$GITEA/api/v1/repos/opensource/<repo>/pulls/<number>"
# 关注字段：state (open/closed)、merged (true/false)、mergeable
```

### 合并 PR

```bash
curl -s -X POST $AUTH -H "Content-Type: application/json" \
  -d '{"Do": "merge"}' \
  "$GITEA/api/v1/repos/opensource/<repo>/pulls/<number>/merge"
```

HTTP 200 即成功；合并后 `state=closed`、`merged=true`。

### 创建 Release

```bash
curl -s -X POST $AUTH -H "Content-Type: application/json" \
  -d '{
    "tag_name": "v1.6.0",
    "name": "发版 v1.6.0",
    "body": "<CHANGELOG 中该版本的内容>",
    "draft": false,
    "prerelease": false
  }' \
  "$GITEA/api/v1/repos/opensource/<repo>/releases"
```

> tag 需先在本地打好并 push：`git tag v1.6.0 && git push origin v1.6.0`

### 上传构建产物到 Release

```bash
# 先查 release id（按 tag 查）
RELEASE_ID=$(curl -s $AUTH "$GITEA/api/v1/repos/opensource/<repo>/releases/tags/v1.6.0" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

curl -s -X POST $AUTH \
  -F "attachment=@build/app-release.apk" \
  "$GITEA/api/v1/repos/opensource/<repo>/releases/$RELEASE_ID/assets?name=app-release.apk"
```

## 标准工作流

### 日常开发（feature / bugfix）

```bash
# 1. 从最新 main 切分支开发
git checkout main && git pull origin main
git checkout -b feat/xxx   # 或 fix/xxx

# 2. 开发完成 push 后，用 API 创建 PR（标题取提交主题）
# 3. 确认 mergeable: true 后 API 合并
# 4. 同步本地 main
git checkout main && git pull origin main
```

### 发版

1. `git checkout main && git pull`
2. 更新版本号与 CHANGELOG（gui 项目见 `docs/release_guide.md`）
3. 提交并 push 到 main
4. 打 tag 并 push：`git tag vX.Y.Z && git push origin vX.Y.Z`
5. API 创建 Release（正文取 CHANGELOG 对应版本条目）
6. （可选）构建产物后通过 API 上传附件

## 注意事项

- **main 分支严禁直接开发**：只允许项目配置、发版（版本号/CHANGELOG）、文档/CI 调整；功能走 `feat/`，修复走 `fix/`，经 PR 合入
- **敏感信息**：token 只从 `git credential fill` 读取，禁止写入文档、脚本常量或提交记录
- 三个仓库的 API 调用方式完全一致，仅 `<repo>` 不同：`clsswjz-gui` / `clsswjz-server` / `clsswjz-agent`
