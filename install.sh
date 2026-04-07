#!/bin/bash
#
# Feishu Relay 安装脚本
# 

set -e

INSTALL_DIR="/opt/feishu-notifier"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Feishu Relay 安装 ==="
echo ""

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行"
    exit 1
fi

# 检查依赖
echo "检查依赖..."
for cmd in python3 sqlite3 curl; do
    if ! command -v $cmd &> /dev/null; then
        echo "缺少依赖: $cmd"
        echo "安装依赖..."
        apt-get update && apt-get install -y python3 sqlite3 curl
        break
    fi
done

# 创建目录
echo "创建目录结构..."
mkdir -p "$INSTALL_DIR"/{bin,lib,queue,config}

# 复制文件
echo "复制文件..."
cp "$REPO_DIR/bin/"*.sh "$INSTALL_DIR/bin/"
cp "$REPO_DIR/bin/notify" "$INSTALL_DIR/bin/"
cp "$REPO_DIR/lib/"*.py "$INSTALL_DIR/lib/"
chmod +x "$INSTALL_DIR/bin/"*
chmod +x "$INSTALL_DIR/lib/"*.py

# 创建数据库
echo "初始化数据库..."
sqlite3 "$INSTALL_DIR/queue/notify-queue.db" << 'EOF'
CREATE TABLE IF NOT EXISTS queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    retry INTEGER DEFAULT 0
);
EOF

# 安装 systemd 服务
echo "安装 systemd 服务..."
cat > /etc/systemd/system/feishu-relay.service << 'EOF'
[Unit]
Description=Feishu Relay - Unified Notification Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/feishu-notifier/lib/feishu-relay.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable feishu-relay

# 创建软链接
ln -sf "$INSTALL_DIR/bin/notify" /usr/local/bin/notify 2>/dev/null || true

echo ""
echo "=== 安装完成 ==="
echo ""
echo "下一步:"
echo "1. 配置飞书参数:"
echo "   sudo tee $INSTALL_DIR/config/feishu.env << 'EOF'"
echo "   FEISHU_APP_ID=cli_xxx"
echo "   FEISHU_APP_SECRET=xxx"
echo "   FEISHU_USER_ID=ou_xxx"
echo "   FEISHU_RECEIVE_ID_TYPE=open_id"
echo "   EOF"
echo ""
echo "2. 设置权限:"
echo "   sudo chmod 600 $INSTALL_DIR/config/feishu.env"
echo ""
echo "3. 启动服务:"
echo "   sudo systemctl start feishu-relay"
echo ""
echo "4. 测试:"
echo "   /opt/feishu-notifier/bin/notify '测试' '消息内容'"
echo ""
