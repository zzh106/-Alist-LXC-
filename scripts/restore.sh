#!/bin/bash

#================================================================
# Alist 数据恢复脚本
# 用于从备份恢复 Alist 数据
#================================================================

# 配置
ALIST_DIR="/opt/alist"
BACKUP_DIR="/backup/alist"

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查权限
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}错误: 此脚本必须以 root 权限运行${NC}"
    exit 1
fi

# 列出可用备份
echo -e "${GREEN}可用的备份文件：${NC}\n"
backups=($(ls -t "$BACKUP_DIR"/alist-backup-*.tar.gz 2>/dev/null))

if [ ${#backups[@]} -eq 0 ]; then
    echo -e "${RED}未找到备份文件！${NC}"
    exit 1
fi

# 显示备份列表
for i in "${!backups[@]}"; do
    echo "$((i+1)). $(basename ${backups[$i]}) - $(ls -lh ${backups[$i]} | awk '{print $5}')"
done

# 选择备份
echo ""
read -p "请选择要恢复的备份 (1-${#backups[@]}): " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#backups[@]} ]; then
    echo -e "${RED}无效的选择${NC}"
    exit 1
fi

BACKUP_FILE="${backups[$((choice-1))]}"

# 确认恢复
echo -e "\n${YELLOW}警告: 恢复操作将覆盖当前数据！${NC}"
read -p "确认要恢复吗？(yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "取消恢复"
    exit 0
fi

# 停止服务
echo -e "\n${GREEN}正在停止 Alist 服务...${NC}"
systemctl stop alist

# 备份当前数据
echo -e "${GREEN}正在备份当前数据...${NC}"
if [ -d "${ALIST_DIR}/data" ]; then
    mv "${ALIST_DIR}/data" "${ALIST_DIR}/data.old.$(date +%s)"
fi

# 恢复数据
echo -e "${GREEN}正在恢复数据...${NC}"
if tar -xzf "$BACKUP_FILE" -C "$ALIST_DIR"; then
    echo -e "${GREEN}数据恢复成功！${NC}"
    
    # 清理旧备份
    rm -rf "${ALIST_DIR}"/data.old.*
    
    # 启动服务
    echo -e "${GREEN}正在启动 Alist 服务...${NC}"
    systemctl start alist
    
    if systemctl is-active --quiet alist; then
        echo -e "${GREEN}Alist 服务已启动${NC}"
    else
        echo -e "${RED}服务启动失败，请检查日志${NC}"
    fi
else
    echo -e "${RED}恢复失败！${NC}"
    
    # 恢复旧数据
    if [ -d "${ALIST_DIR}/data.old."* ]; then
        mv "${ALIST_DIR}"/data.old.* "${ALIST_DIR}/data"
        systemctl start alist
    fi
    
    exit 1
fi

