---
name: commerce-cart-api
description: Complete guide to Commerce Cart API for headless e-commerce and custom cart implementations.
---

# Commerce Cart API - 购物车 RESTful API (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Cart API 提供标准化的购物车 RESTful API，支持前后端分离架构、PWA Progressive Web Apps）、移动端原生应用、第三方系统集成等现代电商技术栈。实现购物车的全生命周期管理。

### 核心功能
- ✅ **购物车 CRUD API** - 完整的增删改查操作
- ✅ **结账流程 API** - 多步骤 checkout 支持
- ✅ **优惠券验证 API** - 实时优惠码校验
- ✅ **配送方法计算 API** - 运费即时计算
- ✅ **税务计算 API** - 智能税费预估
- ✅ **Webhook 集成** - 事件驱动架构
- ✅ **Token 认证支持** - OAuth2 / API Key
- ✅ **GraphQL 查询** - 灵活数据获取
- ✅ **多币种支持** - 国际化定价
- ✅ **缓存优化** - Redis/Memcached 支持

### 适用场景
- Headless 电商架构（Decoupled）
- Progressive Web Apps (PWA)
- 移动原生应用（iOS/Android）
- 多平台统一管理
- 第三方系统集成
- 社交媒体购物
- IoT 设备购物

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- JSON:API module (推荐)
- JWT or OAuth2 module (认证)

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装 Cart API 模块
composer require drupal/cart_api jsonapi

# 启用相关模块
drush en cart_api jsonapi rest resource_permissions --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl cart_api

# 2. 启用模块
drush en cart_api --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块并配置权限

```bash
drush en cart_api --yes
```

```
路径：/admin/config/services/rest/resource_type
→ 启用 Commerce Cart资源类型
→ 配置 GET, POST, PATCH, DELETE 权限
```

### 2. 设置 API 端点

```yaml
cart_api_endpoints:
  base_url: '/api/v1'
  
  carts:
    get_single: '/carts/{cart_id}'
    list: '/carts'
    create: 'POST /carts'
    update: 'PATCH /carts/{cart_id}'
    delete: 'DELETE /carts/{cart_id}'
    clear: 'POST /carts/{cart_id}/clear'
    
  cart_items:
    add: 'POST /carts/{cart_id}/items'
    update: 'PATCH /carts/{cart_id}/items/{item_id}'
    remove: 'DELETE /carts/{cart_id}/items/{item_id}'
    list: 'GET /carts/{cart_id}/items'
    
  checkout:
    initiate: 'POST /carts/{cart_id}/checkout/initiate'
    submit: 'POST /carts/{cart_id}/checkout/submit'
    payment: 'POST /carts/{cart_id}/payment'
    confirm: 'GET /carts/{cart_id}/checkout/confirm'
    
  coupons:
    validate: 'POST /carts/{cart_id}/coupons/validate'
    apply: 'POST /carts/{cart_id}/coupons/apply/{code}'
    remove: 'DELETE /carts/{cart_id}/coupons/{coupon_id}'
    
  shipping:
    calculate: 'POST /carts/{cart_id}/shipping/calculate'
    select: 'POST /carts/{cart_id}/shipping/select'
    
  taxes:
    estimate: 'POST /carts/{cart_id}/taxes/estimate'
```

### 3. 配置认证方式

```
/admin/config/services/auth
```

| 认证方式 | 端点 | 说明 |
|---------|------|------|
| **JWT Token** | `POST /auth/login` | 获取访问令牌 |
| **OAuth2** | `POST /oauth2/token` | 标准 OAuth2 流程 |
| **API Key** | Header: `X-API-Key` | 简单服务器对服务器 |
| **Anonymous** | No auth | 允许访客购物车 |

### 4. 设置速率限制

```yaml
rate_limits:
  anonymous_user:
    requests_per_minute: 30
    requests_per_hour: 500
    
  authenticated_user:
    requests_per_minute: 60
    requests_per_hour: 2000
    
  specific_endpoints:
    '/api/v1/carts':
      limit: 100
      window: '1 hour'
      
    '/api/v1/coupons/validate':
      limit: 10
      window: '1 minute'  # 防止滥用
```

---

## 💻 代码示例

### 1. 创建购物车 API 控制器

```php
use Drupal\Core\Controller\ControllerBase;
use Drupal\commerce_cart\Entity\CartRepositoryInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * 购物车 API 控制器
 */
class CartApiController extends ControllerBase {
  
  protected $cartRepository;
  protected $entityTypeManager;
  
  public function __construct(CartRepositoryInterface $cart_repository, \Drupal\Core\Entity\EntityTypeManagerInterface $entity_type_manager) {
    $this->cartRepository = $cart_repository;
    $this->entityTypeManager = $entity_type_manager;
  }
  
  /**
   * 创建新购物车
   */
  public function createCart() {
    $user = $this->currentUser();
    
    // 如果是匿名用户，创建会话购物车
    if (!$user->isAuthenticated()) {
      $session_key = session_id();
      $cart = $this->createGuestCart($session_key);
    } else {
      // 查找或创建用户购物车
      $cart = $this->getOrCreateUserCart($user->id());
    }
    
    return JsonResponse([
      'success' => TRUE,
      'data' => [
        'cart_id' => $cart->id(),
        'created_at' => date('Y-m-d H:i:s', $cart->getCreated()),
        'status' => 'active',
        'currency' => $cart->getCurrency()->getId(),
      ],
    ]);
  }
  
  /**
   * 获取购物车详情
   */
  public function getCart($cart_id) {
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart || !$this->canAccessCart($cart)) {
      throw new NotFoundHttpException('Cart not found');
    }
    
    return JsonResponse([
      'success' => TRUE,
      'data' => $this->formatCartResponse($cart),
    ]);
  }
  
  /**
   * 添加商品到购物车
   */
  public function addItem($cart_id) {
    $request = $this->getRequest();
    $data = json_decode($request->getContent(), TRUE);
    
    if (!isset($data['variation_id']) || !isset($data['quantity'])) {
      return JsonResponse([
        'success' => FALSE,
        'errors' => ['Missing required fields: variation_id, quantity'],
      ], 400);
    }
    
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart || !$this->canAccessCart($cart)) {
      throw new NotFoundHttpException('Cart not found');
    }
    
    try {
      // 验证库存
      $variation = \Drupal::entityTypeManager()
        ->getStorage('commerce_product_variation')
        ->load($data['variation_id']);
      
      if (!$variation) {
        throw new \Exception('Product variation not found');
      }
      
      // 检查库存充足性
      if (!$this->checkStockAvailability($variation, $data['quantity'])) {
        return JsonResponse([
          'success' => FALSE,
          'errors' => ['Not enough stock available'],
        ], 422);
      }
      
      // 添加到购物车
      $cart->addLineItem(
        $variation,
        $data['quantity'],
        $data['options'] ?? []
      );
      
      return JsonResponse([
        'success' => TRUE,
        'data' => [
          'cart_id' => $cart->id(),
          'item_added' => [
            'variation_id' => $variation->id(),
            'quantity' => $data['quantity'],
            'line_item_id' => $cart->getLastAddedLineItemId(),
          ],
        ],
      ]);
      
    } catch (\Exception $e) {
      return JsonResponse([
        'success' => FALSE,
        'errors' => [$e->getMessage()],
      ], 400);
    }
  }
  
  /**
   * 更新购物车项目数量
   */
  public function updateItem($cart_id, $item_id) {
    $request = $this->getRequest();
    $data = json_decode($request->getContent(), TRUE);
    
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart || !$this->canAccessCart($cart)) {
      throw new NotFoundHttpException('Cart not found');
    }
    
    $line_item = $cart->getLineItem($item_id);
    
    if (!$line_item) {
      return JsonResponse([
        'success' => FALSE,
        'errors' => ['Line item not found in cart'],
      ], 404);
    }
    
    $new_quantity = $data['quantity'];
    
    if ($new_quantity <= 0) {
      // 数量为 0 或删除
      $cart->removeLineItem($item_id);
    } else {
      // 更新数量
      $line_item->setQuantity($new_quantity);
      $cart->save();
    }
    
    return JsonResponse([
      'success' => TRUE,
      'data' => $this->formatCartResponse($cart),
    ]);
  }
  
  /**
   * 删除购物车项目
   */
  public function removeItem($cart_id, $item_id) {
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart || !$this->canAccessCart($cart)) {
      throw new NotFoundHttpException('Cart not found');
    }
    
    $cart->removeLineItem($item_id);
    
    return JsonResponse([
      'success' => TRUE,
      'data' => $this->formatCartResponse($cart),
    ]);
  }
  
  /**
   * 清空购物车
   */
  public function clearCart($cart_id) {
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart || !$this->canAccessCart($cart)) {
      throw new NotFoundHttpException('Cart not found');
    }
    
    $cart->clear();
    
    return JsonResponse([
      'success' => TRUE,
      'message' => 'Cart cleared successfully',
      'data' => $this->formatCartResponse($cart),
    ]);
  }
  
  /**
   * 验证优惠券
   */
  public function validateCoupon($cart_id) {
    $request = $this->getRequest();
    $data = json_decode($request->getContent(), TRUE);
    
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart) {
      throw new NotFoundHttpException('Cart not found');
    }
    
    $coupon_code = $data['code'] ?? NULL;
    
    if (!$coupon_code) {
      return JsonResponse([
        'success' => FALSE,
        'errors' => ['Coupon code is required'],
      ], 400);
    }
    
    try {
      $coupon = \Drupal::entityTypeManager()
        ->getStorage('promo_code')
        ->loadByProperties(['code' => $coupon_code])
        ->current();
      
      if (!$coupon) {
        return JsonResponse([
          'success' => FALSE,
          'errors' => ['Invalid coupon code'],
        ], 404);
      }
      
      // 验证优惠券是否可用
      if (!$coupon->isValid()) {
        return JsonResponse([
          'success' => FALSE,
          'errors' => ['Coupon has expired or reached usage limit'],
        ], 422);
      }
      
      // 验证适用条件
      $validation_result = $this->validateCouponApplicability($coupon, $cart);
      
      if (!$validation_result['valid']) {
        return JsonResponse([
          'success' => FALSE,
          'errors' => [$validation_result['message']],
        ], 422);
      }
      
      // 计算折扣金额
      $discount_amount = $this->calculateCouponDiscount($coupon, $cart);
      
      return JsonResponse([
        'success' => TRUE,
        'data' => [
          'coupon_id' => $coupon->id(),
          'code' => $coupon->getCode(),
          'value' => $coupon->getValue(),
          'type' => $coupon->getValueType(),
          'discount_amount' => $discount_amount,
          'applies_to' => $validation_result['applies_to'],
        ],
      ]);
      
    } catch (\Exception $e) {
      return JsonResponse([
        'success' => FALSE,
        'errors' => [$e->getMessage()],
      ], 500);
    }
  }
  
  /**
   * 计算运费
   */
  public function calculateShipping($cart_id) {
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart) {
      throw new NotFoundHttpException('Cart not found');
    }
    
    $request = $this->getRequest();
    $address_data = json_decode($request->getContent(), TRUE);
    
    // 根据收货地址计算运费
    $shipping_methods = $this->calculateShippingMethods($cart, $address_data);
    
    return JsonResponse([
      'success' => TRUE,
      'data' => [
        'methods' => array_map(function($method) {
          return [
            'id' => $method->getPluginId(),
            'title' => $method->getTitle(),
            'cost' => $method->getRate()->toString(),
            'estimated_days' => $method->getDeliveryTime(),
          ];
        }, $shipping_methods),
        'cheapest' => min(array_column($shipping_methods, 'rate')),
      ],
    ]);
  }
  
  /**
   * 开始结账流程
   */
  public function initiateCheckout($cart_id) {
    $cart = $this->cartRepository->loadCart($cart_id);
    
    if (!$cart || $cart->getItems()->count() === 0) {
      throw new NotFoundHttpException('Cart is empty');
    }
    
    if (!$this->canProcedeToCheckout($cart)) {
      return JsonResponse([
        'success' => FALSE,
        'errors' => ['Cannot proceed to checkout due to inventory issues'],
      ], 422);
    }
    
    // 冻结库存
    $this->reserveStockForCart($cart);
    
    return JsonResponse([
      'success' => TRUE,
      'data' => [
        'checkout_token' => $this->generateCheckoutToken($cart),
        'expires_at' => REQUEST_TIME + (HOUR),
        'next_step' => 'shipping_address',
      ],
    ]);
  }
  
  // ========== 辅助方法 ==========
  
  protected function formatCartResponse(CartInterface $cart): array {
    return [
      'cart_id' => $cart->id(),
      'created_at' => date('Y-m-d H:i:s', $cart->getCreated()),
      'updated_at' => date('Y-m-d H:i:s', $cart->getChanged()),
      'status' => 'active',
      'currency' => $cart->getCurrency()->getId(),
      'subtotal' => $cart->getSubtotal()->toString(),
      'shipping_total' => $cart->getShippingTotal()->toString(),
      'tax_total' => $cart->getTotalTax()->toString(),
      'total' => $cart->getTotalAmount()->toString(),
      'items_count' => count($cart->getItems()),
      'items' => array_map(function($item) {
        return [
          'line_item_id' => $item->id(),
          'variation_id' => $item->getProductVariation()->id(),
          'title' => $item->getTitle(),
          'quantity' => $item->getQuantity(),
          'price' => $item->getPrice()->toString(),
          'unit_price' => $item->getUnitPrice()->toString(),
          'total' => $item->getPrice()->toString(),
          'options' => $this->formatLineItemOptions($item),
        ];
      }, iterator_to_array($cart->getItems())),
    ];
  }
  
  protected function canAccessCart(CartInterface $cart): bool {
    $user = $this->currentUser();
    
    // 所有者可以直接访问
    if ($cart->getOwner()->id() === $user->id()) {
      return TRUE;
    }
    
    // 管理员可以访问任何购物车
    if ($user->hasPermission('administer commerce carts')) {
      return TRUE;
    }
    
    return FALSE;
  }
}
```

### 2. GraphQL Schema 定义

```php
use Drupal\graphql\Plugin\QueryExtensionPluginInterface;

/**
 * GraphQL 扩展 - 购物车查询
 */
class CartGraphQLExtension implements QueryExtensionPluginInterface {
  
  public function buildSchema(): string {
    return <<<GRAPHQL
extend type Query {
  cart(id: ID!): Cart
  carts(userId: ID, status: String): [Cart!]
  
  # 结账流程查询
  checkout(cartId: ID!): CheckoutSession
  
  # 优惠券验证
  validateCoupon(code: String!, cartId: ID!): CouponValidation
}

extend type Mutation {
  # 购物车操作
  addToCart(input: AddToCartInput!): AddToCartResult
  removeFromCart(lineItemId: ID!): Boolean!
  updateCartQuantity(lineItemId: ID!, quantity: Int!): UpdateCartResult
  
  # 结账流程
  createCheckout(cartId: ID!, input: CreateCheckoutInput!): CheckoutSession!
  submitOrder(input: SubmitOrderInput!): OrderCreateResult
  
  # 优惠券
  applyCoupon(cartId: ID!, code: String!): ApplyCouponResult
  removeCoupon(cartId: ID!, couponId: ID!): RemoveCouponResult
}

type Cart {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  currency: Currency!
  subtotal: Price!
  shippingTotal: Price!
  taxTotal: Price!
  total: Price!
  items: [CartItem!]!
  itemCount: Int!
}

type CartItem {
  lineItemId: ID!
  productId: ID!
  variationId: ID!
  title: String!
  quantity: Int!
  price: Price!
  unitPrice: Price!
  options: [ProductOption!]
}

input AddToCartInput {
  variationId: ID!
  quantity: Int!
  options: [ProductOptionInput!]
}

type AddToCartResult {
  success: Boolean!
  cart: Cart
  errors: [String!]
}

type CheckoutSession {
  token: String!
  expiresAt: DateTime!
  steps: [CheckoutStep!]!
  currentStep: String!
  cart: Cart!
}

scalar DateTime
scalar Price
scalar Currency
GRAPHQL;
  }
}
```

### 3. 测试客户端示例

```javascript
// JavaScript - 购物车 API 客户端
class CartAPIClient {
  constructor(baseUrl, authToken = null) {
    this.baseUrl = baseUrl;
    this.authToken = authToken;
    this.headers = {
      'Content-Type': 'application/json',
      ...(authToken && { 'Authorization': `Bearer ${authToken}` })
    };
  }
  
  /**
   * 创建购物车
   */
  async createCart() {
    const response = await fetch(`${this.baseUrl}/api/v1/carts`, {
      method: 'POST',
      headers: this.headers
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response.json();
  }
  
  /**
   * 获取购物车
   */
  async getCart(cartId) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}`,
      { headers: this.headers }
    );
    
    return response.json();
  }
  
  /**
   * 添加商品到购物车
   */
  async addToCart(cartId, variationId, quantity, options = {}) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/items`,
      {
        method: 'POST',
        headers: this.headers,
        body: JSON.stringify({
          variation_id: variationId,
          quantity: quantity,
          options: options
        })
      }
    );
    
    return response.json();
  }
  
  /**
   * 更新商品数量
   */
  async updateCartItem(cartId, itemId, quantity) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/items/${itemId}`,
      {
        method: 'PATCH',
        headers: this.headers,
        body: JSON.stringify({ quantity: quantity })
      }
    );
    
    return response.json();
  }
  
  /**
   * 删除商品
   */
  async removeCartItem(cartId, itemId) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/items/${itemId}`,
      {
        method: 'DELETE',
        headers: this.headers
      }
    );
    
    return response.json();
  }
  
  /**
   * 清空购物车
   */
  async clearCart(cartId) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/clear`,
      {
        method: 'POST',
        headers: this.headers
      }
    );
    
    return response.json();
  }
  
  /**
   * 验证优惠券
   */
  async validateCoupon(cartId, code) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/coupons/validate`,
      {
        method: 'POST',
        headers: this.headers,
        body: JSON.stringify({ code: code })
      }
    );
    
    return response.json();
  }
  
  /**
   * 应用优惠券
   */
  async applyCoupon(cartId, code) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/coupons/apply/${code}`,
      {
        method: 'POST',
        headers: this.headers
      }
    );
    
    return response.json();
  }
  
  /**
   * 计算运费
   */
  async calculateShipping(cartId, address) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/shipping/calculate`,
      {
        method: 'POST',
        headers: this.headers,
        body: JSON.stringify({ ...address })
      }
    );
    
    return response.json();
  }
  
  /**
   * 获取结账信息
   */
  async initiateCheckout(cartId) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/carts/${cartId}/checkout/initiate`,
      {
        method: 'POST',
        headers: this.headers
      }
    );
    
    return response.json();
  }
  
  /**
   * 提交订单
   */
  async submitOrder(token, orderData) {
    const response = await fetch(
      `${this.baseUrl}/api/v1/checkout/submit`,
      {
        method: 'POST',
        headers: {
          ...this.headers,
          'X-Checkout-Token': token
        },
        body: JSON.stringify(orderData)
      }
    );
    
    return response.json();
  }
}

// 使用示例
const api = new CartAPIClient('https://api.yourstore.com', userAuthToken);

// 创建购物车
const cart = await api.createCart();
console.log('Cart created:', cart.data.cart_id);

// 添加商品
await api.addToCart(cart.data.cart_id, 123, 2, { size: 'L', color: 'red' });

// 获取购物车详情
const cartDetail = await api.getCart(cart.data.cart_id);
console.log('Cart total:', cartDetail.data.total);

// 验证并使用优惠券
const validation = await api.validateCoupon(cart.data.cart_id, 'SAVE10');
if (validation.success) {
  await api.applyCoupon(cart.data.cart_id, 'SAVE10');
}

// 开始结账
const checkout = await api.initiateCheckout(cart.data.cart_id);
console.log('Checkout token:', checkout.data.checkout_token);
```

---

## 📋 数据表结构

### cart_api_log
API 调用日志

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 自增 ID |
| request_method | VARCHAR(10) | NOT NULL | HTTP 方法 |
| endpoint | VARCHAR(255) | NOT NULL | 请求端点 |
| user_id | INT | NULLABLE | 用户 ID |
| ip_address | VARCHAR(45) | NULLABLE | IP 地址 |
| request_time | DATETIME | NOT NULL | 请求时间 |
| response_status | INT | NOT NULL | 响应状态码 |
| response_time_ms | INT | NOT NULL | 响应耗时（毫秒） |

**索引**:
- `idx_endpoint_time` ON (endpoint, request_time DESC)
- `idx_user_time` ON (user_id, request_time DESC)

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\commerce_cart\Api\CartApiControllerTest;

class CartApiTest extends KernelTestBase {
  
  protected static $modules = ['cart_api', 'jsonapi'];
  
  public function testCreateCartSuccess() {
    $controller = \Drupal::service('cart_api.controller');
    
    $response = $controller->createCart();
    
    $this->assertEquals(200, $response->getStatusCode());
    $data = json_decode($response->getContent(), TRUE);
    $this->assertTrue($data['success']);
    $this->assertArrayHasKey('cart_id', $data['data']);
  }
  
  public function testAddItemInsufficientStock() {
    // 创建只有 1 件库存的商品
    $low_stock_product = $this->createLowStockProduct(1);
    $cart = $this->createCart();
    
    // 尝试添加 2 件
    $response = $this->addItemToCart($cart->id(), $low_stock_product->id(), 2);
    
    $this->assertEquals(422, $response->getStatusCode());
    $data = json_decode($response->getContent(), TRUE);
    $this->assertFalse($data['success']);
    $this->assertEquals('Not enough stock available', $data['errors'][0]);
  }
  
  public function testCouponValidation() {
    $cart = $this->createCartWithTotal(100);
    $valid_coupon = $this->createValidCoupon('SAVE10', 10, 'percentage');
    
    $response = $this->validateCoupon($cart->id(), 'SAVE10');
    
    $this->assertEquals(200, $response->getStatusCode());
    $data = json_decode($response->getContent(), TRUE);
    $this->assertTrue($data['success']);
    $this->assertEquals(10.00, $data['data']['discount_amount']);
  }
}
```

### 集成测试

```gherkin
Feature: Cart REST API
  As a mobile app developer
  I want to use the Cart API to manage shopping carts
  
  Scenario: Creating a guest cart from mobile app
    Given I am a mobile user without authentication
    When I call POST /api/v1/carts
    Then I should receive a cart_id
    And I can use this cart_id for subsequent requests
    
  Scenario: Adding items with product options
    Given I have a valid cart
    When I call POST /carts/{cart_id}/items with variation_id and options
    Then the item should be added with specified options
    And the cart total should update correctly
    
  Scenario: Applying valid coupon code
    Given my cart meets minimum requirements
    When I send POST /carts/{cart_id}/coupons/validate with a valid code
    Then the API should return success
    And the discount should be calculated correctly
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **API 平均响应时间** | AVG(response_time_ms) | < 200ms |
| **错误率** | (5xx + 4xx) / Total Requests | < 1% |
| **QPS (Queries Per Second)** | Requests / Time Window | 视流量而定 |
| **Cache Hit Rate** | Cache hits / Total lookups | > 80% |

### 日志命令

```bash
# 查看 API 调用日志
drush watchdog-view cart_api --count=50

# 查询慢请求
drush sql-query "
  SELECT endpoint, 
         AVG(response_time_ms) as avg_time,
         COUNT(*) as request_count
  FROM cart_api_log
  WHERE request_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
  GROUP BY endpoint
  ORDER BY avg_time DESC
  LIMIT 10
"

# 导出 API 分析报告
drush php-script export_cart_api_report
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| JSON:API Specification | https://jsonapi.org/ |
| OpenAPI Specification | https://swagger.io/specification/ |
| GraphQL Specification | https://graphql.org/learn/ |

---

## 🆘 常见问题

### Q1: 如何处理并发修改冲突？

**答案**：
```php
class OptimisticLockingMiddleware {
  
  public function handle(Request $request, $handler) {
    // 获取当前版本的购物车
    $cart = \Drupal::service('cart.repository')->load($cart_id);
    $current_version = $cart->getRevisionId();
    
    // 客户端携带版本信息
    $client_version = $request->headers->get('If-Match');
    
    if ($client_version && $client_version != $current_version) {
      return JsonResponse([
        'success' => FALSE,
        'errors' => ['Cart has been modified. Please refresh.'],
        'current_version' => $current_version,
      ], 409); // Conflict
    }
    
    // 继续处理...
  }
}
```

### Q2: 如何实现购物车同步？

**答案**：
```php
class CrossDeviceCartSync {
  
  public function syncCartBetweenDevices(UserInterface $user, string $source_session_id) {
    // 1. 获取所有设备的购物车
    $carts_by_device = $this->getCartsByDevice($user->id());
    
    // 2. 合并购物车项目（去重 + 数量累加）
    $merged_cart = $this->mergeCarts($carts_by_device);
    
    // 3. 保存为主购物车
    $primary_cart = reset($merged_cart);
    foreach ($merged_cart as $cart) {
      if ($cart !== $primary_cart) {
        $this->transferItemsToPrimary($cart, $primary_cart);
        $this->archiveCart($cart);
      }
    }
    
    // 4. 通知各设备刷新
    $this->notifyDeviceRefresh($user->id(), $primary_cart->id());
  }
  
  private function mergeCarts(array $carts): array {
    $all_items = [];
    
    foreach ($carts as $cart) {
      foreach ($cart->getItems() as $item) {
        $key = "{$item->getProductVariation()->id()}" . 
               "_" . $this->serializeOptions($item->getOptions());
        
        if (isset($all_items[$key])) {
          $all_items[$key]['quantity'] += $item->getQuantity();
        } else {
          $all_items[$key] = [
            'variation_id' => $item->getProductVariation()->id(),
            'quantity' => $item->getQuantity(),
            'options' => $item->getOptions(),
          ];
        }
      }
    }
    
    // 返回合并后的结果
    return $all_items;
  }
}
```

### Q3: 如何保证 API 安全性？

**答案**：
```php
// 1. CORS 配置
$config['cors.settings']['allowed_origins'] = [
  'https://yourstore.com',
  'https://app.yourstore.com',
];

// 2. 输入验证中间件
class CartApiValidationMiddleware {
  
  public function process(Request $request) {
    // 验证 JSON 格式
    $data = json_decode($request->getContent(), TRUE);
    if (json_last_error() !== JSON_ERROR_NONE) {
      throw new BadRequestHttpException('Invalid JSON');
    }
    
    // XSS 过滤
    $sanitized = $this->sanitizeInput($data);
    
    // SQL 注入防护（使用参数化查询）
    // 依赖 Drupal Entity API 自动处理
    
    return $sanitized;
  }
}

// 3. 速率限制
$limiters = [
  '/api/v1/carts/*/items' => ['limit' => 100, 'window' => '1 minute'],
  '/api/v1/carts/*/checkout' => ['limit' => 10, 'window' => '1 hour'],
];
```

---

**大正，commerce-cart-api.md 已补充完成。继续下一个...** 🚀
