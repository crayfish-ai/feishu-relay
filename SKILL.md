# Feishu Relay

统一飞书通知系统 - 可靠的消息队列、自动发现和重试机制。

## 功能

- **统一通知入口** - 所有系统使用相同的 `notify` 命令
- **自动系统发现** - 新系统部署后自动注册并通知
- **SQLite 消息队列** - 可靠的消息存储和投递
- **自动重试机制** - 失败自动重试 3 次
- **systemd 服务集成** - 后台常驻服务
- **智能类型识别** - 自动识别 website/service/skill/task
- **框架检测** - 自动检测 Next.js/Django/Flask/Node/Go/Rust

## 快速开始

```bash
# 安装
sudo ./install-v2.sh

# 发送通知
notify "标题" "内容"

# 查看已注册系统
feishu-relay-register list
```

## 自动发现

新系统部署到以下目录将自动被发现：

| 路径 | 识别类型 |
|------|---------|
| `/opt/*` | service |
| `/var/www/*` | website |
| `/data/*` | data |
| `/home/*` | user |

## 配置

编辑 `/opt/feishu-notifier/config/feishu.env`：

```
FEISHU_APP_ID=cli_xxx
FEISHU_APP_SECRET=xxx
FEISHU_USER_ID=ou_xxx
FEISHU_RECEIVE_ID_TYPE=open_id
```

## 命令

```bash
notify "标题" "内容"                    # 发送即时通知
feishu-relay-register list              # 列出所有系统
feishu-relay-register status            # 查看状态
feishu-relay-register scan              # 手动触发扫描
```

## 文档

- [自动发现文档](docs/auto-discovery.md)
- [架构设计](ARCHITECTURE.md)

## 许可证

MIT
