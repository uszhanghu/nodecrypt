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

如果您想使用域名和 HTTPS，可以在 VPS 上配置 Nginx。

#### ⚠️ 重要：必须启用 WebSocket 支持

NodeCrypt 依赖 WebSocket 进行实时通信，**必须在 Nginx 配置中启用 WebSocket 支持**，否则无法连接到聊天室！

#### HTTP 配置（基础版本）

创建配置文件 `/etc/nginx/sites-available/nodecrypt`：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        
        # 🔴 关键：WebSocket 支持配置
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # 其他必要的头部
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket 超时设置（可选，防止长时间连接断开）
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
}
```

**关键配置说明**：
- `proxy_http_version 1.1;` - 使用 HTTP/1.1 协议（WebSocket 必需）
- `proxy_set_header Upgrade $http_upgrade;` - 传递 Upgrade 头部
- `proxy_set_header Connection "upgrade";` - 设置 Connection 为 upgrade

启用配置：
```bash
sudo ln -s /etc/nginx/sites-available/nodecrypt /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### HTTPS 配置（推荐，生产环境）

使用 Certbot 自动配置 HTTPS：

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx

# 自动配置 SSL
sudo certbot --nginx -d your-domain.com
```

或者手动配置 HTTPS：

```nginx
# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS 配置
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL 证书配置
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # SSL 安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:8080;
        
        # 🔴 关键：WebSocket 支持配置
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # 其他必要的头部
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket 超时设置
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
}
```

#### 验证 WebSocket 配置

配置完成后，测试 WebSocket 是否正常工作：

1. 访问您的域名
2. 打开浏览器开发者工具（F12）
3. 切换到 **Network** 标签
4. 筛选 **WS**（WebSocket）
5. 尝试加入房间
6. 应该能看到 WebSocket 连接成功（状态码 101 Switching Protocols）

**如果 WebSocket 连接失败**：
- 检查 Nginx 配置中是否包含 `Upgrade` 和 `Connection` 头部
- 查看 Nginx 错误日志：`sudo tail -f /var/log/nginx/error.log`
- 确认容器正常运行：`docker ps`


### ⚠️ 使用 Nginx Proxy Manager（重要！）

如果您使用 **Nginx Proxy Manager** 进行反向代理，**必须启用 WebSocket 支持**，否则无法连接到聊天室！

#### 配置步骤：

1. **创建 Proxy Host**：
   - Domain Names: `your-domain.com`
   - Scheme: `http`
   - Forward Hostname / IP: `172.17.0.1`（Docker 网桥 IP）或容器 IP
   - Forward Port: `24643`（或您的容器端口）

2. **🔴 关键步骤：启用 WebSocket 支持**
   - 在 **Details** 标签页中
   - 找到 **Websockets Support** 选项
   - **必须打开这个开关！**
   - 如果不启用，页面会一直显示"连接中..."，无法进入聊天室

3. **配置 SSL**（推荐）：
   - 切换到 **SSL** 标签页
   - 选择 **Request a new SSL Certificate**
   - 勾选 **Force SSL**
   - 填写邮箱并同意条款

4. **其他推荐设置**：
   - ✅ Cache Assets（缓存静态资源）
   - ✅ Block Common Exploits（阻止常见攻击）
   - ✅ Websockets Support（**必须启用！**）

#### 常见问题：

**问题**：页面能打开，但一直显示"连接中..."
**原因**：未启用 WebSocket 支持
**解决**：在 Nginx Proxy Manager 中打开 **Websockets Support** 开关

**问题**：WebSocket 连接失败
**检查**：
1. 确认 WebSocket 支持已启用
2. 检查容器是否正常运行：`docker ps`
3. 查看容器日志：`docker logs nodecrypt`
4. 确认端口映射正确


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
