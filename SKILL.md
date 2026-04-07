# Feishu Relay

统一飞书通知系统 - 可靠的消息队列和重试机制。

## 功能

- 统一通知入口
- SQLite 消息队列
- 自动重试机制
- systemd 服务集成
- 支持特殊字符、换行、空内容

## 使用

```bash
/opt/feishu-notifier/bin/notify "标题" "内容"
```

## 配置

编辑 `/opt/feishu-notifier/config/feishu.env`：

```
FEISHU_APP_ID=cli_xxx
FEISHU_APP_SECRET=xxx
FEISHU_USER_ID=ou_xxx
```

## 安装

```bash
sudo ./install.sh
```

## 许可证

MIT
