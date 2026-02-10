# NodeCrypt Docker 部署指南

## 📦 部署到 VPS

### 1️⃣ 准备工作

确保您的 VPS 已安装：
- Docker
- Docker Compose

### 2️⃣ 上传文件

将整个 `nodecrypt` 文件夹上传到 VPS：

```bash
# 方法 1: 使用 scp
scp -r nodecrypt/ user@your-vps-ip:/path/to/destination/

# 方法 2: 使用 rsync（推荐，支持断点续传）
rsync -avz --progress nodecrypt/ user@your-vps-ip:/path/to/destination/

# 方法 3: 使用 Git（如果您有 Git 仓库）
# 在 VPS 上执行：
git clone your-repo-url
cd nodecrypt
```

### 3️⃣ 构建和启动

SSH 登录到 VPS，进入项目目录：

```bash
cd /path/to/nodecrypt

# 构建镜像
docker-compose build

# 启动容器（后台运行）
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 4️⃣ 访问应用

在浏览器中访问：
```
http://your-vps-ip:8080
```

### 5️⃣ 常用命令

```bash
# 停止容器
docker-compose down

# 重启容器
docker-compose restart

# 查看运行状态
docker-compose ps

# 查看实时日志
docker-compose logs -f

# 重新构建并启动（代码更新后）
docker-compose up -d --build
```

## 🔧 配置说明

### 端口修改

如果需要修改端口，编辑 `docker-compose.yml`：

```yaml
ports:
  - "8080:80"  # 改为您想要的端口，如 "3000:80"
```

### 使用 Nginx 反向代理（推荐）

如果您想使用域名和 HTTPS，可以在 VPS 上配置 Nginx：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

然后使用 Certbot 配置 HTTPS：
```bash
sudo certbot --nginx -d your-domain.com
```

## ✅ 验证部署

部署成功后，您应该能够：
- ✅ 访问聊天界面
- ✅ 创建/加入房间
- ✅ 发送文本消息
- ✅ 发送文件
- ✅ **查看图片预览**（新功能）
- ✅ **播放视频**（新功能）

## 🔄 更新代码

当您修改代码后，重新部署：

```bash
# 在本地构建（可选，测试用）
npm run build

# 上传到 VPS（使用 rsync 只上传修改的文件）
rsync -avz --progress nodecrypt/ user@your-vps-ip:/path/to/nodecrypt/

# 在 VPS 上重新构建并启动
cd /path/to/nodecrypt
docker-compose up -d --build
```

## 📊 资源监控

查看容器资源使用情况：
```bash
docker stats nodecrypt
```

## 🐛 故障排查

### 容器无法启动
```bash
# 查看详细日志
docker-compose logs

# 检查端口占用
sudo netstat -tulpn | grep 8080
```

### 无法访问
1. 检查防火墙规则
2. 确认端口映射正确
3. 查看容器是否运行：`docker-compose ps`

### 图片/视频预览不显示
1. 强制刷新浏览器（Ctrl+F5）
2. 检查浏览器控制台是否有错误
3. 确认使用的是最新构建的镜像
