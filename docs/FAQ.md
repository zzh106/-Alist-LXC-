# 常见问题解答 (FAQ)

## 目录

- [安装相关](#安装相关)
- [配置相关](#配置相关)
- [使用相关](#使用相关)
- [故障排查](#故障排查)
- [性能优化](#性能优化)

## 安装相关

### Q1: 支持哪些系统？

**A**: 本脚本主要支持：
- Debian 10/11/12
- Ubuntu 20.04/22.04/24.04
- PVE 9.0 LXC 容器

其他基于 Debian 的系统理论上也可以使用。

### Q2: 需要什么权限？

**A**: 必须使用 root 权限运行脚本：
```bash
sudo ./alist-manager.sh
# 或直接使用 root 账户
su -
./alist-manager.sh
```

### Q3: 安装失败怎么办？

**A**: 常见原因和解决方法：

1. **网络问题** - 无法访问 GitHub
   ```bash
   # 使用代理
   export https_proxy=http://your-proxy:port
   ```

2. **依赖缺失** - 缺少必要工具
   ```bash
   apt-get update
   apt-get install -y curl wget tar systemd
   ```

3. **端口占用** - 5244 端口被占用
   ```bash
   # 查看占用进程
   netstat -tuln | grep 5244
   # 或使用脚本的修改端口功能
   ```

### Q4: 如何离线安装？

**A**: 手动下载安装包：

```bash
# 1. 下载对应架构的安装包
# AMD64: https://github.com/alist-org/alist/releases/download/v3.36.0/alist-linux-amd64.tar.gz
# ARM64: https://github.com/alist-org/alist/releases/download/v3.36.0/alist-linux-arm64.tar.gz

# 2. 解压并安装
tar -zxf alist-linux-amd64.tar.gz
mkdir -p /opt/alist
mv alist /opt/alist/
chmod +x /opt/alist/alist

# 3. 创建服务（使用脚本或手动创建）
```

## 配置相关

### Q5: 如何修改端口？

**A**: 三种方法：

**方法 1**: 使用脚本（推荐）
- 运行脚本，选择"7. 修改端口"

**方法 2**: 手动修改配置文件
```bash
nano /opt/alist/data/config.json
# 修改 "http_port": 5244 为新端口
systemctl restart alist
```

**方法 3**: 命令行修改
```bash
sed -i 's/"http_port": 5244/"http_port": 8080/g' /opt/alist/data/config.json
systemctl restart alist
```

### Q6: 如何启用 HTTPS？

**A**: 编辑配置文件：

```json
{
  "scheme": {
    "https": true,
    "cert_file": "/path/to/your/cert.pem",
    "key_file": "/path/to/your/key.pem"
  }
}
```

使用 Let's Encrypt 获取免费证书：
```bash
apt-get install certbot
certbot certonly --standalone -d your-domain.com
```

### Q7: 忘记管理员密码怎么办？

**A**: 使用脚本重置（推荐）：
- 运行脚本，选择"8. 重置密码"

或手动重置：
```bash
cd /opt/alist
./alist admin random    # 生成随机密码
./alist admin set 新密码  # 设置指定密码
```

### Q8: 如何更改数据库？

**A**: 从 SQLite 迁移到 MySQL：

1. 备份现有数据
   ```bash
   cd /opt/alist
   ./alist export
   ```

2. 修改配置文件
   ```json
   {
     "database": {
       "type": "mysql",
       "host": "localhost",
       "port": 3306,
       "user": "alist",
       "password": "your_password",
       "name": "alist",
       "table_prefix": "x_"
     }
   }
   ```

3. 导入数据
   ```bash
   ./alist import
   systemctl restart alist
   ```

## 使用相关

### Q9: 如何添加存储？

**A**: Web 界面操作：

1. 登录 `http://你的IP:5244`
2. 进入"存储"菜单
3. 点击"添加"
4. 选择存储类型（阿里云盘、本地存储等）
5. 填写必要信息
6. 保存并测试

### Q10: WebDAV 如何使用？

**A**: WebDAV 地址：
```
服务器: http://你的IP:5244/dav
用户名: admin
密码: 你的密码
```

客户端配置：
- **Windows**: 映射网络驱动器
- **macOS**: Finder → 前往 → 连接服务器
- **Linux**: 使用 davfs2 挂载
- **手机**: 使用支持 WebDAV 的文件管理器

### Q11: 如何设置反向代理？

**A**: Nginx 配置示例：

```nginx
server {
    listen 80;
    server_name alist.example.com;
    
    location / {
        proxy_pass http://127.0.0.1:5244;
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

### Q12: 支持哪些存储？

**A**: Alist 支持众多存储，包括但不限于：

**国内常用**:
- 阿里云盘
- 百度网盘
- 天翼云盘
- 夸克网盘
- 迅雷云盘
- 123云盘

**国际常用**:
- Google Drive
- OneDrive
- Dropbox
- Amazon S3
- WebDAV

**其他**:
- 本地存储
- FTP/SFTP
- SMB
- NFS

## 故障排查

### Q13: 服务无法启动？

**A**: 排查步骤：

1. 查看详细日志
   ```bash
   journalctl -u alist -n 50 --no-pager
   ```

2. 检查端口占用
   ```bash
   netstat -tuln | grep 5244
   ```

3. 测试手动启动
   ```bash
   cd /opt/alist
   ./alist server
   ```

4. 检查配置文件
   ```bash
   cat /opt/alist/data/config.json
   ```

### Q14: 无法访问 Web 界面？

**A**: 检查清单：

1. 服务状态
   ```bash
   systemctl status alist
   ```

2. 防火墙规则
   ```bash
   # Debian/Ubuntu (ufw)
   ufw allow 5244
   
   # 或直接查看
   iptables -L -n | grep 5244
   ```

3. LXC 容器网络
   - 检查容器 IP：`ip addr`
   - 检查宿主机网络配置
   - 尝试从宿主机访问

4. 浏览器缓存
   - 清除浏览器缓存
   - 使用无痕模式
   - 尝试其他浏览器

### Q15: 上传/下载速度慢？

**A**: 优化建议：

1. 增加 LXC 容器资源
   ```bash
   # 在 PVE 主机编辑
   nano /etc/pve/lxc/容器ID.conf
   # 增加 CPU 和内存
   cores: 4
   memory: 4096
   ```

2. 调整 Alist 配置
   ```json
   {
     "max_connections": 200
   }
   ```

3. 使用 CDN 加速

4. 检查网络带宽

### Q16: 数据丢失怎么办？

**A**: 恢复方法：

1. 从备份恢复
   ```bash
   # 使用恢复脚本
   ./scripts/restore.sh
   ```

2. 如果没有备份
   - 检查 `/opt/alist/data.old.*` 目录
   - 可能在更新时有自动备份

3. 预防措施
   - 定期备份数据
   - 设置自动备份任务
   ```bash
   # 添加到 crontab
   0 2 * * * /path/to/backup.sh
   ```

## 性能优化

### Q17: 如何提升性能？

**A**: 优化策略：

1. **容器资源优化**
   ```
   cores: 4
   memory: 4096
   swap: 1024
   ```

2. **使用 SSD 存储**
   - 将容器磁盘放在 SSD 上
   - 数据目录使用 SSD

3. **启用缓存**
   ```json
   {
     "temp_dir": "data/temp"
   }
   ```

4. **使用专业数据库**
   - 从 SQLite 迁移到 MySQL/PostgreSQL
   - 适合大量文件场景

5. **CDN 加速**
   - 配置 CDN
   - 加速静态资源

### Q18: 如何监控性能？

**A**: 监控方法：

1. 系统资源
   ```bash
   # CPU 和内存
   top
   htop
   
   # 磁盘 I/O
   iotop
   
   # 网络
   iftop
   ```

2. Alist 日志
   ```bash
   tail -f /opt/alist/data/log/log.log
   ```

3. systemd 日志
   ```bash
   journalctl -u alist -f
   ```

### Q19: 大量文件如何优化？

**A**: 针对性优化：

1. 使用 MySQL/PostgreSQL 数据库
2. 启用索引加速
3. 增加服务器内存
4. 使用分布式存储
5. 定期清理缓存

### Q20: 如何设置定时任务？

**A**: 常用定时任务：

```bash
# 编辑 crontab
crontab -e

# 每天凌晨 2 点备份
0 2 * * * /path/to/scripts/backup.sh

# 每周日凌晨 3 点重启服务
0 3 * * 0 systemctl restart alist

# 每小时清理临时文件
0 * * * * find /opt/alist/data/temp -type f -mtime +1 -delete
```

## 更多问题

如果以上内容没有解决您的问题：

1. 查看 [详细文档](alist-installation-guide.md)
2. 访问 [Alist 官方文档](https://alist.nn.ci/)
3. 搜索 [GitHub Issues](https://github.com/alist-org/alist/issues)
4. 提交新的 Issue

---

**文档更新日期**: 2025-11-29  
**适用版本**: v1.0.0+

