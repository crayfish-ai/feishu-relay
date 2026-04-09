#!/bin/bash
#=============================================================================
# OpenClaw Self-Evolution Task
# 每天凌晨3点自动执行：系统自检 + 经验学习 + 优化策略
#=============================================================================

set -e

# 系统总开关检查
PAUSE_FLAG="/tmp/system_pause.flag"
NOTIFY_PAUSE_LOG="/tmp/.evolution_pause.lock"

if [ -f "$PAUSE_FLAG" ]; then
    if [ ! -f "$NOTIFY_PAUSE_LOG" ]; then
        notify -t "⏸️ 系统自进化已暂停" -m "self-evolution 已暂停，跳过执行。\n恢复：rm -f $PAUSE_FLAG" 2>/dev/null || true
        touch "$NOTIFY_PAUSE_LOG"
    fi
    exit 0
fi

if [ -f "$NOTIFY_PAUSE_LOG" ]; then
    notify -t "▶️ 系统自进化已恢复" -m "self-evolution 已恢复运行。" 2>/dev/null || true
    rm -f "$NOTIFY_PAUSE_LOG"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EVOLUTION_DIR="/root/.openclaw/workspace/evolution"
LOG_DIR="${EVOLUTION_DIR}/logs"
MEMORY_DIR="${EVOLUTION_DIR}/memory"
REPORT_FILE="${EVOLUTION_DIR}/daily-report-$(date +%Y%m%d).md"

mkdir -p "$LOG_DIR" "$MEMORY_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

#=============================================================================
# 1. 系统自检
#=============================================================================
do_health_check() {
    log "=== 步骤1: 系统自检 ==="
    
    REPORT="## 📋 系统自检报告\n"
    REPORT+="**时间**: $(date '+%Y-%m-%d %H:%M:%S')\n\n"
    
    # Gateway 状态
    if systemctl --user is-active openclaw-gateway >/dev/null 2>&1; then
        REPORT+="✅ **Gateway**: 运行中\n"
    else
        REPORT+="❌ **Gateway**: 未运行\n"
    fi
    
    # Cron 状态
    if pgrep -f "/usr/sbin/cron" >/dev/null 2>&1; then
        REPORT+="✅ **Cron**: 运行中\n"
    else
        REPORT+="❌ **Cron**: 未运行\n"
    fi
    
    # 内存使用
    MEM=$(free | grep Mem)
    TOTAL=$(echo $MEM | awk '{print $2}')
    USED=$(echo $MEM | awk '{print $3}')
    USAGE=$((USED * 100 / TOTAL))
    REPORT+="📊 **内存使用率**: ${USAGE}%\n"
    
    # 磁盘使用
    ROOT_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    REPORT+="💾 **根分区使用率**: ${ROOT_USAGE}%\n"
    
    # 今日错误数
    TODAY=$(date +%Y-%m-%d)
    LOG_PATH="/tmp/openclaw/openclaw-${TODAY}.log"
    if [ -f "$LOG_PATH" ]; then
        ERROR_COUNT=$(grep -c "ERROR" "$LOG_PATH" 2>/dev/null || echo 0)
        REPORT+="⚠️ **今日错误数**: ${ERROR_COUNT}\n"
    fi
    
    echo -e "$REPORT"
}

#=============================================================================
# 2. 分析失败任务
#=============================================================================
do_failure_analysis() {
    log "=== 步骤2: 分析失败任务 ==="
    
    REPORT="\n## 🔍 失败任务分析\n"
    TODAY=$(date +%Y-%m-%d)
    LOG_PATH="/tmp/openclaw/openclaw-${TODAY}.log"
    
    if [ ! -f "$LOG_PATH" ]; then
        REPORT+="无日志文件\n"
        echo -e "$REPORT"
        return
    fi
    
    # 分析错误类型
    REPORT+="### 错误类型分布\n\n"
    
    EDIT_FAIL=$(grep -c "edit failed" "$LOG_PATH" 2>/dev/null || echo 0)
    READ_FAIL=$(grep -c "read failed" "$LOG_PATH" 2>/dev/null || echo 0)
    EXEC_FAIL=$(grep -c "exec failed" "$LOG_PATH" 2>/dev/null || echo 0)
    
    REPORT+="| 错误类型 | 数量 | 说明 |\n"
    REPORT+="|---------|------|------|\n"
    REPORT+="| edit failed | ${EDIT_FAIL} | 编辑工具尝试修改不存在的文本 |\n"
    REPORT+="| read failed | ${READ_FAIL} | 读取不存在的文件或路径问题 |\n"
    REPORT+="| exec failed | ${EXEC_FAIL} | 执行命令预检失败 |\n"
    
    # 判断是否需要告警
    TOTAL_FAIL=$((EDIT_FAIL + READ_FAIL + EXEC_FAIL))
    if [ "$TOTAL_FAIL" -gt 100 ]; then
        REPORT+="\n🚨 **告警**: 错误数过多（${TOTAL_FAIL}），建议检查系统状态\n"
    fi
    
    echo -e "$REPORT"
}

#=============================================================================
# 3. 更新优化策略
#=============================================================================
do_strategy_update() {
    log "=== 步骤3: 更新优化策略 ==="
    
    REPORT="\n## 🧬 优化策略更新\n"
    
    # 记录成功策略
    SUCCESS_PATTERNS="${MEMORY_DIR}/success_patterns.json"
    if [ ! -f "$SUCCESS_PATTERNS" ]; then
        echo '{}' > "$SUCCESS_PATTERNS"
    fi
    
    # 记录失败策略
    FAILURE_PATTERNS="${MEMORY_DIR}/failure_patterns.json"
    if [ ! -f "$FAILURE_PATTERNS" ]; then
        echo '{}' > "$FAILURE_PATTERNS"
    fi
    
    # 分析今天的错误，更新失败模式
    TODAY=$(date +%Y-%m-%d)
    LOG_PATH="/tmp/openclaw/openclaw-${TODAY}.log"
    
    if [ -f "$LOG_PATH" ]; then
        # 检查路径问题
        if grep -q "Path escapes sandbox" "$LOG_PATH"; then
            REPORT+="- ⚠️ **风险**: 检测到沙箱路径问题，建议使用 workspace 相对路径\n"
        fi
        
        # 检查文件不存在问题
        if grep -q "ENOENT" "$LOG_PATH"; then
            REPORT+="- ⚠️ **风险**: 检测到文件不存在错误，建议操作前验证文件存在\n"
        fi
        
        # 检查偏移量问题
        if grep -q "Offset.*beyond end" "$LOG_PATH"; then
            REPORT+="- ⚠️ **风险**: 检测到文件读取偏移量错误，建议先检查文件大小\n"
        fi
    fi
    
    REPORT+="- ✅ **策略**: 继续使用经过验证的工作流程\n"
    REPORT+="- ✅ **策略**: 优先使用 read/write 工具而非 exec\n"
    
    echo -e "$REPORT"
}

#=============================================================================
# 4. 输出优化报告
#=============================================================================
do_report() {
    log "=== 步骤4: 生成报告 ==="
    
    REPORT="$1$2$3"
    
    # 保存报告
    echo -e "$REPORT" > "$REPORT_FILE"
    log "报告已保存: $REPORT_FILE"
    
    # 发送飞书通知（如果有配置）
    if [ -f "${SKILL_DIR}/lib/send.py" ]; then
        FEISHU_TITLE="📊 系统自我进化报告 - $(date '+%m/%d')"
        FEISHU_MSG=$(echo -e "$REPORT" | head -30 | sed 's/#\*\*//g; s/\*\*//g; s/## //g; s/\n/\\n/g')
        
        # 尝试发送（静默失败）
        cd "${SKILL_DIR}"
        ./run.sh -t "$FEISHU_TITLE" -m "$FEISHU_MSG" 2>/dev/null || true
    fi
    
    echo -e "$REPORT"
}

#=============================================================================
# 5. 记录经验
#=============================================================================
do_record_experience() {
    log "=== 步骤5: 记录经验 ==="
    
    TODAY=$(date +%Y-%m-%d)
    
    # 今天的经验记录
    EXPERIENCE_FILE="${MEMORY_DIR}/experience-$(date +%Y%m%d).json"
    
    # 简单记录今天的错误类型
    LOG_PATH="/tmp/openclaw/openclaw-${TODAY}.log"
    
    if [ -f "$LOG_PATH" ]; then
        ERROR_COUNT=$(grep -c "ERROR" "$LOG_PATH" 2>/dev/null || echo 0)
        EDIT_FAIL=$(grep -c "edit failed" "$LOG_PATH" 2>/dev/null || echo 0)
        READ_FAIL=$(grep -c "read failed" "$LOG_PATH" 2>/dev/null || echo 0)
        
        cat > "$EXPERIENCE_FILE" << EOF
{
  "date": "${TODAY}",
  "error_count": ${ERROR_COUNT},
  "edit_failed": ${EDIT_FAIL},
  "read_failed": ${READ_FAIL},
  "gateway_status": "$(systemctl --user is-active openclaw-gateway 2>/dev/null || echo 'unknown')",
  "cron_status": "$(pgrep -f '/usr/sbin/cron' >/dev/null && echo 'running' || echo 'stopped')"
}
EOF
        log "经验已记录: $EXPERIENCE_FILE"
    fi
}

#=============================================================================
# 主流程
#=============================================================================
main() {
    log "========== 系统自我进化开始 =========="
    
    HEALTH_REPORT=$(do_health_check)
    FAILURE_REPORT=$(do_failure_analysis)
    STRATEGY_REPORT=$(do_strategy_update)
    
    do_report "$HEALTH_REPORT" "$FAILURE_REPORT" "$STRATEGY_REPORT"
    do_record_experience
    
    log "========== 系统自我进化完成 =========="
}

main "$@"
