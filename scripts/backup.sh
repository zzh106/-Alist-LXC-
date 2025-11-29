#!/bin/bash

#================================================================
# Alist 数据备份脚本
# 用于定期备份 Alist 数据
#================================================================

# 配置
ALIST_DIR="/opt/alist"
BACKUP_DIR="/backup/alist"
KEEP_DAYS=7

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成备份文件名
BACKUP_FILE="alist-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

# 执行备份
echo -e "${GREEN}开始备份 Alist 数据...${NC}"
if tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" -C "$ALIST_DIR" data; then
    echo -e "${GREEN}备份成功: ${BACKUP_DIR}/${BACKUP_FILE}${NC}"
    
    # 清理旧备份
    find "$BACKUP_DIR" -name "alist-backup-*.tar.gz" -mtime +$KEEP_DAYS -delete
    echo -e "${GREEN}已清理 ${KEEP_DAYS} 天前的旧备份${NC}"
else
    echo -e "${RED}备份失败！${NC}"
    exit 1
fi

# 显示备份列表
echo -e "\n当前备份文件："
ls -lh "$BACKUP_DIR"/alist-backup-*.tar.gz 2>/dev/null || echo "无备份文件"

