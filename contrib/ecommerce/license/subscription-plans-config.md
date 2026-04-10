# Commerce License - 订阅计划配置指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 概述

本文档详细介绍如何在 Drupal Commerce 中配置和管理订阅计划（Subscription Plans），适用于 SaaS 软件、会员服务和定期收费产品。

### 适用场景

- **SaaS 软件订阅** - 按月/年付费使用
- **内容平台会员** - 付费内容访问权限
- **在线服务套餐** - API 调用量分级
- **学习平台课程** - 定期更新课程

---

## 🎯 核心概念

### 订阅 vs 许可证

| 特性 | 一次性许可证 | 订阅计划 |
|------|------------|---------|
| **计费周期** | 单次支付 | 周期性重复收费 |
| **有效期** | 永久或固定期限 | 持续至取消/到期 |
| **价格模式** | 固定价格 | 阶梯定价、试用、折扣 |
| **功能更新** | 通常包含在版本内 | 可能需升级到高级版 |
| **典型用例** | 永久使用权 | 持续服务访问 |

### 订阅生命周期

```
Trial (试用期)
    ↓ [用户选择]
Active (激活期)
    ├── [自动续费] → Active
    ├── [用户取消] → Cancelled
    ├── [支付失败] → Past Due
    └── [手动暂停] → Paused
```

---

## ⚙️ 基础配置

### 1. 启用订阅模块

```bash
composer require drupal/commerce_subscription
drush en commerce_subscription subscription_checkout --yes
```

### 2. 创建订阅产品类型

```
/admin/structure/product-type/add
→ Name: Software Subscription
→ Type: Subscription
```

### 3. 添加必要字段

```yaml
fields:
  - name: billing_cycle
    type: list_text
    cardinality: 1
    allowed_values:
      - monthly
      - annual
      - lifetime
    default_value: monthly
    
  - name: trial_period_days
    type: integer
    cardinality: 1
    default_value: 14
    
  - name: price_adjustment_annual
    type: decimal
    description: "Annual discount percentage"
    default_value: 0
```

---

## 📋 订阅计划配置

### 创建订阅计划

**路径**: `/admin/store/subscription/plans`

#### 基本设置

| 字段 | 说明 | 示例值 |
|------|------|--------|
| Plan Name | 计划名称 | Professional Monthly |
| Description | 详细描述 | 适合小团队的专业版 |
| Price | 单价 | $29.99 |
| Currency | 货币 | USD |
| Billing Cycle | 计费周期 | Monthly |

#### 高级设置

| 字段 | 说明 | 示例值 |
|------|------|--------|
| Trial Period | 试用期天数 | 14 |
| Minimum Commitment | 最小承诺期 | 1 month |
| Auto-Renewal | 自动续费 | Yes |
| Cancellation Policy | 取消政策 | Refund within 30 days |
| Max Users | 最大用户数 | 5 |
| Max Projects | 最大项目数 | 10 |

### 订阅计划模板库

下面是常见的订阅模型参考：

#### 模型 A: 分级订阅 (Tiered Subscription)

| 计划名 | 月度价 | 年度价 | 优惠比例 | 适用人群 |
|-------|-------|-------|---------|---------|
| **Starter** | $9.99 | $99.99 | 17% off | 个人用户 |
| **Professional** | $29.99 | $299.99 | 17% off | 小型团队 |
| **Business** | $99.99 | $999.99 | 17% off | 中型企业 |
| **Enterprise** | Contact | Contact | Custom | 大型企业 |

**特点**:
- 层级清晰，功能递增
- 年度优惠吸引长期承诺
- 提供定制企业方案入口

#### 模型 B: 按用量付费 (Usage-Based)

| 资源类型 | Starter | Professional | Business |
|---------|---------|-------------|----------|
| API Calls | 1,000/mo | 10,000/mo | 100,000/mo |
| Storage | 10 GB | 100 GB | 1 TB |
| Support | Email only | Email + Chat | Dedicated SLA |
| Overage | $0.01/call | $0.008/call | $0.005/call |

**特点**:
- 灵活扩展，适合增长型客户
- 超额部分单独计费
- 降低初始门槛

#### 模型 C: 免费增值 (Freemium)

| 功能 | Free Tier | Pro Upgrade |
|------|-----------|------------|
| Price | $0/month | $29/month |
| Trials | 7 days | Unlimited |
| Features | Core only | Full suite |
| Support | Community | Priority |
| Export | Limited | Unlimited |

**特点**:
- 免费层获客
- 体验式升级
- 转化率优化

---

## 💻 代码示例

### 1. 创建订阅计划实体

```php
use Drupal\commerce_subscription\Entity\SubscriptionPlan;

/**
 * 创建订阅计划的完整示例
 */
class SubscriptionPlanCreator {
  
  /**
   * 创建标准订阅计划
   */
  public function createPlan(array $config): SubscriptionPlan {
    $plan = SubscriptionPlan::create([
      'id' => $config['id'] ?? NULL,
      'label' => $config['name'],
      'description' => $config['description'],
      'price' => new Price($config['price'], $config['currency'] ?? 'USD'),
      'billing_interval' => $config['interval'] ?? 'month',
      'trial_period_days' => $config['trial_days'] ?? 0,
      'status' => TRUE,
    ]);
    
    // 保存基础计划
    $plan->save();
    
    // 添加元数据
    $this->addMetadata($plan, $config);
    
    // 设置促销规则
    if (!empty($config['promotions'])) {
      $this->applyPromotions($plan, $config['promotions']);
    }
    
    return $plan;
  }
  
  /**
   * 批量创建分级订阅计划
   */
  public function createTieredPlans(): array {
    $tiers = [
      [
        'id' => 'starter',
        'name' => 'Starter Plan',
        'description' => 'Perfect for individuals and side projects.',
        'price' => 9.99,
        'interval' => 'month',
        'trial_days' => 7,
        'features' => [
          'max_users' => 1,
          'max_projects' => 3,
          'api_calls' => 1000,
          'support' => 'email',
        ],
      ],
      [
        'id' => 'professional',
        'name' => 'Professional Plan',
        'description' => 'For small teams needing more power.',
        'price' => 29.99,
        'interval' => 'month',
        'trial_days' => 14,
        'annual_discount' => 17,
        'features' => [
          'max_users' => 5,
          'max_projects' => 10,
          'api_calls' => 10000,
          'support' => 'email_chat',
        ],
      ],
      [
        'id' => 'business',
        'name' => 'Business Plan',
        'description' => 'Advanced features for growing businesses.',
        'price' => 99.99,
        'interval' => 'month',
        'trial_days' => 30,
        'annual_discount' => 17,
        'features' => [
          'max_users' => 20,
          'max_projects' => 50,
          'api_calls' => 100000,
          'support' => 'priority',
        ],
      ],
    ];
    
    $plans = [];
    foreach ($tiers as $tier) {
      $plans[] = $this->createPlan($tier);
    }
    
    \Drupal::logger('commerce_subscription')
      ->info('Created :count subscription plans', [':count' => count($plans)]);
    
    return $plans;
  }
  
  /**
   * 添加计划元数据
   */
  protected function addMetadata(SubscriptionPlan $plan, array $config): void {
    $metadata = [
      'target_audience' => $config['audience'] ?? 'general',
      'sale_target_percentage' => $config['discount'] ?? 0,
      'created_by' => \Drupal::currentUser()->id(),
      'updated_at' => REQUEST_TIME,
    ];
    
    $plan->set('metadata', $metadata);
  }
  
  /**
   * 应用促销规则到计划
   */
  protected function applyPromotions(SubscriptionPlan $plan, array $promotions): void {
    foreach ($promotions as $promo_config) {
      $promotion = \Drupal\promotions\Entity\Promotion::create([
        'name' => $promo_config['name'],
        'status' => TRUE,
        'priority' => 10,
        'actions' => [$promo_config['action_type']],
        'conditions' => [
          'commerce_subscription:plan' => ['plan_id' => $plan->id()],
        ],
      ]);
      
      $promotion->save();
    }
  }
}
```

### 2. 订阅轮换逻辑

```php
use Drupal\commerce_subscription\Entity\Subscription;

/**
 * 处理订阅轮换（从试用转正式、月转年等）
 */
class SubscriptionRenewalProcessor {
  
  /**
   * 试用转正式
   */
  public function processTrialToPaid(int $subscription_id): void {
    $subscription = Subscription::load($subscription_id);
    
    // 验证仍在试用期内
    if (!$subscription->isInTrial()) {
      throw new \Exception('Trial period has already ended');
    }
    
    // 获取关联的订单
    $order = Order::load($subscription->getOrderId());
    
    // 执行实际付款流程
    $payment_result = $this->processPayment($subscription, $order);
    
    if ($payment_result->isSuccessful()) {
      // 升级订阅状态
      $subscription->setStatus('active');
      $subscription->setStartDate(REQUEST_TIME);
      $subscription->setEndDate($this->calculateNextBillingDate($subscription));
      $subscription->setTrialEnd(REQUEST_TIME);
      $subscription->save();
      
      // 生成许可证
      $this->generateLicenseForSubscription($subscription);
      
      // 发送确认邮件
      $this->sendTrialConversionEmail($subscription);
      
      \Drupal::logger('subscription')
        ->info('Trial converted to paid subscription: :sub_id', [':sub_id' => $subscription_id]);
    } else {
      $subscription->setStatus('past_due');
      $subscription->save();
      
      // 通知支付失败
      $this->sendPaymentFailedNotification($subscription);
    }
  }
  
  /**
   * 订阅续订
   */
  public function renewSubscription(int $subscription_id): bool {
    $subscription = Subscription::load($subscription_id);
    
    if ($subscription->getStatus() !== 'active') {
      return FALSE;
    }
    
    // 检查是否需要续订
    if ($subscription->getNextBillingDate() > REQUEST_TIME) {
      return FALSE; // 还未到续订时间
    }
    
    try {
      // 执行续订付款
      $result = $this->processAutoRenewal($subscription);
      
      if ($result->isSuccessful()) {
        // 延长订阅期限
        $old_end_date = $subscription->getEndDate();
        $new_end_date = strtotime('+1 month', $old_end_date);
        
        $subscription->setEndDate($new_end_date);
        $subscription->setNextBillingDate($new_end_date);
        $subscription->save();
        
        // 延长许可证
        $this->extendLicenseValidity($subscription, $new_end_date);
        
        // 记录续订事件
        $this->logRenewalEvent($subscription, $result);
        
        // 发送续订成功通知
        $this->sendRenewalConfirmation($subscription);
        
        return TRUE;
      } else {
        // 处理续订失败
        $this->handleRenewalFailure($subscription, $result);
        return FALSE;
      }
      
    } catch (\Exception $e) {
      \Drupal::logger('subscription')->error('Renewal failed: @message', ['@message' => $e->getMessage()]);
      return FALSE;
    }
  }
  
  /**
   * 计算下次账单日期
   */
  protected function calculateNextBillingDate(SubscriptionInterface $subscription): int {
    $start = $subscription->getStartDate() ?: REQUEST_TIME;
    $interval = $subscription->getBillingInterval();
    
    switch ($interval) {
      case 'day':
        return strtotime('+1 day', $start);
      case 'week':
        return strtotime('+7 days', $start);
      case 'month':
        return strtotime('+1 month', $start);
      case 'year':
        return strtotime('+1 year', $start);
      default:
        return strtotime('+1 month', $start);
    }
  }
  
  /**
   * 为订阅生成许可证
   */
  protected function generateLicenseForSubscription(SubscriptionInterface $subscription): void {
    $product = $subscription->getProductVariant();
    $quantity = $subscription->getUserCount() ?? 1;
    
    $generator = new LicenseBatchGenerator(\Drupal::service('license.generator'));
    $licenses = $generator->generateForProduct($product, $quantity);
    
    foreach ($licenses as $license) {
      $license->setLinkedSubscription($subscription->id());
      $license->setExpiresAt($subscription->getEndDate());
      $license->save();
    }
  }
}
```

### 3. 订阅价格调整

```php
/**
 * 管理订阅计划的价格变更
 */
class SubscriptionPriceAdjuster {
  
  /**
   * 应用价格变化到现有订阅
   */
  public function applyPriceChange(SubscriptionPlan $plan, float $new_price, string $effective_date = 'now'): void {
    // 查找所有活跃的订阅
    $subscriptions = \Drupal::entityTypeManager()
      ->getStorage('subscription')
      ->loadByProperties([
        'plan_id' => $plan->id(),
        'status' => 'active',
      ]);
    
    foreach ($subscriptions as $subscription) {
      // 计算价格差异
      $old_price = $subscription->getAmount();
      $price_diff = $new_price - $old_price;
      
      if ($price_diff != 0) {
        // 标记为价格变更
        db_insert('subscription_price_history')
          ->fields([
            'subscription_id' => $subscription->id(),
            'old_price' => $old_price,
            'new_price' => $new_price,
            'price_diff' => $price_diff,
            'change_reason' => 'manual_update',
            'effective_date' => strtotime($effective_date),
            'changed_by' => \Drupal::currentUser()->id(),
            'created_at' => REQUEST_TIME,
          ])
          ->execute();
        
        \Drupal::logger('subscription')
          ->warning('Price changed for subscription :id from $:old to $:new', [
            ':id' => $subscription->id(),
            ':old' => $old_price,
            ':new' => $new_price,
          ]);
      }
    }
    
    // 更新计划基础价格
    $plan->setPrice(new Price($new_price, $plan->getPrice()->getCurrency()->getId()));
    $plan->save();
  }
  
  /**
   * 批量更新价格（带通知）
   */
  public function bulkUpdatePricesWithNotification(
    array $plan_ids, 
    float $percentage_increase,
    string $notification_template = 'price_change_notification'
  ): void {
    foreach ($plan_ids as $plan_id) {
      $plan = SubscriptionPlan::load($plan_id);
      $current_price = $plan->getPrice()->getAmount();
      $new_price = $current_price * (1 + $percentage_increase / 100);
      
      $this->applyPriceChange($plan, round($new_price, 2), '+30 days');
      
      // 发送邮件通知现有订阅者
      $affected_subscriptions = $this->getAffectedSubscriptions($plan_id);
      foreach ($affected_subscriptions as $subscription) {
        $this->sendPriceChangeNotification($subscription, $percentage_increase);
      }
    }
  }
}
```

### 4. 订阅取消处理

```php
/**
 * 处理订阅取消请求
 */
class SubscriptionCancellationService {
  
  /**
   * 用户主动取消
   */
  public function cancelByUser(int $subscription_id, string $reason = ''): void {
    $subscription = Subscription::load($subscription_id);
    
    if ($subscription->getStatus() !== 'active') {
      throw new \Exception('Subscription is not active');
    }
    
    // 检查取消政策
    $policy = $this->getCancellationPolicy($subscription);
    
    if (!$policy->allowsCancellation()) {
      throw new \Exception('Cancellation not allowed under current policy');
    }
    
    // 确定取消生效时间
    if ($policy->hasRefundPeriod()) {
      // 如果在退款期内，立即停止服务
      $effective_date = REQUEST_TIME;
      $refund_amount = $this->calculateRefundAmount($subscription);
    } else {
      // 否则等到当前周期结束
      $effective_date = $subscription->getEndDate();
      $refund_amount = 0;
    }
    
    // 执行取消
    $subscription->setStatus('cancelled');
    $subscription->setCancelledAt(REQUEST_TIME);
    $subscription->setCancellationReason($reason);
    $subscription->save();
    
    // 记录取消事件
    db_insert('subscription_cancellation_log')
      ->fields([
        'subscription_id' => $subscription_id,
        'cancellation_date' => REQUEST_TIME,
        'effective_date' => $effective_date,
        'reason' => $reason,
        'refund_amount' => $refund_amount,
      ])
      ->execute();
    
    // 发送取消确认邮件
    $this->sendCancellationConfirmation($subscription, $refund_amount);
    
    // 如果涉及退款，处理退款流程
    if ($refund_amount > 0) {
      $this->initiateRefund($subscription, $refund_amount);
    }
    
    \Drupal::logger('subscription')
      ->info('Subscription :id cancelled by user: :reason', [
        ':id' => $subscription_id,
        ':reason' => $reason,
      ]);
  }
  
  /**
   * 管理员强制取消
   */
  public function forceCancel(int $subscription_id, string $reason): void {
    $subscription = Subscription::load($subscription_id);
    
    $subscription->setStatus('cancelled');
    $subscription->setCancelledAt(REQUEST_TIME);
    $subscription->setCancellationReason('forced:' . $reason);
    $subscription->setForceCancelledBy(\Drupal::currentUser()->id());
    $subscription->save();
    
    // 删除许可证（安全原因）
    $this->revokeAssociatedLicenses($subscription);
    
    // 发送通知
    $this->sendForceCancellationNotice($subscription, $reason);
  }
}
```

---

## 🔧 订阅工作流程配置

### 自动化规则设置

**路径**: `/admin/config/workflow/rules`

#### 规则示例：自动续费失败通知

```yaml
rule_subscription_payment_failed:
  LABEL: 'Send notification on payment failure'
  COND:
    - plugin: 'entity_is_type'
      bundles:
        - 'subscription'
    - plugin: 'data_is'
      data: 'subscription:payment_status'
      value: 'failed'
  ACT:
    - plugin: 'mail'
      mail_key: 'subscription_payment_failed'
```

#### 规则示例：试用即将到期提醒

```yaml
rule_trial_expiration_reminder:
  LABEL: 'Reminder before trial ends'
  COND:
    - plugin: 'entity_is_type'
      bundles:
        - 'subscription'
    - plugin: 'condition_list'
      impl: 'and'
      criteria:
        - data: 'subscription:status'
          value: 'trialing'
        - data: 'time_comparison'
          days_before: 3
          field: 'subscription:end_date'
  ACT:
    - plugin: 'mail'
      mail_key: 'trial_expiration_reminder'
      delay: '0 seconds'
```

---

## 📊 订阅分析报表

### 关键指标定义

| 指标 | 公式 | 目标值 |
|------|------|--------|
| MRR (月经常性收入) | SUM(active_subscriptions × monthly_price) | 持续增长 |
| ARR (年经常性收入) | MRR × 12 | 季度增长 10%+ |
| Churn Rate (流失率) | Cancellations ÷ Total Subscriptions | < 5%/月 |
| LTV (客户终身价值) | Avg Revenue per Account × Gross Margin % ÷ Churn Rate | > 3× CAC |

### 导出订阅报告

```bash
# MRR 分析报告
drush subscription:mrr-report \
  --date-from "$(date -d '30 days ago' +%Y-%m-%d)" \
  --format=csv \
  --output=mrr-report.csv

# 订阅流失分析
drush subscription:churn-analysis \
  --period 30 \
  --output=churn-analysis.json
```

---

*最后更新：2026-04-08 | 版本：v1.0*
