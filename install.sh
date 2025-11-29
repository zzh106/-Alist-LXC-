#!/bin/bash

#================================================================
# Alist 快速安装脚本
# 此脚本用于快速下载并运行主管理脚本
#================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Alist 快速安装程序${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}错误: 此脚本必须以 root 权限运行${NC}"
    exit 1
fi

# 检查依赖
echo -e "${BLUE}[1/3]${NC} 检查依赖..."
if ! command -v wget &> /dev/null; then
    echo "正在安装 wget..."
    apt-get update -qq && apt-get install -y wget
fi

# 下载主脚本
echo -e "${BLUE}[2/3]${NC} 下载管理脚本..."
SCRIPT_URL="https://raw.githubusercontent.com/你的仓库/main/alist-manager.sh"
wget -q -O /tmp/alist-manager.sh "$SCRIPT_URL"

if [ $? -ne 0 ]; then
    echo -e "${RED}下载失败！请检查网络连接${NC}"
    exit 1
fi

chmod +x /tmp/alist-manager.sh

# 运行主脚本
echo -e "${BLUE}[3/3]${NC} 启动管理脚本..."
echo ""
/tmp/alist-manager.sh

# 清理临时文件
rm -f /tmp/alist-manager.sh

