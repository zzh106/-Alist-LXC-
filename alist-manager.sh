#!/bin/bash

#================================================================
# Alist 一键管理脚本 for PVE 9.0 LXC
# 功能：安装、卸载、重启、修改端口、查看状态等
# 作者：Linux工程师
# 日期：2025-11-29
#================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
ALIST_DIR="/opt/alist"
ALIST_BIN="${ALIST_DIR}/alist"
ALIST_CONFIG="${ALIST_DIR}/data/config.json"
ALIST_SERVICE="/etc/systemd/system/alist.service"
ALIST_VERSION="latest"
ALIST_DOWNLOAD_URL=""

# 打印信息函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "此脚本必须以root权限运行！"
        exit 1
    fi
}

# 检测系统架构
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="armv7"
            ;;
        *)
            print_error "不支持的系统架构: $arch"
            exit 1
            ;;
    esac
    print_info "检测到系统架构: $ARCH"
}

# 获取最新版本号
get_latest_version() {
    print_info "正在获取最新版本信息..."
    ALIST_VERSION=$(curl -s https://api.github.com/repos/alist-org/alist/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    if [[ -z "$ALIST_VERSION" ]]; then
        print_warning "无法获取最新版本，使用默认版本 v3.36.0"
        ALIST_VERSION="v3.36.0"
    fi
    print_info "最新版本: $ALIST_VERSION"
}

# 安装依赖
install_dependencies() {
    print_info "正在安装必要的依赖..."
    apt-get update -qq
    apt-get install -y curl wget tar systemd >/dev/null 2>&1
    print_success "依赖安装完成"
}

# 下载Alist
download_alist() {
    print_info "正在下载 Alist ${ALIST_VERSION} (${ARCH})..."
    
    # 创建临时目录
    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    
    # 构建下载URL
    ALIST_DOWNLOAD_URL="https://github.com/alist-org/alist/releases/download/${ALIST_VERSION}/alist-linux-${ARCH}.tar.gz"
    
    # 下载文件
    if ! wget -q --show-progress "$ALIST_DOWNLOAD_URL"; then
        print_error "下载失败！请检查网络连接或版本信息"
        rm -rf "$tmp_dir"
        exit 1
    fi
    
    # 解压文件
    print_info "正在解压文件..."
    tar -zxf alist-linux-${ARCH}.tar.gz
    
    # 创建安装目录
    mkdir -p "$ALIST_DIR"
    
    # 移动文件
    mv alist "$ALIST_BIN"
    chmod +x "$ALIST_BIN"
    
    # 清理临时文件
    cd - >/dev/null
    rm -rf "$tmp_dir"
    
    print_success "Alist 下载并安装完成"
}

# 创建systemd服务
create_service() {
    print_info "正在创建 systemd 服务..."
    
    cat > "$ALIST_SERVICE" <<EOF
[Unit]
Description=Alist Service
After=network.target

[Service]
Type=simple
WorkingDirectory=${ALIST_DIR}
ExecStart=${ALIST_BIN} server
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    print_success "systemd 服务创建完成"
}

# 安装Alist
install_alist() {
    print_info "================================"
    print_info "开始安装 Alist"
    print_info "================================"
    
    # 检查是否已安装
    if [[ -f "$ALIST_BIN" ]]; then
        print_warning "检测到 Alist 已安装"
        read -p "是否覆盖安装？(y/n): " choice
        if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
            print_info "取消安装"
            return
        fi
        stop_alist
    fi
    
    # 检测架构
    detect_arch
    
    # 获取最新版本
    get_latest_version
    
    # 安装依赖
    install_dependencies
    
    # 下载Alist
    download_alist
    
    # 创建systemd服务
    create_service
    
    # 启动服务
    print_info "正在启动 Alist 服务..."
    systemctl enable alist
    systemctl start alist
    
    # 等待服务启动
    sleep 3
    
    # 获取管理员密码
    print_success "================================"
    print_success "Alist 安装完成！"
    print_success "================================"
    
    # 尝试获取管理员密码
    cd "$ALIST_DIR"
    ADMIN_PASSWORD=$($ALIST_BIN admin random 2>/dev/null | grep -oP '(?<=password: ).*')
    
    if [[ -n "$ADMIN_PASSWORD" ]]; then
        print_info "管理员信息："
        print_info "  用户名: admin"
        print_info "  密码: ${ADMIN_PASSWORD}"
    else
        print_info "获取管理员密码："
        print_info "  运行命令: cd ${ALIST_DIR} && ${ALIST_BIN} admin random"
    fi
    
    print_info "访问地址: http://$(hostname -I | awk '{print $1}'):5244"
    print_info "配置文件: ${ALIST_CONFIG}"
}

# 卸载Alist
uninstall_alist() {
    print_warning "================================"
    print_warning "准备卸载 Alist"
    print_warning "================================"
    
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    read -p "确认要卸载 Alist 吗？所有数据将被删除！(yes/no): " choice
    if [[ "$choice" != "yes" ]]; then
        print_info "取消卸载"
        return
    fi
    
    # 停止服务
    print_info "正在停止服务..."
    systemctl stop alist 2>/dev/null
    systemctl disable alist 2>/dev/null
    
    # 删除服务文件
    print_info "正在删除服务文件..."
    rm -f "$ALIST_SERVICE"
    systemctl daemon-reload
    
    # 删除安装目录
    print_info "正在删除安装目录..."
    rm -rf "$ALIST_DIR"
    
    print_success "Alist 已完全卸载"
}

# 启动Alist
start_alist() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    print_info "正在启动 Alist..."
    systemctl start alist
    
    if systemctl is-active --quiet alist; then
        print_success "Alist 启动成功"
    else
        print_error "Alist 启动失败，请检查日志: journalctl -u alist -n 50"
    fi
}

# 停止Alist
stop_alist() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    print_info "正在停止 Alist..."
    systemctl stop alist
    print_success "Alist 已停止"
}

# 重启Alist
restart_alist() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    print_info "正在重启 Alist..."
    systemctl restart alist
    
    if systemctl is-active --quiet alist; then
        print_success "Alist 重启成功"
    else
        print_error "Alist 重启失败，请检查日志"
    fi
}

# 查看状态
check_status() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    print_info "================================"
    print_info "Alist 状态信息"
    print_info "================================"
    
    # 服务状态
    if systemctl is-active --quiet alist; then
        print_success "服务状态: 运行中"
    else
        print_error "服务状态: 已停止"
    fi
    
    # 版本信息
    if [[ -f "$ALIST_BIN" ]]; then
        VERSION=$($ALIST_BIN version 2>/dev/null | head -n 1)
        print_info "版本信息: ${VERSION}"
    fi
    
    # 端口信息
    if [[ -f "$ALIST_CONFIG" ]]; then
        PORT=$(grep -oP '"http_port":\s*\K\d+' "$ALIST_CONFIG" 2>/dev/null)
        [[ -z "$PORT" ]] && PORT="5244"
        print_info "监听端口: ${PORT}"
        print_info "访问地址: http://$(hostname -I | awk '{print $1}'):${PORT}"
    fi
    
    # 安装路径
    print_info "安装路径: ${ALIST_DIR}"
    print_info "配置文件: ${ALIST_CONFIG}"
    
    echo ""
    systemctl status alist --no-pager -l
}

# 修改端口
change_port() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    # 获取当前端口
    CURRENT_PORT="5244"
    if [[ -f "$ALIST_CONFIG" ]]; then
        CURRENT_PORT=$(grep -oP '"http_port":\s*\K\d+' "$ALIST_CONFIG" 2>/dev/null)
        [[ -z "$CURRENT_PORT" ]] && CURRENT_PORT="5244"
    fi
    
    print_info "当前端口: ${CURRENT_PORT}"
    read -p "请输入新端口号 (1-65535): " new_port
    
    # 验证端口号
    if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [[ "$new_port" -lt 1 ]] || [[ "$new_port" -gt 65535 ]]; then
        print_error "无效的端口号"
        return
    fi
    
    # 检查端口是否被占用
    if netstat -tuln 2>/dev/null | grep -q ":${new_port} "; then
        print_warning "警告: 端口 ${new_port} 可能已被占用"
        read -p "是否继续？(y/n): " choice
        if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
            return
        fi
    fi
    
    # 停止服务
    print_info "正在停止服务..."
    systemctl stop alist
    
    # 修改配置文件
    if [[ -f "$ALIST_CONFIG" ]]; then
        # 使用sed修改端口
        sed -i "s/\"http_port\":\s*[0-9]\+/\"http_port\": ${new_port}/" "$ALIST_CONFIG"
        print_success "配置文件已更新"
    else
        # 如果配置文件不存在，创建基本配置
        mkdir -p "${ALIST_DIR}/data"
        cat > "$ALIST_CONFIG" <<EOF
{
  "force": false,
  "site_url": "",
  "cdn": "",
  "jwt_secret": "$(openssl rand -hex 16)",
  "token_expires_in": 48,
  "database": {
    "type": "sqlite3",
    "host": "",
    "port": 0,
    "user": "",
    "password": "",
    "name": "",
    "db_file": "data/data.db",
    "table_prefix": "x_",
    "ssl_mode": ""
  },
  "scheme": {
    "https": false,
    "cert_file": "",
    "key_file": ""
  },
  "temp_dir": "data/temp",
  "bleve_dir": "data/bleve",
  "log": {
    "enable": true,
    "name": "data/log/log.log",
    "max_size": 10,
    "max_backups": 5,
    "max_age": 28,
    "compress": false
  },
  "delayed_start": 0,
  "max_connections": 0,
  "tls_insecure_skip_verify": true,
  "http_port": ${new_port}
}
EOF
        print_success "配置文件已创建"
    fi
    
    # 启动服务
    print_info "正在启动服务..."
    systemctl start alist
    
    if systemctl is-active --quiet alist; then
        print_success "端口已成功修改为: ${new_port}"
        print_info "新访问地址: http://$(hostname -I | awk '{print $1}'):${new_port}"
    else
        print_error "服务启动失败，请检查配置"
    fi
}

# 查看日志
view_logs() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    print_info "显示最近50行日志 (按 q 退出):"
    echo ""
    journalctl -u alist -n 50 --no-pager
}

# 重置管理员密码
reset_password() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    print_info "正在生成新的管理员密码..."
    cd "$ALIST_DIR"
    
    # 生成随机密码
    NEW_PASSWORD=$($ALIST_BIN admin random 2>&1 | grep -oP '(?<=password: ).*')
    
    if [[ -n "$NEW_PASSWORD" ]]; then
        print_success "管理员密码已重置"
        print_info "用户名: admin"
        print_info "新密码: ${NEW_PASSWORD}"
    else
        print_error "密码重置失败"
        print_info "请手动运行: cd ${ALIST_DIR} && ${ALIST_BIN} admin random"
    fi
}

# 更新Alist
update_alist() {
    if [[ ! -f "$ALIST_BIN" ]]; then
        print_error "Alist 未安装"
        return
    fi
    
    print_info "================================"
    print_info "开始更新 Alist"
    print_info "================================"
    
    # 获取当前版本
    CURRENT_VERSION=$($ALIST_BIN version 2>/dev/null | head -n 1 || echo "未知")
    print_info "当前版本: ${CURRENT_VERSION}"
    
    # 检测架构
    detect_arch
    
    # 获取最新版本
    get_latest_version
    
    # 备份当前版本
    print_info "正在备份当前版本..."
    cp "$ALIST_BIN" "${ALIST_BIN}.backup"
    
    # 停止服务
    print_info "正在停止服务..."
    systemctl stop alist
    
    # 下载新版本
    download_alist
    
    # 启动服务
    print_info "正在启动服务..."
    systemctl start alist
    
    if systemctl is-active --quiet alist; then
        print_success "Alist 更新成功！"
        print_info "新版本: ${ALIST_VERSION}"
        rm -f "${ALIST_BIN}.backup"
    else
        print_error "更新后启动失败，正在恢复备份..."
        mv "${ALIST_BIN}.backup" "$ALIST_BIN"
        systemctl start alist
        print_error "已恢复到原版本"
    fi
}

# 显示菜单
show_menu() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Alist 管理脚本 for PVE 9.0${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "  1. 安装 Alist"
    echo "  2. 卸载 Alist"
    echo "  3. 启动 Alist"
    echo "  4. 停止 Alist"
    echo "  5. 重启 Alist"
    echo "  6. 查看状态"
    echo "  7. 修改端口"
    echo "  8. 重置密码"
    echo "  9. 查看日志"
    echo " 10. 更新 Alist"
    echo "  0. 退出脚本"
    echo ""
    echo -e "${BLUE}================================${NC}"
}

# 主函数
main() {
    check_root
    
    while true; do
        show_menu
        read -p "请选择操作 [0-10]: " choice
        echo ""
        
        case $choice in
            1)
                install_alist
                ;;
            2)
                uninstall_alist
                ;;
            3)
                start_alist
                ;;
            4)
                stop_alist
                ;;
            5)
                restart_alist
                ;;
            6)
                check_status
                ;;
            7)
                change_port
                ;;
            8)
                reset_password
                ;;
            9)
                view_logs
                ;;
            10)
                update_alist
                ;;
            0)
                print_info "退出脚本"
                exit 0
                ;;
            *)
                print_error "无效的选择，请重新输入"
                ;;
        esac
        
        echo ""
        read -p "按回车键继续..."
    done
}

# 运行主函数
main

