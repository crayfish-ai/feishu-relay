#!/bin/bash
#=============================================================================
# OpenClaw System Health Check
# 定期检查系统各组件健康状态
#=============================================================================

set -e

LOG_DIR="/tmp/openclaw-health"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/health-$(date +%Y%m%d).log"
ALERT_LOG="${LOG_DIR}/alerts.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $1" | tee -a "$ALERT_LOG"
}

#=============================================================================
# 1. Gateway 检查
#=============================================================================
check_gateway() {
    log "=== Gateway 检查 ==="
    
    # 检查 systemd 服务状态
    if systemctl --user is-active openclaw-gateway >/dev/null 2>&1; then
        log "✓ Gateway 服务运行中"
    else
        alert "Gateway 服务未运行，尝试重启..."
        systemctl --user restart openclaw-gateway 2>/dev/null || true
        sleep 5
        if systemctl --user is-active openclaw-gateway >/dev/null 2>&1; then
            log "✓ Gateway 已重启"
        else
            alert "Gateway 重启失败"
        fi
    fi
    
    # 检查进程内存使用
    MEM=$(ps -o rss= -p $(systemctl --user show openclaw-gateway -p MainPID --value 2>/dev/null) 2>/dev/null | tr -d ' ' || echo 0)
    MEM_MB=$((MEM / 1024))
    if [ "$MEM_MB" -gt 2048 ]; then
        alert "Gateway 内存使用过高: ${MEM_MB}MB"
    else
        log "  Gateway 内存: ${MEM_MB}MB"
    fi
}

#=============================================================================
# 2. Cron 任务检查
#=============================================================================
check_cron() {
    log "=== Cron 任务检查 ==="
    
    # 检查 cron 是否运行
    if pgrep -x cron >/dev/null 2>&1 || pgrep -f "/usr/sbin/cron" >/dev/null 2>&1; then
        log "✓ Cron 运行中"
    else
        alert "Cron 未运行"
    fi
    
    # 检查最近一次 ablesci 队列监控执行时间
    LAST_RUN=$(stat -c %Y /root/.openclaw/workspace/ablesci_queue_monitor/logs/cron.log 2>/dev/null || echo 0)
    NOW=$(date +%s)
    DIFF=$((NOW - LAST_RUN))
    
    if [ "$DIFF" -gt 600 ]; then
        alert "ablesci 队列监控超过10分钟未执行"
    else
        log "  ablesci 队列监控: ${DIFF}秒前"
    fi
}

#=============================================================================
# 3. 磁盘空间检查
#=============================================================================
check_disk() {
    log "=== 磁盘空间检查 ==="
    
    # 检查根分区
    ROOT_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$ROOT_USAGE" -gt 80 ]; then
        alert "根分区使用率: ${ROOT_USAGE}%"
    else
        log "  根分区使用率: ${ROOT_USAGE}%"
    fi
    
    # 检查 /data/disk
    if df /data/disk >/dev/null 2>&1; then
        DATA_USAGE=$(df /data/disk | tail -1 | awk '{print $5}' | sed 's/%//')
        if [ "$DATA_USAGE" -gt 90 ]; then
            alert "/data/disk 使用率: ${DATA_USAGE}%"
        else
            log "  /data/disk 使用率: ${DATA_USAGE}%"
        fi
    fi
}

#=============================================================================
# 4. 内存检查
#=============================================================================
check_memory() {
    log "=== 内存检查 ==="
    
    TOTAL=$(free -m | grep Mem | awk '{print $2}')
    USED=$(free -m | grep Mem | awk '{print $3}')
    AVAILABLE=$(free -m | grep Mem | awk '{print $7}')
    USAGE=$((USED * 100 / TOTAL))
    
    if [ "$USAGE" -gt 80 ]; then
        alert "内存使用率: ${USAGE}% (可用: ${AVAILABLE}MB)"
    else
        log "  内存使用率: ${USAGE}% (可用: ${AVAILABLE}MB)"
    fi
    
    # 检查 swap
    SWAP_TOTAL=$(free -m | grep Swap | awk '{print $2}')
    if [ "$SWAP_TOTAL" -gt 0 ]; then
        SWAP_USED=$(free -m | grep Swap | awk '{print $3}')
        if [ "$SWAP_USED" -gt 0 ]; then
            log "  Swap: ${SWAP_USED}MB / ${SWAP_TOTAL}MB"
        fi
    fi
}

#=============================================================================
# 5. 日志错误检查
#=============================================================================
check_logs() {
    log "=== 日志错误检查 ==="
    
    TODAY=$(date +%Y-%m-%d)
    LOG_PATH="/tmp/openclaw/openclaw-${TODAY}.log"
    
    if [ -f "$LOG_PATH" ]; then
        ERROR_COUNT=$(grep -c "ERROR" "$LOG_PATH" 2>/dev/null || echo 0)
        log "  今日错误数: $ERROR_COUNT"
        
        if [ "$ERROR_COUNT" -gt 100 ]; then
            alert "今日错误数过多: $ERROR_COUNT"
        fi
    fi
}

#=============================================================================
# 6. 队列状态检查
#=============================================================================
check_queue() {
    log "=== 队列状态检查 ==="
    
    QUEUE_FILE="/root/.openclaw/workspace/ablesci_queue_monitor/tasks/queue.json"
    if [ -f "$QUEUE_FILE" ]; then
        TOTAL=$(cat "$QUEUE_FILE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d))" 2>/dev/null || echo 0)
        log "  队列任务数: $TOTAL"
    fi
}

#=============================================================================
# 主流程
#=============================================================================
main() {
    log "========== 系统健康检查开始 =========="
    
    check_gateway
    check_cron
    check_disk
    check_memory
    check_logs
    check_queue
    
    log "========== 健康检查完成 =========="
    
    # 如果有告警，发送通知
    if [ -s "$ALERT_LOG" ]; then
        RECENT_ALERTS=$(grep -c "" "${ALERT_LOG}" 2>/dev/null || echo 0)
        if [ "$RECENT_ALERTS" -gt 0 ]; then
            echo "=== 最近告警 ===" >> "$LOG_FILE"
            tail -5 "$ALERT_LOG" >> "$LOG_FILE"
        fi
    fi
}

main "$@"
