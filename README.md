# Alist 一键管理脚本 for PVE 9.0 LXC

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-orange.svg)](https://www.debian.org/)

专为 PVE 9.0 LXC 容器设计的 Alist 完整管理解决方案，提供一键安装、配置、管理和维护功能。

## ✨ 特性

- 🚀 **一键安装** - 自动检测架构，下载最新版本并完成配置
- 🔧 **完整管理** - 启动、停止、重启、状态查看
- 🔐 **安全便捷** - 密码重置、端口修改
- 📊 **日志查看** - 实时查看运行日志，快速排查问题
- 🔄 **在线更新** - 一键更新到最新版本，失败自动回滚
- 🗑️ **干净卸载** - 完整清理所有文件和配置
- 🎨 **友好界面** - 彩色交互式菜单，操作简单直观
- 🏗️ **多架构支持** - AMD64、ARM64、ARMv7

## 📋 系统要求

- **操作系统**: Debian/Ubuntu (PVE 9.0 LXC 容器)
- **权限**: root 用户
- **网络**: 需要访问 GitHub
- **依赖**: curl, wget, tar, systemd (脚本自动安装)

## 🚀 快速开始

### 方法一：下载运行

```bash
# 1. 下载脚本
wget https://raw.githubusercontent.com/zzh106/-Alist-LXC-/main/alist-manager.sh

# 2. 添加执行权限
chmod +x alist-manager.sh

# 3. 运行脚本
./alist-manager.sh
```

### 方法二：一键执行

```bash
bash <(curl -Ls https://raw.githubusercontent.com/zzh106/-Alist-LXC-/main/install.sh)
```

### 方法三：克隆仓库

```bash
# 克隆项目
git clone https://github.com/zzh106/-Alist-LXC-.git
cd alist-lxc-manager

# 运行脚本
chmod +x alist-manager.sh
./alist-manager.sh
```

## 📖 功能菜单

```
================================
  Alist 管理脚本 for PVE 9.0
================================

  1. 安装 Alist      - 自动安装最新版本
  2. 卸载 Alist      - 完全清理所有文件
  3. 启动 Alist      - 启动服务
  4. 停止 Alist      - 停止服务
  5. 重启 Alist      - 重启服务
  6. 查看状态        - 查看运行状态和配置
  7. 修改端口        - 修改 Web 访问端口
  8. 重置密码        - 重置管理员密码
  9. 查看日志        - 查看最近日志
 10. 更新 Alist      - 更新到最新版本
  0. 退出脚本
```

## 📝 功能详解

### 1. 安装 Alist

自动完成以下步骤：
- ✅ 检测系统架构（AMD64/ARM64/ARMv7）
- ✅ 获取最新版本信息
- ✅ 安装必要依赖
- ✅ 下载并解压 Alist
- ✅ 创建 systemd 服务
- ✅ 启动服务并显示管理员密码

**安装信息**：
- 安装路径: `/opt/alist`
- 配置文件: `/opt/alist/data/config.json`
- 默认端口: `5244`
- 默认用户: `admin`

### 2. 卸载 Alist

完整清理所有相关文件：
- 停止并禁用服务
- 删除 systemd 服务文件
- 删除安装目录和所有数据
- 清理系统配置

⚠️ **警告**: 此操作会删除所有数据，需要输入 `yes` 确认

### 3-5. 服务管理

标准的 systemd 服务管理：
- **启动**: 启动 Alist 服务
- **停止**: 停止 Alist 服务
- **重启**: 重启服务（修改配置后使用）

### 6. 查看状态

显示完整的运行状态信息：
- 服务运行状态
- Alist 版本信息
- 监听端口号
- Web 访问地址
- 安装路径
- 配置文件位置
- systemd 服务详细状态

### 7. 修改端口

动态修改 Web 访问端口：
- 显示当前端口
- 验证新端口号（1-65535）
- 检测端口占用情况
- 自动更新配置并重启服务

**使用示例**：
```
当前端口: 5244
请输入新端口号 (1-65535): 8080
正在停止服务...
配置文件已更新
正在启动服务...
端口已成功修改为: 8080
新访问地址: http://192.168.1.100:8080
```

### 8. 重置密码

快速重置管理员密码：
- 生成新的随机密码
- 显示用户名和新密码
- 无需停止服务

### 9. 查看日志

查看最近 50 行运行日志，方便排查问题。

**手动查看日志命令**：
```bash
journalctl -u alist -f              # 实时日志
journalctl -u alist -n 100          # 最近 100 行
journalctl -u alist --since today   # 今天的日志
```

### 10. 更新 Alist

安全的在线更新流程：
- 获取最新版本信息
- 备份当前版本
- 下载并安装新版本
- 验证更新结果
- 失败时自动回滚到备份版本

## 🔧 手动管理命令

### 服务管理

```bash
systemctl start alist       # 启动服务
systemctl stop alist        # 停止服务
systemctl restart alist     # 重启服务
systemctl status alist      # 查看状态
systemctl enable alist      # 开机自启
systemctl disable alist     # 禁用自启
```

### 密码管理

```bash
cd /opt/alist
./alist admin random        # 生成随机密码
./alist admin set 新密码    # 设置指定密码
```

### 配置文件

```bash
# 查看配置
cat /opt/alist/data/config.json

# 编辑配置
nano /opt/alist/data/config.json

# 配置修改后需要重启
systemctl restart alist
```

## 📁 文件结构

```
/opt/alist/
├── alist                    # 主程序
├── data/
│   ├── config.json          # 配置文件
│   ├── data.db              # 数据库文件
│   ├── temp/                # 临时文件目录
│   └── log/
│       └── log.log          # 日志文件

/etc/systemd/system/
└── alist.service            # systemd 服务文件
```

## ⚙️ 配置说明

### 基本配置 (config.json)

```json
{
  "force": false,
  "site_url": "",
  "http_port": 5244,
  "jwt_secret": "随机生成的密钥",
  "token_expires_in": 48,
  "database": {
    "type": "sqlite3",
    "db_file": "data/data.db"
  }
}
```

### 修改端口

```json
{
  "http_port": 8080
}
```

### 启用 HTTPS

```json
{
  "scheme": {
    "https": true,
    "cert_file": "/path/to/cert.pem",
    "key_file": "/path/to/key.pem"
  }
}
```

### 使用 MySQL/PostgreSQL

```json
{
  "database": {
    "type": "mysql",
    "host": "localhost",
    "port": 3306,
    "user": "alist",
    "password": "your_password",
    "name": "alist"
  }
}
```

## 🔍 故障排查

### 问题 1: 服务启动失败

```bash
# 查看详细日志
journalctl -u alist -n 50 --no-pager

# 检查端口占用
netstat -tuln | grep 5244
# 或
ss -tuln | grep 5244

# 手动启动测试
cd /opt/alist && ./alist server
```

### 问题 2: 无法访问 Web 界面

**检查清单**：
1. 服务是否运行: `systemctl status alist`
2. 端口是否正确: `grep http_port /opt/alist/data/config.json`
3. 防火墙规则: `iptables -L -n | grep 5244`
4. LXC 容器网络配置

### 问题 3: GitHub 下载失败

**解决方案**：

```bash
# 方法 1: 使用代理
export https_proxy=http://your-proxy:port
./alist-manager.sh

# 方法 2: 手动下载
wget https://github.com/alist-org/alist/releases/download/v3.36.0/alist-linux-amd64.tar.gz
tar -zxf alist-linux-amd64.tar.gz
mkdir -p /opt/alist
mv alist /opt/alist/
chmod +x /opt/alist/alist

# 方法 3: 使用镜像站
# 修改脚本中的下载地址为国内镜像
```

### 问题 4: 数据迁移

```bash
# 备份数据
tar -czf alist-backup-$(date +%Y%m%d).tar.gz /opt/alist/data

# 恢复数据
tar -xzf alist-backup-20251129.tar.gz -C /
systemctl restart alist
```

## 🔐 安全建议

1. **修改默认密码**: 安装后立即修改
   ```bash
   cd /opt/alist && ./alist admin set 强密码
   ```

2. **限制访问来源**: 使用防火墙或 iptables
   ```bash
   # 只允许特定 IP 访问
   iptables -A INPUT -p tcp --dport 5244 -s 192.168.1.0/24 -j ACCEPT
   iptables -A INPUT -p tcp --dport 5244 -j DROP
   ```

3. **启用 HTTPS**: 生产环境必须启用

4. **定期备份**: 设置定时任务备份数据
   ```bash
   # 添加到 crontab
   0 2 * * * tar -czf /backup/alist-$(date +\%Y\%m\%d).tar.gz /opt/alist/data
   ```

5. **及时更新**: 定期检查并更新到最新版本

## 🎯 使用场景

### 1. 挂载阿里云盘

1. 登录 Web 界面 `http://你的IP:5244`
2. 进入 `存储` → `添加`
3. 选择 `阿里云盘Open`
4. 填写 Refresh Token
5. 保存并测试

### 2. 挂载本地存储

1. 进入 `存储` → `添加`
2. 选择 `本地存储`
3. 填写路径，如 `/mnt/data`
4. 设置权限和挂载路径

### 3. WebDAV 服务

Alist 自带 WebDAV 功能：

```
WebDAV 地址: http://你的IP:5244/dav
用户名: admin
密码: 你的密码
```

可在以下客户端使用：
- Windows 文件资源管理器
- macOS Finder
- rclone
- 各种手机文件管理器

### 4. 反向代理配置

**Nginx 配置示例**：

```nginx
server {
    listen 80;
    server_name alist.yourdomain.com;

    location / {
        proxy_pass http://localhost:5244;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket 支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## 📊 性能优化

### LXC 容器配置建议

在 PVE 主机上编辑容器配置：

```bash
nano /etc/pve/lxc/容器ID.conf
```

推荐配置：
```
cores: 2
memory: 2048
swap: 512
rootfs: local-lvm:vm-100-disk-0,size=20G
```

### Alist 配置优化

```json
{
  "max_connections": 100,
  "temp_dir": "data/temp",
  "bleve_dir": "data/bleve"
}
```

## 📚 参考资源

- [Alist 官方文档](https://alist.nn.ci/)
- [Alist GitHub](https://github.com/alist-org/alist)
- [PVE 官方文档](https://pve.proxmox.com/wiki/Main_Page)
- [详细安装指南](docs/alist-installation-guide.md)

## 📦 项目结构

```
.
├── README.md                           # 项目说明文档
├── alist-manager.sh                    # 主管理脚本
├── docs/
│   └── alist-installation-guide.md     # 详细安装使用指南
└── scripts/
    └── (预留扩展脚本目录)
```

## 🔄 版本历史

### v1.0.0 (2025-11-29)

**新功能**：
- ✨ 初始版本发布
- ✨ 一键安装、卸载功能
- ✨ 完整的服务管理（启动、停止、重启）
- ✨ 端口动态修改功能
- ✨ 管理员密码重置
- ✨ 状态查看和日志查看
- ✨ 在线更新功能
- ✨ 多架构支持（AMD64/ARM64/ARMv7）
- ✨ 彩色交互式界面
- ✨ 完善的错误处理

**技术特性**：
- systemd 服务管理
- 自动依赖安装
- 版本备份与回滚
- 端口冲突检测
- GitHub API 集成

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发计划

- [ ] 添加数据备份/恢复功能
- [ ] 添加配置导入/导出
- [ ] 支持离线安装包
- [ ] 添加更多存储驱动配置模板
- [ ] 添加性能监控功能
- [ ] 支持集群部署
- [ ] 添加自动更新检查

## 📄 许可证

MIT License

## 💡 技术支持

如有问题，请：
1. 查看 [详细文档](docs/alist-installation-guide.md)
2. 查看 [Alist 官方文档](https://alist.nn.ci/)
3. 提交 Issue

## ⭐ Star History

如果这个项目对您有帮助，请给个 Star ⭐

---

**开发者**: Linux 工程师  
**创建日期**: 2025-11-29  
**适用环境**: PVE 9.0 LXC 容器

