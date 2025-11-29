# 快速开始指南

5 分钟快速部署 Alist 到你的 PVE LXC 容器。

## 🚀 最快方式

在 PVE LXC 容器中执行一条命令：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/zzh106/-Alist-LXC-/main/install.sh)
```

然后选择"1. 安装 Alist"，等待完成即可。

## 📦 标准安装流程

### 步骤 1: 准备 LXC 容器

在 PVE 中创建一个 LXC 容器：

```
模板: Debian 12 / Ubuntu 22.04
核心: 2
内存: 2048 MB
硬盘: 20 GB
网络: 桥接
```

### 步骤 2: 进入容器

```bash
# 在 PVE 主机上
pct enter 容器ID

# 或通过 SSH
ssh root@容器IP
```

### 步骤 3: 下载脚本

```bash
wget https://raw.githubusercontent.com/zzh106/-Alist-LXC-/main/alist-manager.sh
chmod +x alist-manager.sh
```

### 步骤 4: 运行安装

```bash
./alist-manager.sh
```

选择"1. 安装 Alist"

### 步骤 5: 访问 Alist

安装完成后，脚本会显示：

```
管理员信息：
  用户名: admin
  密码: xxxxxxxx
访问地址: http://192.168.1.100:5244
```

在浏览器中访问显示的地址即可！

## ⚡ 完整示例

```bash
# 1. 下载脚本
root@debian:~# wget https://raw.githubusercontent.com/zzh106/-Alist-LXC-/main/alist-manager.sh
root@debian:~# chmod +x alist-manager.sh

# 2. 运行脚本
root@debian:~# ./alist-manager.sh

================================
  Alist 管理脚本 for PVE 9.0
================================

  1. 安装 Alist
  2. 卸载 Alist
  ...

请选择操作 [0-10]: 1

[INFO] 开始安装 Alist
[INFO] 检测到系统架构: amd64
[INFO] 正在获取最新版本信息...
[INFO] 最新版本: v3.36.0
[INFO] 正在安装必要的依赖...
[INFO] 正在下载 Alist v3.36.0 (amd64)...
[INFO] 正在解压文件...
[SUCCESS] Alist 下载并安装完成
[INFO] 正在创建 systemd 服务...
[SUCCESS] systemd 服务创建完成
[INFO] 正在启动 Alist 服务...
[SUCCESS] ================================
[SUCCESS] Alist 安装完成！
[SUCCESS] ================================
[INFO] 管理员信息：
[INFO]   用户名: admin
[INFO]   密码: Ab12Cd34Ef56
[INFO] 访问地址: http://192.168.1.100:5244
[INFO] 配置文件: /opt/alist/data/config.json

# 3. 访问 Web 界面
# 打开浏览器访问 http://192.168.1.100:5244
# 使用 admin / Ab12Cd34Ef56 登录
```

## 🎯 首次配置

### 1. 登录系统

使用安装时显示的用户名和密码登录。

### 2. 修改密码

1. 点击右上角头像
2. 选择"个人资料"
3. 修改密码

### 3. 添加存储

#### 示例：添加阿里云盘

1. 进入"存储"页面
2. 点击"添加"
3. 选择"阿里云盘Open"
4. 填写配置：
   - 挂载路径: `/aliyun`
   - Refresh Token: (从阿里云盘获取)
5. 保存

#### 示例：添加本地存储

1. 进入"存储"页面
2. 点击"添加"
3. 选择"本地存储"
4. 填写配置：
   - 挂载路径: `/local`
   - 根文件夹路径: `/mnt/data`
5. 保存

### 4. 访问文件

在主页即可看到添加的存储，点击进入浏览文件。

## 🔧 常用操作

### 修改端口

```bash
./alist-manager.sh
# 选择 "7. 修改端口"
# 输入新端口，如 8080
```

### 重置密码

```bash
./alist-manager.sh
# 选择 "8. 重置密码"
```

### 查看状态

```bash
./alist-manager.sh
# 选择 "6. 查看状态"
```

### 查看日志

```bash
./alist-manager.sh
# 选择 "9. 查看日志"
```

## 🔐 安全配置

### 1. 修改默认密码

**重要**: 安装后立即修改默认密码！

### 2. 限制访问 IP

```bash
# 只允许局域网访问
iptables -A INPUT -p tcp --dport 5244 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 5244 -j DROP
```

### 3. 启用 HTTPS

编辑 `/opt/alist/data/config.json`:

```json
{
  "scheme": {
    "https": true,
    "cert_file": "/path/to/cert.pem",
    "key_file": "/path/to/key.pem"
  }
}
```

## 📱 移动端访问

### 使用 WebDAV

配置信息：
```
服务器: http://你的IP:5244/dav
用户名: admin
密码: 你的密码
```

支持的 App：
- **iOS**: Documents, FileBrowser, FE File Explorer
- **Android**: ES文件浏览器, Solid Explorer, FX File Explorer

## 🆘 遇到问题？

### 无法访问 Web 界面

1. 检查服务状态
   ```bash
   systemctl status alist
   ```

2. 检查防火墙
   ```bash
   ufw status
   ```

3. 检查端口
   ```bash
   netstat -tuln | grep 5244
   ```

### 忘记密码

```bash
cd /opt/alist
./alist admin random
```

### 服务无法启动

查看日志：
```bash
journalctl -u alist -n 50
```

## 📚 下一步

- 阅读 [详细文档](alist-installation-guide.md)
- 查看 [常见问题](FAQ.md)
- 访问 [Alist 官网](https://alist.nn.ci/)

## 💡 提示

- 定期备份数据：`/opt/alist/data`
- 及时更新版本：使用脚本的"10. 更新 Alist"
- 使用强密码
- 生产环境建议启用 HTTPS

---

现在开始享受 Alist 带来的便利吧！🎉

