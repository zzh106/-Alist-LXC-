# 项目结构说明

本文档详细说明项目的目录结构和各文件的用途。

## 📁 目录树

```
一键安装Alist的LXC脚本/
├── README.md                           # 项目主说明文档
├── CHANGELOG.md                        # 版本更新日志
├── LICENSE                             # MIT 许可证
├── PROJECT_STRUCTURE.md                # 本文件 - 项目结构说明
├── .gitignore                          # Git 忽略文件配置
│
├── alist-manager.sh                    # 主管理脚本 ⭐
├── install.sh                          # 快速安装脚本
│
├── docs/                               # 文档目录
│   ├── alist-installation-guide.md     # 详细安装使用指南
│   ├── FAQ.md                          # 常见问题解答
│   └── QUICKSTART.md                   # 快速开始指南
│
└── scripts/                            # 辅助脚本目录
    ├── backup.sh                       # 数据备份脚本
    └── restore.sh                      # 数据恢复脚本
```

## 📄 文件说明

### 根目录文件

#### README.md
- **用途**: 项目主说明文档
- **内容**: 
  - 项目简介和特性
  - 快速开始指南
  - 功能详解
  - 配置说明
  - 故障排查
  - 使用场景示例
- **受众**: 所有用户

#### CHANGELOG.md
- **用途**: 版本更新日志
- **内容**:
  - 各版本的新增功能
  - 修复的问题
  - 重要变更
- **格式**: 遵循 Keep a Changelog 规范
- **受众**: 关注项目更新的用户

#### LICENSE
- **用途**: 开源许可证
- **类型**: MIT License
- **说明**: 允许自由使用、修改、分发

#### PROJECT_STRUCTURE.md
- **用途**: 项目结构说明文档（本文件）
- **内容**: 目录结构和文件说明
- **受众**: 开发者、贡献者

#### .gitignore
- **用途**: Git 版本控制忽略配置
- **内容**:
  - 备份文件
  - 临时文件
  - 日志文件
  - 编辑器配置
  - 本地配置文件

### 主脚本

#### alist-manager.sh ⭐
- **用途**: Alist 完整管理脚本（核心文件）
- **功能**:
  1. 安装 Alist
  2. 卸载 Alist
  3. 启动服务
  4. 停止服务
  5. 重启服务
  6. 查看状态
  7. 修改端口
  8. 重置密码
  9. 查看日志
  10. 更新 Alist
- **特性**:
  - 交互式菜单
  - 彩色输出
  - 错误处理
  - 架构自动检测
  - 版本自动获取
- **执行**: `./alist-manager.sh`

#### install.sh
- **用途**: 快速安装入口脚本
- **功能**:
  - 检查依赖
  - 下载主脚本
  - 自动运行
- **使用场景**: 一键在线安装
- **执行**: `bash <(curl -Ls URL/install.sh)`

### docs/ 文档目录

#### alist-installation-guide.md
- **用途**: 详细的安装使用指南
- **内容**:
  - 完整安装步骤
  - 详细功能说明
  - 配置文件详解
  - 故障排查方案
  - 安全建议
  - 性能优化
  - 实际使用案例
- **长度**: 约 350+ 行
- **受众**: 需要深入了解的用户

#### FAQ.md
- **用途**: 常见问题解答
- **结构**:
  - 安装相关（Q1-Q4）
  - 配置相关（Q5-Q8）
  - 使用相关（Q9-Q12）
  - 故障排查（Q13-Q16）
  - 性能优化（Q17-Q20）
- **格式**: Q&A 问答形式
- **受众**: 遇到问题的用户

#### QUICKSTART.md
- **用途**: 快速开始指南
- **内容**:
  - 5 分钟快速部署
  - 完整示例演示
  - 首次配置指导
  - 常用操作说明
  - 安全配置建议
- **受众**: 新手用户

### scripts/ 辅助脚本目录

#### backup.sh
- **用途**: 自动备份 Alist 数据
- **功能**:
  - 压缩备份数据目录
  - 自动清理旧备份
  - 保留指定天数的备份
- **配置**:
  - `ALIST_DIR`: Alist 安装目录
  - `BACKUP_DIR`: 备份存储目录
  - `KEEP_DAYS`: 保留天数（默认7天）
- **使用**:
  ```bash
  ./scripts/backup.sh
  # 或添加到 crontab 定时执行
  0 2 * * * /path/to/backup.sh
  ```

#### restore.sh
- **用途**: 从备份恢复数据
- **功能**:
  - 列出可用备份
  - 交互式选择备份
  - 安全恢复流程
  - 自动服务管理
- **流程**:
  1. 停止 Alist 服务
  2. 备份当前数据
  3. 恢复选定备份
  4. 启动服务
  5. 失败时自动回滚
- **使用**:
  ```bash
  ./scripts/restore.sh
  # 根据提示选择要恢复的备份
  ```

## 🔧 脚本依赖关系

```
用户
  │
  ├─→ install.sh (快速入口)
  │       │
  │       └─→ alist-manager.sh (主脚本)
  │
  └─→ alist-manager.sh (直接使用)
          │
          ├─→ 安装功能 → 创建服务
          ├─→ 管理功能 → systemd
          ├─→ 更新功能 → GitHub API
          └─→ 其他功能
```

## 📊 文件大小参考

| 文件 | 行数 | 大小 | 类型 |
|------|------|------|------|
| alist-manager.sh | ~590 | ~20KB | Bash 脚本 |
| README.md | ~600 | ~25KB | Markdown |
| alist-installation-guide.md | ~360 | ~15KB | Markdown |
| FAQ.md | ~450 | ~18KB | Markdown |
| QUICKSTART.md | ~280 | ~10KB | Markdown |
| backup.sh | ~50 | ~2KB | Bash 脚本 |
| restore.sh | ~90 | ~3KB | Bash 脚本 |
| install.sh | ~40 | ~1.5KB | Bash 脚本 |

## 🎯 使用建议

### 新手用户
1. 阅读 `README.md` 了解项目
2. 查看 `docs/QUICKSTART.md` 快速上手
3. 遇到问题查看 `docs/FAQ.md`

### 进阶用户
1. 参考 `docs/alist-installation-guide.md` 深入配置
2. 使用 `scripts/backup.sh` 设置定时备份
3. 自定义配置文件优化性能

### 开发者
1. 阅读 `PROJECT_STRUCTURE.md`（本文件）
2. 查看 `CHANGELOG.md` 了解版本历史
3. 参考 `alist-manager.sh` 源码

## 🔄 维护流程

### 添加新功能
1. 修改 `alist-manager.sh`
2. 更新 `CHANGELOG.md`
3. 更新相关文档
4. 更新版本号

### 修复问题
1. 定位问题文件
2. 修复代码
3. 记录到 `CHANGELOG.md`
4. 更新版本号（如需要）

### 更新文档
1. 保持文档与代码同步
2. 及时更新 FAQ
3. 补充使用案例

## 📦 部署清单

发布新版本时需要确保：

- [ ] 所有脚本可执行权限正确
- [ ] README.md 包含最新信息
- [ ] CHANGELOG.md 记录所有变更
- [ ] 文档与代码功能一致
- [ ] 测试所有核心功能
- [ ] 更新版本号

## 🌟 核心文件标识

- ⭐ **alist-manager.sh**: 最核心的文件，包含所有主要功能
- 📖 **README.md**: 项目门面，首先查看
- 🚀 **QUICKSTART.md**: 快速开始的最佳入口
- 💡 **FAQ.md**: 问题解决的首选

## 📝 贡献指南

如需贡献代码或文档：

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 发起 Pull Request
5. 更新相关文档

## 🔗 文件链接关系

```
README.md
    ├─ 链接到 → docs/alist-installation-guide.md
    ├─ 链接到 → docs/FAQ.md
    └─ 链接到 → CHANGELOG.md

QUICKSTART.md
    ├─ 链接到 → alist-installation-guide.md
    └─ 链接到 → FAQ.md

FAQ.md
    └─ 链接到 → alist-installation-guide.md
```

---

**维护者**: Linux 工程师  
**创建日期**: 2025-11-29  
**最后更新**: 2025-11-29

