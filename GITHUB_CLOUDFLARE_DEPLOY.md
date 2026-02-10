# GitHub 上传和 Cloudflare Workers 部署指南

## 📤 第一步：上传到 GitHub

### 1. 初始化 Git 仓库

在项目目录中打开终端（PowerShell 或 Git Bash）：

```bash
cd c:\Users\Ron063\Desktop\nodecrypt

# 初始化 Git 仓库
git init

# 添加所有文件
git add .

# 提交更改
git commit -m "feat: Add media preview support for images and videos"
```

### 2. 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `NodeCrypt` 或 `NodeCrypt-Enhanced`
   - **Description**: `Enhanced NodeCrypt with image preview and video playback support`
   - **Public** 或 **Private**（推荐 Public 以支持一键部署）
3. **不要**勾选 "Initialize this repository with a README"
4. 点击 "Create repository"

### 3. 推送到 GitHub

GitHub 会显示推送命令，复制并执行：

```bash
# 添加远程仓库（替换为您的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/NodeCrypt.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

如果需要登录，使用 GitHub Personal Access Token（不是密码）。

---

## ☁️ 第二步：部署到 Cloudflare Workers

### 方法一：一键部署（推荐）⚡

#### 1. 修改 README.md 中的部署按钮

编辑 `README.md` 文件，找到第 10 行的部署按钮：

```markdown
# 原来的（指向原作者仓库）
[![Deploy to Cloudflare Workers](https://deploy.workers.cloudflare.com/button?projectName=NodeCrypt)](https://deploy.workers.cloudflare.com/?url=https://github.com/shuaiplus/NodeCrypt)

# 改为（指向您的仓库）
[![Deploy to Cloudflare Workers](https://deploy.workers.cloudflare.com/button?projectName=NodeCrypt)](https://deploy.workers.cloudflare.com/?url=https://github.com/YOUR_USERNAME/NodeCrypt)
```

#### 2. 提交并推送更改

```bash
git add README.md
git commit -m "docs: Update deploy button to point to forked repository"
git push
```

#### 3. 点击部署按钮

1. 访问您的 GitHub 仓库页面
2. 点击 README 中的 "Deploy to Cloudflare Workers" 按钮
3. 登录 Cloudflare 账号
4. 按照提示完成部署：
   - **Project name**: `nodecrypt`（或自定义）
   - **Build command**: `npm run build`
   - **Deploy command**: `npm run deploy`
5. 等待构建和部署完成

#### 4. 访问应用

部署成功后，Cloudflare 会提供一个 URL：
```
https://nodecrypt.YOUR_SUBDOMAIN.workers.dev
```

---

### 方法二：手动部署（更灵活）🔧

#### 1. 安装 Wrangler CLI

```bash
npm install -g wrangler
```

#### 2. 登录 Cloudflare

```bash
wrangler login
```

这会打开浏览器，登录您的 Cloudflare 账号并授权。

#### 3. 修改 wrangler.toml（可选）

如果需要自定义项目名称，编辑 `wrangler.toml`：

```toml
name = "my-nodecrypt"  # 改为您想要的名称
```

#### 4. 部署

```bash
# 构建前端
npm run build

# 部署到 Cloudflare Workers
npm run deploy
```

#### 5. 访问应用

部署成功后会显示 URL：
```
https://my-nodecrypt.YOUR_SUBDOMAIN.workers.dev
```

---

## 🔄 自动同步和部署（推荐长期维护）

### 配置 GitHub Actions 自动部署

项目已经包含了自动同步 workflow，但我们需要配置 Cloudflare 自动部署。

#### 1. 获取 Cloudflare API Token

1. 访问 https://dash.cloudflare.com/profile/api-tokens
2. 点击 "Create Token"
3. 使用 "Edit Cloudflare Workers" 模板
4. 复制生成的 Token

#### 2. 添加 GitHub Secrets

1. 访问您的 GitHub 仓库
2. 进入 **Settings** → **Secrets and variables** → **Actions**
3. 点击 "New repository secret"
4. 添加以下 secrets：
   - **Name**: `CLOUDFLARE_API_TOKEN`
   - **Value**: 粘贴刚才复制的 Token
5. 再添加一个：
   - **Name**: `CLOUDFLARE_ACCOUNT_ID`
   - **Value**: 您的 Cloudflare Account ID（在 Workers 页面右侧可以找到）

#### 3. 创建自动部署 Workflow

创建文件 `.github/workflows/deploy.yml`：

```yaml
name: Deploy to Cloudflare Workers

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build
        run: npm run build
        
      - name: Deploy to Cloudflare Workers
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

现在每次推送到 `main` 分支，都会自动部署到 Cloudflare Workers！

---

## ✅ 验证部署

部署成功后，访问您的 Cloudflare Workers URL，应该能够：

1. ✅ 正常访问聊天界面
2. ✅ 创建/加入房间
3. ✅ 发送文本消息
4. ✅ 发送文件
5. ✅ **查看图片预览**（新功能）
6. ✅ **播放视频**（新功能）

---

## 🎯 总结

### 快速部署流程

```bash
# 1. 初始化并推送到 GitHub
git init
git add .
git commit -m "feat: Add media preview support"
git remote add origin https://github.com/YOUR_USERNAME/NodeCrypt.git
git push -u origin main

# 2. 部署到 Cloudflare Workers
npm run build
npm run deploy
```

### 三种部署方式对比

| 方式 | 优点 | 缺点 | 推荐场景 |
|------|------|------|----------|
| **一键部署** | 最简单，无需配置 | 需要公开仓库 | 快速体验 |
| **手动部署** | 灵活控制 | 需要手动执行 | 开发测试 |
| **自动部署** | 推送即部署 | 需要配置 Secrets | 长期维护 |

---

## 🔗 相关链接

- **Cloudflare Workers 文档**: https://developers.cloudflare.com/workers/
- **Wrangler CLI 文档**: https://developers.cloudflare.com/workers/wrangler/
- **GitHub Actions 文档**: https://docs.github.com/en/actions

---

## 💡 提示

1. **首次部署**建议使用**一键部署**，快速体验
2. **长期维护**建议配置**自动部署**，省时省力
3. 部署后记得在浏览器中**强制刷新**（Ctrl+F5）以加载最新代码
4. Cloudflare Workers 免费版有每日 10 万次请求限制，足够个人使用
