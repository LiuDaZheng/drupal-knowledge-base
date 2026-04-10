#!/bin/bash
# scripts/deploy.sh - Drupal 11 部署脚本（Agent 可安全运行）
# 用法：./scripts/deploy.sh [dev|staging|production]

set -e  # 遇错立即终止
set -o pipefail  # 管道错误也需要捕获

# 环境变量配置（从 .env.ci 或环境变量读取）
DRUPAL_ROOT="${DRUPAL_ROOT:-$(pwd)}"
DEPLOY_ENV="${1:-staging}"
DRUSH="${DRUPAL_ROOT}/vendor/bin/drush"
LOG_FILE="${DRUPAL_ROOT}/logs/deploy-$(date +%Y%m%d-%H%M%S).log"

# 确保日志目录存在
mkdir -p "${DRUPAL_ROOT}/logs"

# 日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误退出
error_exit() {
  log "❌ ERROR: $1"
  exit 1
}

# 开始部署
log "🚀 开始部署到 $DEPLOY_ENV 环境"
log "📁 Drupal 根目录：$DRUPAL_ROOT"

# 1. 检查 Drupal 是否安装
if [ ! -f "$DRUPAL_ROOT/web/core/drupal.bootstrap.php" ]; then
  error_exit "Drupal 核心文件不存在，请检查 DRUPAL_ROOT 变量"
fi

# 2. 检查 Drush 是否可用
if [ ! -x "$DRUSH" ]; then
  error_exit "Drush 未安装或不可执行，请先运行：composer require drush/drush"
fi

# 3. 检查配置同步目录
if grep -q "config_sync_directory" "$DRUPAL_ROOT/web/sites/default/settings.php" 2>/dev/null; then
  SYNC_DIR=$(grep "config_sync_directory" "$DRUPAL_ROOT/web/sites/default/settings.php" | sed "s/.*'\(.*\)'.*/\1/")
  SYNC_PATH="$DRUPAL_ROOT/$SYNC_DIR"
  
  if [ ! -d "$SYNC_PATH" ]; then
    mkdir -p "$SYNC_PATH"
    chmod 755 "$SYNC_PATH"
    log "✅ 创建配置同步目录：$SYNC_PATH"
  fi
else
  error_exit "settings.php 中未配置 config_sync_directory"
fi

# 4. 检查数据库连接
log "🔧 检查数据库连接..."
if ! $DRUSH status --db-status --format=json 2>&1 | tee -a "$LOG_FILE" | grep -q "dbms"; then
  error_exit "无法连接到数据库"
fi

# 5. 根据环境执行部署
case "$DEPLOY_ENV" in
  dev|testing)
    log "💡 部署到开发/测试环境"
    
    # 数据库更新
    log "1️⃣ Running database updates..."
    if ! $DRUSH updatedb --strict=0 -y 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "数据库更新失败"
    fi
    
    # 清除缓存
    log "2️⃣ Clearing cache..."
    if ! $DRUSH cache:rebuild 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "缓存重建失败"
    fi
    
    # 导入配置
    log "3️⃣ Importing configuration..."
    if ! $DRUSH config:import -y 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "配置导入失败"
    fi
    
    # 再次清除缓存
    log "4️⃣ Clearing cache again..."
    if ! $DRUSH cache:rebuild 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "缓存重建失败"
    fi
    
    log "✅ 部署到开发/测试环境完成!"
    ;;
  
  staging)
    log "⚠️  部署到预发环境"
    
    # 环境状态
    log "📊 Checking status..."
    $DRUSH status --format=json 2>&1 | tee -a "$LOG_FILE"
    
    # 数据库更新
    log "1️⃣ Running database updates..."
    if ! $DRUSH updatedb --strict=0 -y 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "数据库更新失败"
    fi
    
    # 清除缓存
    log "2️⃣ Clearing cache..."
    if ! $DRUSH cache:rebuild 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "缓存重建失败"
    fi
    
    # 导入配置
    log "3️⃣ Importing configuration..."
    if ! $DRUSH config:import -y 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "配置导入失败"
    fi
    
    # 再次清除缓存
    log "4️⃣ Clearing cache again..."
    if ! $DRUSH cache:rebuild 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "缓存重建失败"
    fi
    
    # 部署状态
    log "📊 Checking deploy status..."
    $DRUSH deploy:status 2>&1 | tee -a "$LOG_FILE" || true
    
    log "✅ 部署到预发环境完成!"
    ;;
  
  production)
    log "🔒 部署到生产环境 - 谨慎操作!"
    
    # 环境状态
    log "📊 Checking status..."
    $DRUSH status --format=json 2>&1 | tee -a "$LOG_FILE"
    
    # 模拟运行
    log "⚠️  Running simulation..."
    if ! $DRUSH updatedb --strict=0 --simulate -y 2>&1 | tee -a "$LOG_FILE"; then
      log "⚠️  Simulation revealed issues, please review"
    fi
    
    log "⚠️  模拟运行完成，确认开始实际部署..."
    read -p "按回车键确认继续部署到生产环境，输入 'abort' 取消：" confirm
    if [ "$confirm" != "" ] && [ "$confirm" != "" ]; then
      error_exit "部署已取消"
    fi
    
    # 数据库更新
    log "1️⃣ Running database updates..."
    if ! $DRUSH updatedb --strict=0 -y 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "数据库更新失败"
    fi
    
    # 清除缓存
    log "2️⃣ Clearing cache..."
    if ! $DRUSH cache:rebuild 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "缓存重建失败"
    fi
    
    # 导入配置
    log "3️⃣ Importing configuration..."
    if ! $DRUSH config:import -y 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "配置导入失败"
    fi
    
    # 再次清除缓存
    log "4️⃣ Clearing cache again..."
    if ! $DRUSH cache:rebuild 2>&1 | tee -a "$LOG_FILE"; then
      error_exit "缓存重建失败"
    fi
    
    # 部署钩子
    log "5️⃣ Running deploy hook..."
    $DRUSH deploy:hook 2>&1 | tee -a "$LOG_FILE" || true
    
    log "✅ 部署到生产环境完成!"
    ;;
  
  *)
    error_exit "未知环境：$DEPLOY_ENV (可用：dev, staging, production)"
    ;;
esac

log "✅ 部署完成!"
log "📋 部署日志已保存：$LOG_FILE"
exit 0
