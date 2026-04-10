---
name: commerce-wishlist
description: Complete guide to Commerce Wishlist for saving products and reordering later.
---

# Commerce Wishlist - 愿望清单 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Wishlist 是 Drupal Commerce 的核心扩展功能，允许注册用户将感兴趣的商品添加到个人愿望清单中，便于后续查看、分享和管理购买计划。该功能特别适用于礼品采购、商品对比和高价值商品的延迟决策场景。

### 核心功能
- ✅ **用户专属愿望清单** - 每个用户拥有独立的愿望清单
- ✅ **分享愿望清单给朋友** - 通过邮件或链接分享给他人
- ✅ **价格变化通知** - 监控商品价格变动并通知用户
- ✅ **一键添加到购物车** - 快速将愿望清单商品加入购物车
- ✅ **社交网络集成** - 支持分享到 Facebook、Twitter 等平台
- ✅ **库存提醒** - 缺货时自动通知补货
- ✅ **有效期管理** - 可设置愿望清单过期时间
- ✅ **批量操作** - 支持删除、移动分类等操作

### 适用场景
- B2C 电商网站
- 礼品推荐平台
- 季节性促销（黑五、圣诞）
- 社交媒体整合电商
- 需要复购激励的商店
- UGC 内容驱动型电商

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- User account module enabled

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装 wishlist 模块
composer require drupal/wishlist

# 启用相关模块
drush en wishlist user_notifications --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块到 sites/modules/contrib
drush dl wishlist

# 2. 启用模块
drush en wishlist --yes

# 3. 运行数据库更新
drush updatedb --yes
```

#### 方法 3: 使用 Drupal UI

1. 访问 [https://www.drupal.org/project/wishlist](https://www.drupal.org/project/wishlist)
2. 下载模块 ZIP 文件
3. 上传至 `/sites/all/modules/custom/`
4. 前往 `/admin/modules`
5. 勾选 "Wishlist" 模块
6. 点击 Install

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en wishlist --yes
```

### 2. 创建愿望清单页面

在 Structure → Page management 中添加：

```
路径：/user/{uid}/wishlist
权限：Authenticated user
```

或通过 Drush：
```bash
drush page:wishlist add "My Wishlist" \
  --path="user/[current-user:uid]/wishlist" \
  --access=administer \
  --weight=10
```

### 3. 配置基本选项

```
路径：/admin/config/store/wishlist/settings
```

| 选项 | 默认值 | 说明 |
|------|--------|------|
| Enable wishlists | ✅ Yes | 启用愿望清单功能 |
| Allow anonymous users | ❌ No | 允许匿名访问（需登录） |
| Max items per list | 100 | 单列表最大项目数 |
| Auto-delete old lists | 90 days | 自动删除旧列表 |
| Share via email | ✅ Yes | 支持邮件分享 |
| Enable notifications | ✅ Yes | 启用价格变化通知 |

### 4. 设置分享权限

```yaml
sharing_settings:
  public_lists: false
  share_methods: ['email', 'facebook', 'twitter']
  password_protected: true  # 可选密码保护
  expires_after_days: 30    # 分享链接有效期
```

### 5. 配置邮件模板

```
/admin/config/system/mail/settings/wishlist
```

#### 分享通知模板

```twig
主题：{{ recipient_name }} 分享了一个愿望清单给您!

正文:
{{ sender_name }} 与您分享了他们的愿望清单

清单名称：{{ wishlist_title }}
包含 {{ item_count }} 个商品

查看清单：{{ wishlist_url }}

此链接将在 {{ expiry_days }} 天后失效

感谢您的好友分享！
```

---

## 💻 代码示例

### 1. 添加商品到愿望清单

```php
use Drupal\wishlist\Entity\WishlistInterface;
use Drupal\commerce_product\Entity\ProductVariation;

/**
 * 将商品添加到用户的愿望清单
 */
function add_to_wishlist($user_id, ProductVariation $product, $notes = '') {
  // 获取或创建用户的愿望清单
  $wishlist = get_or_create_user_wishlist($user_id);
  
  // 检查是否已存在
  if ($wishlist->hasItem($product->id())) {
    throw new \Exception('This item is already in your wishlist.');
  }
  
  // 添加商品
  $wishlist_item = \Drupal::entityTypeManager()
    ->getStorage('wishlist_item')
    ->create([
      'wishlist' => $wishlist->id(),
      'variation_id' => $product->id(),
      'notes' => $notes,
      'created' => REQUEST_TIME,
    ]);
  
  $wishlist_item->save();
  
  // 发送通知
  send_add_notification($user_id, $product);
  
  return $wishlist_item;
}

/**
 * 获取或创建用户愿望清单
 */
function get_or_create_user_wishlist($user_id) {
  $list = \Drupal::entityTypeManager()
    ->getStorage('wishlist')
    ->loadByProperties(['uid' => $user_id]);
  
  if (!empty($list)) {
    return reset($list);
  }
  
  // 创建新清单
  $new_list = \Drupal\wishlist\Entity\Wishlist::create([
    'uid' => $user_id,
    'title' => t('My Wishlist'),
    'status' => 'active',
  ]);
  
  $new_list->save();
  
  return $new_list;
}
```

### 2. 从愿望清单移除商品

```php
/**
 * 从愿望清单移除商品
 */
function remove_from_wishlist($wishlist_id, $product_id) {
  $items = \Drupal::entityTypeManager()
    ->getStorage('wishlist_item')
    ->loadByProperties([
      'wishlist' => $wishlist_id,
      'variation_id' => $product_id,
    ]);
  
  if (!empty($items)) {
    foreach ($items as $item) {
      $item->delete();
    }
    
    \Drupal::logger('wishlist')
      ->info('Removed product :pid from wishlist :wid', [
        '@pid' => $product_id,
        '@wid' => $wishlist_id,
      ]);
  }
}
```

### 3. 分享愿望清单

```php
/**
 * 生成分享链接
 */
function generate_wishlist_share_link(WishlistInterface $wishlist) {
  // 创建唯一的分享令牌
  $token = md5(uniqid(rand(), TRUE));
  
  $share_data = [
    'wishlist_id' => $wishlist->id(),
    'token' => $token,
    'expires_at' => REQUEST_TIME + (30 * DAY), // 30 天有效
    'password' => NULL, // 可选密码保护
  ];
  
  // 保存分享记录
  db_insert('wishlist_share')
    ->fields($share_data)
    ->execute();
  
  // 返回分享 URL
  return Url::fromRoute('entity.wishlist.share', [
    'share_token' => $token,
  ])->toString();
}

/**
 * 发送邮件分享
 */
function send_wishlist_email_share(WishlistInterface $wishlist, $recipient_email) {
  $user = \Drupal\user\User::load($wishlist->getOwnerId());
  $share_url = generate_wishlist_share_link($wishlist);
  
  $mail_manager = \Drupal::service('plugin.manager.mail');
  
  $message = [
    'uid' => $user->id(),
    'template' => 'wishlist_share',
    'params' => [
      'recipient_name' => $recipient_email,
      'sender_name' => $user->getEmail(),
      'wishlist_title' => $wishlist->getTitle(),
      'item_count' => count($wishlist->getItems()),
      'wishlist_url' => $share_url,
      'expiry_days' => 30,
    ],
  ];
  
  $mail_manager->mailSend($message);
}
```

### 4. 价格变化通知

```php
/**
 * Hook implementation: commerce_product_price_update
 * 当商品价格变更时检查是否在用户的愿望清单中
 */
function mymodule_commerce_product_price_update(ProductVariantInterface $variant, $old_price, $new_price) {
  // 查询所有包含该商品的愿望清单
  $wishlists = \Drupal::entityTypeManager()
    ->getStorage('wishlist_item')
    ->getQuery()
    ->condition('variation_id', $variant->id())
    ->execute();
  
  foreach ($wishlists as $item_id) {
    $item = \Drupal\wishlist\Entity\WishlistItem::load($item_id);
    $wishlist = $item->getWishlist();
    
    if ($item->hasNotificationEnabled()) {
      send_price_change_notification(
        $wishlist->getOwner(),
        $variant,
        $old_price,
        $new_price
      );
    }
  }
}

/**
 * 发送价格变化通知
 */
function send_price_change_notification($user, $variant, $old_price, $new_price) {
  $price_difference = clone $new_price;
  $price_difference->setAmount($new_price->getAmount() - $old_price->getAmount());
  
  $direction = $price_difference->getAmount() < 0 ? 'down' : 'up';
  
  \Drupal::service('plugin.manager.mail')
    ->send(
      'mymodule',
      'wishlist_price_change',
      $user,
      [
        'product_name' => $variant->getProduct()->getName(),
        'old_price' => $old_price->toString(),
        'new_price' => $new_price->toString(),
        'change_direction' => ucfirst($direction),
        'difference' => abs($price_difference->getAmount()),
        'view_url' => $variant->toUrl()->toString(),
      ]
    );
}
```

### 5. Twig 模板 - 愿望清单视图

```twig
{# templates/wishlist/view.html.twig #}
<div class="wishlist-container">
  <h1>{{ title }}</h1>
  
  {% if wishlists|length == 0 %}
    <div class="empty-wishlist">
      <p>您的愿望清单还是空的。</p>
      <a href="{{ path('catalog.page') }}" class="button">浏览商品</a>
    </div>
  {% else %}
    <div class="wishlist-actions">
      <button class="btn btn-primary" onclick="moveAllToCart()">
        全部加入购物车
      </button>
      <button class="btn btn-secondary" onclick="exportList()">
        导出列表
      </button>
      <button class="btn btn-share" data-wishlist-id="{{ wishlist.id }}">
        分享
      </button>
    </div>
    
    <table class="wishlist-table">
      <thead>
        <tr>
          <th>商品</th>
          <th>价格</th>
          <th>库存</th>
          <th>操作</th>
        </tr>
      </thead>
      <tbody>
        {% for item in wishlist.items %}
          <tr data-item-id="{{ item.id }}">
            <td class="product-info">
              <img src="{{ item.variation.image.url }}" alt="{{ item.variation.name }}" width="50">
              <a href="{{ item.variation.toUrl()->toString() }}">{{ item.variation.name }}</a>
              {% if item.notes %}
                <div class="notes">{{ item.notes }}</div>
              {% endif %}
            </td>
            <td class="price">
              <span class="current-price">{{ item.variation.price }}</span>
              {% if item.notification_enabled %}
                <span class="notification-icon" title="有价格变化通知">🔔</span>
              {% endif %}
            </td>
            <td class="stock">
              {% if item.variation.stock_available > 0 %}
                <span class="in-stock" style="color: green;">✅ 有货 ({{ item.variation.stock_available }})</span>
              {% else %}
                <span class="out-of-stock" style="color: red;">❌ 缺货</span>
              {% endif %}
            </td>
            <td class="actions">
              <button class="btn-cart" data-var-id="{{ item.variation.id }}">
                加入购物车
              </button>
              <button class="btn-remove" data-item-id="{{ item.id }}">
                移除
              </button>
            </td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  {% endif %}
</div>

<script>
// 批量加入购物车
function moveAllToCart() {
  var itemIds = document.querySelectorAll('.wishlist-table tbody tr').forEach(function(row) {
    var btn = row.querySelector('.btn-cart');
    btn.click();
  });
}

// 导出愿望清单
function exportList() {
  window.open('/wishlist/{{ wishlist.id }}/export.csv');
}
</script>
```

---

## 📋 数据表结构

### wishlist
愿望清单主表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY | 自增 ID |
| uid | INT | FOREIGN KEY | 用户 ID |
| title | VARCHAR(255) | NOT NULL | 清单标题 |
| description | TEXT | NULLABLE | 描述 |
| status | VARCHAR(20) | DEFAULT 'active' | active/published/archived |
| visibility | VARCHAR(20) | DEFAULT 'private' | private/public/protected |
| item_count | INT | DEFAULT 0 | 项目数量缓存 |
| created | DATETIME | NOT NULL | 创建时间 |
| changed | DATETIME | NOT NULL | 最后修改时间 |

**索引**:
- `idx_uid` ON uid
- `idx_status_visibility` ON (status, visibility)

### wishlist_item
愿望清单项表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| wishlist_id | INT | FOREIGN KEY | 关联 wishlist.id |
| variation_id | INT | NOT NULL | 商品变体 ID |
| quantity | INT | DEFAULT 1 | 期望数量 |
| notes | TEXT | NULLABLE | 备注 |
| price_when_added | DECIMAL(10,2) | NULLABLE | 添加时价格 |
| notification_enabled | BOOLEAN | DEFAULT TRUE | 是否开启价格通知 |
| priority | INT | DEFAULT 0 | 优先级 |
| position | INT | DEFAULT 0 | 排序位置 |
| added_at | DATETIME | NOT NULL | 添加时间 |

**索引**:
- `idx_wishlist` ON wishlist_id
- `idx_variation` ON variation_id
- UNIQUE INDEX `unique_item` (wishlist_id, variation_id)

### wishlist_share
愿望清单分享表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| wishlist_id | INT | FOREIGN KEY | 关联 wishlist.id |
| token | VARCHAR(64) | NOT NULL UNIQUE | 分享令牌 |
| email | VARCHAR(255) | NULLABLE | 分享到的邮箱 |
| password_hash | VARCHAR(255) | NULLABLE | 密码哈希（如启用） |
| access_count | INT | DEFAULT 0 | 访问次数 |
| last_accessed | DATETIME | NULLABLE | 最后访问时间 |
| expires_at | DATETIME | NOT NULL | 过期时间 |

**索引**:
- `idx_token` ON token (唯一)
- `idx_expires` ON expires_at WHERE expires_at > NOW()

### wishlist_notification_log
通知日志表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 自增 ID |
| wishlist_id | INT | NOT NULL | 关联 wishlist.id |
| item_id | INT | NOT NULL | 关联 wishlist_item.id |
| notification_type | VARCHAR(50) | NOT NULL | price_change/restock/expiration |
| template_used | VARCHAR(100) | NULLABLE | 使用的模板 |
| sent_at | DATETIME | NOT NULL | 发送时间 |
| delivery_status | VARCHAR(20) | DEFAULT 'pending' | pending/sent/failed |
| error_message | TEXT | NULLABLE | 错误信息 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\wishlist\Kernel\WishlistTest;
use Drupal\wishlist\Entity\Wishlist;

class WishlistFunctionalityTest extends KernelTestBase {
  
  protected static $modules = ['wishlist', 'commerce_product'];
  
  /**
   * Test: Create wishlist and add item
   */
  public function testCreateWishlistAndAddItem() {
    // 创建用户
    $user = $this->createUser([], [], TRUE);
    
    // 创建商品
    $product = $this->createTestProduct();
    
    // 添加商品到愿望清单
    $item = add_to_wishlist($user->id(), $product);
    
    // 验证
    $this->assertNotNull($item);
    $this->assertEquals($user->id(), $item->getWishlist()->getOwnerId());
    $this->assertEquals($product->id(), $item->getVariation()->id());
  }
  
  /**
   * Test: Wishlist sharing
   */
  public function testShareWishlist() {
    $user = $this->createUser([], [], TRUE);
    $wishlist = get_or_create_user_wishlist($user->id());
    
    // 生成分享链接
    $share_url = generate_wishlist_share_link($wishlist);
    
    // 验证 URL 格式
    $this->assertMatchesRegularExpression(
      '/\/wishlist\/share\/[a-f0-9]{32}/',
      $share_url
    );
  }
  
  /**
   * Test: Price change notification
   */
  public function testPriceChangeNotification() {
    $user = $this->createUser();
    $wishlist = get_or_create_user_wishlist($user->id());
    
    $product = $this->createTestProduct(new Price('10.00', 'USD'));
    add_to_wishlist($user->id(), $product);
    
    // 模拟价格变化
    update_product_price($product, new Price('8.00', 'USD'));
    
    // 验证通知被触发
    $mails = mail_test_get_sent_mails();
    $this->assertCount(1, $mails);
    $this->assertEquals('wishlist_price_change', $mails[0]['template']);
  }
}
```

### 集成测试

```gherkin
Feature: Wishlist Sharing
  As a registered user
  I want to share my wishlist with friends
  
  Scenario: Share wishlist via email
    Given I have a wishlist with 5 items
    When I enter a friend's email address
    And click "Share"
    Then the email should be sent successfully
    And I should see a confirmation message
    And the link should expire in 30 days
  
  Scenario: Friend accesses shared wishlist
    Given a wishlist was shared with me via email
    When I click the share link
    Then I should see the wishlist content
    And I can add items to cart
    And after viewing, access_count should increase by 1
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算方式 | 目标值 |
|------|---------|--------|
| **平均愿望清单大小** | SUM(item_count) / COUNT(lists) | 10-30 项 |
| **分享转化率** | (分享后购买 / 分享总数) × 100% | > 5% |
| **通知打开率** | (打开邮件 / 发送总数) × 100% | > 30% |
| **心愿清单活跃度** | (周活跃用户 / 总用户) × 100% | > 20% |

### 日志命令

```bash
# 查看愿望清单相关日志
drush watchdog-view wishlist --count=50

# 导出分享统计
drush sql-query "SELECT * FROM wishlist_share ORDER BY access_count DESC LIMIT 20"

# 查找过期链接
drush sql-query "SELECT * FROM wishlist_share WHERE expires_at < NOW()"

# 清理旧数据
drush php-script cleanup_old_wishlists
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Wishlist Module | https://www.drupal.org/project/wishlist |
| Email Marketing Best Practices | https://www.hubspot.com/email-marketing-statistics |
| Social Sharing Guidelines | https://developers.facebook.com/docs/sharing/webmasters |

---

## 🆘 常见问题

### Q1: 如何处理匿名用户添加愿望清单？

**答案**：
```php
/**
 * 为匿名用户创建临时会话愿望清单
 */
function create_anonymous_wishlist() {
  $session = \Drupal::session();
  $anon_id = 'anon_' . session_id();
  
  if (!$session->has('wishlist_id')) {
    $wishlist = Wishlist::create([
      'uid' => 0,
      'title' => t('Your temporary wishlist'),
      'visibility' => 'private',
    ]);
    $wishlist->save();
    $session->set('wishlist_id', $wishlist->id());
  }
  
  return Wishlist::load($session->get('wishlist_id'));
}
```

### Q2: 如何设置愿望清单过期？

**答案**：
```yaml
# settings.php
$config['wishlist.settings']['auto_expire'] = TRUE;
$config['wishlist.settings']['expire_after_days'] = 90;

# 定期清理脚本
#!/bin/bash
# cron.sh

drush php-eval "
\$days = 90;
\$cutoff = strtotime('-' . \$days . ' days');

$query = db_select('wishlist', 'w');
$query->fields('w', ['id']);
$query->condition('changed', \$cutoff, '<');
\$ids = \$query->execute();

foreach (\$ids as \$row) {
  \$wishlist = Wishlist::load(\$row->id);
  \$wishlist->setStatus('archived');
  \$wishlist->save();
}
"
```

### Q3: 如何实现批量操作？

**答案**：
```javascript
// 全选/反选
$('#select-all-items').on('click', function() {
  $('.wishlist-item-checkbox').prop('checked', true);
});

// 批量移动到另一个清单
$('.bulk-move-to').on('click', function() {
  var selectedItems = [];
  $('.wishlist-item-checkbox:checked').each(function() {
    selectedItems.push($(this).data('item-id'));
  });
  
  if (selectedItems.length > 0) {
    $.ajax({
      url: '/api/wishlist/move-items',
      method: 'POST',
      data: {
        item_ids: selectedItems,
        target_list: $('#target-list').val()
      },
      success: function(response) {
        alert('Moved ' + selectedItems.length + ' items successfully');
        location.reload();
      }
    });
  }
});
```

---

**大正，commerce-wishlist.md 已补充完成。您还有其他指令吗？** 🚀
