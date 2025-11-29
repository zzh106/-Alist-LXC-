# Alist 一键管理脚本使用指南

## 简介

这是一个专为 PVE 9.0 LXC 容器设计的 Alist 一键管理脚本。Alist 是一个支持多种存储的文件列表程序，可以方便地管理和分享各种云存储中的文件。

## 功能特性

- ✅ **一键安装**: 自动检测系统架构，下载最新版本并配置
- ✅ **完整卸载**: 清理所有文件和服务
- ✅ **服务管理**: 启动、停止、重启服务
- ✅ **端口修改**: 轻松修改监听端口
- ✅ **密码重置**: 快速重置管理员密码
- ✅ **状态查看**: 实时查看运行状态
- ✅ **日志查看**: 方便排查问题
- ✅ **在线更新**: 一键更新到最新版本
- ✅ **多架构支持**: 支持 AMD64、ARM64、ARMv7

## 系统要求

- **操作系统**: Debian/Ubuntu (PVE 9.0 LXC 容器)
- **权限**: root 用户
- **网络**: 需要访问 GitHub 下载资源
- **依赖**: curl, wget, tar, systemd (脚本会自动安装)

## 快速开始

### 1. 下载脚本

```bash
# 下载脚本
wget https://raw.githubusercontent.com/你的仓库/scripts/alist-manager.sh

# 或者使用 curl
curl -O https://raw.githubusercontent.com/你的仓库/scripts/alist-manager.sh
```

### 2. 添加执行权限

```bash
chmod +x alist-manager.sh
```

### 3. 运行脚本

```bash
./alist-manager.sh
```

## 功能详解

### 1️⃣ 安装 Alist

- 自动检测系统架构 (amd64/arm64/armv7)
- 从 GitHub 获取最新版本
- 自动安装必要依赖
- 创建 systemd 服务
- 自动启动并显示管理员密码

**安装路径**: `/opt/alist`
**配置文件**: `/opt/alist/data/config.json`
**默认端口**: `5244`

### 2️⃣ 卸载 Alist

- 停止并禁用服务
- 删除所有文件和配置
- 清理 systemd 服务

⚠️ **警告**: 此操作会删除所有数据，需要输入 `yes` 确认

### 3️⃣ 启动/停止/重启

标准的服务管理功能：
- **启动**: 启动 Alist 服务
- **停止**: 停止 Alist 服务
- **重启**: 重启 Alist 服务（修改配置后需要重启）

### 4️⃣ 查看状态

显示详细的运行状态信息：
- 服务运行状态
- 版本信息
- 监听端口
- 访问地址
- 安装路径
- systemd 服务状态

### 5️⃣ 修改端口

- 显示当前端口
- 输入新端口号 (1-65535)
- 自动检测端口占用
- 更新配置并重启服务

**示例**:
```
当前端口: 5244
请输入新端口号: 8080
```

### 6️⃣ 重置密码

- 生成新的随机管理员密码
- 显示用户名和新密码

**默认用户名**: `admin`

### 7️⃣ 查看日志

显示最近 50 行日志，方便排查问题。

**手动查看日志**:
```bash
# 查看实时日志
journalctl -u alist -f

# 查看最近 100 行
journalctl -u alist -n 100

# 查看指定时间范围
journalctl -u alist --since "2025-11-29 10:00:00"
```

### 8️⃣ 更新 Alist

- 自动检查最新版本
- 备份当前版本
- 下载并安装新版本
- 如果更新失败自动回滚

## 常用命令

### 手动管理服务

```bash
# 启动服务
systemctl start alist

# 停止服务
systemctl stop alist

# 重启服务
systemctl restart alist

# 查看状态
systemctl status alist

# 开机自启
systemctl enable alist

# 禁用自启
systemctl disable alist
```

### 手动管理密码

```bash
# 进入 Alist 目录
cd /opt/alist

# 重置随机密码
./alist admin random

# 设置指定密码
./alist admin set 你的密码
```

### 配置文件位置

```bash
# 主配置文件
/opt/alist/data/config.json

# 数据库文件
/opt/alist/data/data.db

# 日志文件
/opt/alist/data/log/log.log
```

## 配置说明

### 端口配置

在 `/opt/alist/data/config.json` 中修改：

```json
{
  "http_port": 5244
}
```

### HTTPS 配置

```json
{
  "scheme": {
    "https": true,
    "cert_file": "/path/to/cert.pem",
    "key_file": "/path/to/key.pem"
  }
}
```

### 数据库配置

默认使用 SQLite3，也可以配置为 MySQL/PostgreSQL：

```json
{
  "database": {
    "type": "mysql",
    "host": "localhost",
    "port": 3306,
    "user": "alist",
    "password": "password",
    "name": "alist",
    "table_prefix": "x_"
  }
}
```

## 故障排查

### 问题 1: 服务启动失败

```bash
# 查看详细日志
journalctl -u alist -n 50 --no-pager

# 检查端口是否被占用
netstat -tuln | grep 5244

# 测试手动启动
cd /opt/alist && ./alist server
```

### 问题 2: 无法访问 Web 界面

1. 检查服务是否运行：`systemctl status alist`
2. 检查防火墙规则：`iptables -L -n`
3. 检查端口是否正确：`cat /opt/alist/data/config.json | grep http_port`
4. 检查 LXC 容器网络配置

### 问题 3: 下载失败

如果无法访问 GitHub，可以使用代理或手动下载：

```bash
# 使用代理
export https_proxy=http://your-proxy:port
./alist-manager.sh

# 手动下载并安装
wget https://github.com/alist-org/alist/releases/download/v3.36.0/alist-linux-amd64.tar.gz
tar -zxf alist-linux-amd64.tar.gz
mv alist /opt/alist/
chmod +x /opt/alist/alist
```

### 问题 4: 数据迁移

```bash
# 备份数据
tar -czf alist-backup.tar.gz /opt/alist/data

# 恢复数据
tar -xzf alist-backup.tar.gz -C /
systemctl restart alist
```

## 安全建议

1. **修改默认密码**: 安装后立即修改默认密码
2. **限制访问**: 使用防火墙限制访问来源
3. **HTTPS**: 生产环境建议启用 HTTPS
4. **定期备份**: 定期备份数据目录
5. **更新**: 及时更新到最新版本

## 性能优化

### LXC 容器配置建议

```bash
# 在 PVE 主机上编辑容器配置
nano /etc/pve/lxc/容器ID.conf

# 建议配置
cores: 2
memory: 2048
swap: 512
```

### Alist 配置优化

```json
{
  "max_connections": 100,
  "temp_dir": "data/temp",
  "bleve_dir": "data/bleve"
}
```

## 常见使用场景

### 1. 挂载阿里云盘

1. 登录 Alist Web 界面
2. 进入 `存储` → `添加`
3. 选择 `阿里云盘Open`
4. 填写 Refresh Token
5. 保存并测试连接

### 2. 挂载本地存储

1. 进入 `存储` → `添加`
2. 选择 `本地存储`
3. 填写本地路径，如 `/mnt/data`
4. 保存

### 3. WebDAV 使用

Alist 提供 WebDAV 服务：

```
地址: http://你的IP:5244/dav
用户名: admin
密码: 你的密码
```

## 参考资源

- [Alist 官方文档](https://alist.nn.ci/)
- [Alist GitHub](https://github.com/alist-org/alist)
- [PVE 官方文档](https://pve.proxmox.com/wiki/Main_Page)

## 脚本更新日志

### v1.0.0 (2025-11-29)

- ✅ 初始版本发布
- ✅ 支持安装、卸载、重启功能
- ✅ 支持端口修改
- ✅ 支持密码重置
- ✅ 支持在线更新
- ✅ 多架构支持
- ✅ 完整的日志查看

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

