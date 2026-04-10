# Drupal 展位预定系统 - 前后端分离与实体处理指南

> **核心原则**: JSON:API + 自定义实体 + 前后端分离架构

**适用场景**: 展位预定系统的现代化前端集成  
**技术栈**: Drupal 11 + JSON:API + Custom Entities  
**文档依据**: Drupal.org 官方最佳实践 + 社区讨论

---

## 🎯 架构概述

### 前后端分离模式

**Drupal 11最佳实践**（2026-04 验证）:

| 模式 | 适用场景 | 推荐度 |
|------|---------|--------|
| **JSON:API** | 默认 REST API | ✅ 首选 |
| **REST Resource Plugin** | 自定义接口 | ✅ 可用 |
| **GraphQL** | 复杂数据查询 | ⚠️ 需额外模块 |

**来源**:
- https://gole.ms/blog/best-practices-rest-apis-drupal-11
- https://www.thedroptimes.com/43903/best-practices-rest-api-development-in-drupal-11
- https://www.drupal.org/docs/develop/decoupled-drupal/getting-started-with-json-api-and-rest

---

## 🔌 JSON:API 集成

### 基础配置

**启用 JSON:API**:
```yaml
# admin/modules
Core modules (built):
  - [✓] JSON:API (drupal/core/modules/jsonapi)
```

**配置路径**:
```
/admin/config/services/jsonapi
```

**默认端点**:
```
GET  /jsonapi/exhibition/{exhibition-id}
GET  /jsonapi/booth
GET  /jsonapi/booth/{booth-id}
POST /jsonapi/booth
PUT  /jsonapi/booth/{booth-id}
DELETE /jsonapi/booth/{booth-id}
```

**来源**:
- https://www.drupal.org/docs/develop/decoupled-drupal/getting-started-with-json-api-and-rest

---

### 展位数据格式

**JSON:API 响应示例**:
```json
{
  "jsonapi": {
    "version": "1.0"
  },
  "data": {
    "type": "node--booth",
    "id": "123",
    "attributes": {
      "title": "A-001 VIP 展位",
      "field_booth_number": "A-001",
      "field_booth_area": {
        "value": 12,
        "unit": "sqm"
      },
      "field_booth_price": {
        "currency": "CNY",
        "amount": 12000
      },
      "field_booth_zone": "VIP",
      "field_booth_status": "available",
      "status": "published"
    },
    "relationships": {
      "field_exhibition": {
        "data": {
          "type": "node--exhibition",
          "id": "456"
        }
      }
    }
  },
  "links": {
    "self": {
      "href": "http://example.com/jsonapi/node--booth/123"
    }
  }
}
```

**来源**:
- https://www.drupal.org/jsonapi
- https://www.thedroptimes.com/64654/drupal-academy-releases-guide-customizing-jsonapi-with-jsonapi-extras

---

## 🛠️ 自定义 REST 端点

### REST Resource Plugin 实现

**创建自定义模块**:
```php
<?php
namespace Drupal\booth_rest;

use Drupal\Core\Url;
use Drupal\rest\ResourceInterface;

class BoothAvailabilityResource implements ResourceInterface {
  
  public function getResponse(
    \Symfony\Component\HttpFoundation\Request $request
  ) {
    $booth_id = $request->attributes->get('booth_id');
    
    // 获取展位信息
    $booth = \Drupal::entityTypeManager()
      ->getStorage('node')
      ->load($booth_id);
    
    if (!$booth) {
      return new \Symfony\Component\HttpFoundation\JsonResponse(
        ['error' => 'Booth not found'],
        404
      );
    }
    
    // 检查可用性
    $available = $this->checkBoothAvailability(
      $booth, 
      $request->get('start_date'), 
      $request->get('end_date')
    );
    
    return new \Symfony\Component\HttpFoundation\JsonResponse([
      'available' => $available,
      'price' => $booth->field_booth_price->value,
      'booth_number' => $booth->field_booth_number->value
    ]);
  }
  
  private function checkBoothAvailability($booth, $start, $end) {
    // 实现预定冲突检查逻辑
    // ...代码略
    return TRUE;
  }
}
```

**REST 资源配置**:
```yaml
# booth_rest.rest.booth_availability.yml
id: booth_availability
label: '展位可用性检查'
provider: booth_rest
serializer_format: json
serializer_classes:
  - 'node--booth'
resource_map:
  -
    base_path: '/api/booth/availability'
    route_name: 'rest.resource.booth_availability_response'
    methods: [GET, POST]
```

**来源**:
- https://drupak.com/blog/custom-rest-api-drupal-10-11-rest-resource-plugin-2025

---

### JSON:API Extras 扩展

**自定义字段展示**:
```yaml
# 使用 JSON:API Extras 扩展默认输出
jsonapi_extras_config:
  node__booth:
    default_fields:
      - title
      - field_booth_number
      - field_booth_area
      - field_booth_status
    extra_fields:
      computed:
        - is_available
        - effective_price
```

**计算字段示例**:
```php
<?php
namespace Drupal\booth_jsonapi\SubResource;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Session\AccountInterface;

class BoothAvailabilityChecker implements SubResourceInterface {
  
  public function getSubData($entity) {
    return [
      'is_available' => $this->checkAvailability($entity),
      'effective_price' => $this->calculatePrice($entity),
    ];
  }
  
  private function checkAvailability($booth) {
    // 自定义可用性检查逻辑
    return TRUE;
  }
}
```

**来源**:
- https://www.thedroptimes.com/64654/drupal-academy-releases-guide-customizing-jsonapi-with-jsonapi-extras

---

## 🎯 实体 API 最佳实践

### 自定义实体定义

**展位实体类**:
```php
<?php
namespace Drupal\booth\Entity;

use Drupal\taxonomy\Entity\TaxonomyTerm;
use Drupal\Core\Entity\EntityStorageInterface;
use Drupal\Core\Field\BaseFieldDefinition;

/**
 * 展位内容实体定义
 *
 * @ContentEntityType(
 *   id = "booth",
 *   label = @Translation("Booth"),
 *   handlers = {
 *     "storage" = "Drupal\booth\BoothStorage",
 *     "view_builder" = "Drupal\Core\Entity\EntityViewBuilder",
 *     "list_builder" = "Drupal\booth\BoothListBuilder",
 *     "views" = "Drupal\booth\BoothViews",
 *     "form" = {
 *       "default" = "Drupal\booth\Form\BoothForm",
 *       "edit" = "Drupal\booth\Form\BoothForm",
 *       "delete" = "Drupal\booth\Form\BoothDeleteForm"
 *     },
 *     "route_provider" = {
 *       "html" = "Drupal\booth\BoothHtmlRouteProvider",
 *     },
 *     "access" = "Drupal\booth\BoothAccessControlHandler",
 *   },
 *   base_table = "booth",
 *   entity_keys = {
 *     "id" = "id",
 *     "label" = "title",
 *     "uuid" = "uuid",
 *   },
 *  )
 */
class Booth extends ContentEntityBase implements BoothInterface {
  
  /**
   * {@inheritdoc}
   */
  public static function baseFieldDefinitions(EntityStorageInterface $storage) {
    $fields['title'] = BaseFieldDefinition::create('string')
      ->setLabel(t('Booth Number'))
      ->setDescription(t('展位编号'))
      ->setRequired(TRUE)
      ->setSettings([
        'max_length' => 255,
        'text_processing' => 0,
      ])
      ->setDefaultValue('');
    
    $fields['field_booth_area'] = BaseFieldDefinition::create('decimal')
      ->setLabel(t('Area'))
      ->setDescription(t('展位面积 (平方米)'))
      ->setRequired(TRUE)
      ->setSettings([
        'precision' => 8,
        'scale' => 2,
      ])
      ->setDefaultValue(0);
    
    $fields['field_booth_price'] = BaseFieldDefinition::create('commerce_price')
      ->setLabel(t('Price'))
      ->setDescription(t('展位价格'))
      ->setRequired(TRUE)
      ->setSettings([
        'currency' => 'CNY',
      ]);
    
    $fields['field_booth_zone'] = BaseFieldDefinition::create('entity_reference')
      ->setLabel(t('Zone'))
      ->setDescription(t('所属区域'))
      ->setRevisionable(TRUE)
      ->setSetting('target_type', 'taxonomy_term')
      ->setCardinality(1)
      ->setRequired(TRUE)
      ->setTranslatable(FALSE);
    
    // ... 更多字段定义
    return $fields;
  }
}
```

**来源**:
- https://www.drupal.org/docs/drupal-apis/entity-api/defining-and-using-content-entity-field-definitions
- https://www.augustinfotech.com/blogs/how-to-create-custom-entity-in-drupal-11/

---

### 实体存储处理

**自定义存储类**:
```php
<?php
namespace Drupal\booth;

use Drupal\Core\Entity\EntityStorageInterface;
use Drupal\commerce_price\PriceValue;

/**
 * 展位存储处理器
 *
 * @ContentEntityType(
 *   handlers = {
 *     "storage" = "Drupal\booth\BoothStorage",
 *   },
 * )
 */
class BoothStorage extends ContentEntityStorage implements BoothStorageInterface {
  
  /**
   * 检查展位可用性
   */
  public function getAvailableBooths($exhibition_id, $start_date, $end_date) {
    $query = $this->getQuery()
      ->condition('field_exhibition', $exhibition_id)
      ->condition('field_booth_status', 'available');
    
    // 排除已预定的展位
    $excluded_booths = $this->getReservedBooths($start_date, $end_date);
    if ($excluded_booths) {
      $query->condition('id', $excluded_booths, 'NOT IN');
    }
    
    return $query->execute();
  }
  
  /**
   * 获取已预定的展位 ID 列表
   */
  protected function getReservedBooths($start_date, $end_date) {
    $reservation_query = \Drupal::entityTypeManager()
      ->getStorage('booth_reservation')
      ->getQuery()
      ->condition('start_date', $start_date)
      ->condition('end_date', $end_date, '<=');
    
    // 处理预定冲突逻辑
    // ...代码略
    
    return $reservation_query->execute();
  }
  
  /**
   * 更新展位状态
   */
  public function updateBoothStatus($booth_id, $status) {
    $booth = $this->load($booth_id);
    if ($booth) {
      $booth->set('field_booth_status', $status);
      $booth->save();
    }
  }
}
```

**来源**:
- https://www.drupal.org/docs/drupal-apis/entity-api/working-with-the-entity-api

---

## 📊 前端集成示例

### React/Vue 组件

**展位列表组件**:
```javascript
// React 组件示例
import React, { useEffect, useState } from 'react';

const BoothList = ({ exhibitionId }) => {
  const [booths, setBooths] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchBooths();
  }, [exhibitionId]);

  const fetchBooths = async () => {
    try {
      setLoading(true);
      
      // 使用 JSON:API
      const response = await fetch(
        `/jsonapi/node--booth?filter[field_exhibition=${exhibitionId}]`
      );
      
      const data = await response.json();
      
      // 处理 JSON:API 数据结构
      const boothData = data.data.map(item => ({
        id: item.id,
        title: item.attributes['title'],
        area: item.attributes['field_booth_area'].value,
        price: item.attributes['field_booth_price'].amount,
        status: item.attributes['field_booth_status']
      }));
      
      setBooths(boothData);
    } catch (error) {
      console.error('Error fetching booths:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div className="booth-list">
      {booths.map(booth => (
        <div key={booth.id} className={`booth booth-${booth.status}`}>
          <h3>{booth.title}</h3>
          <p>面积：{booth.area} m²</p>
          <p>价格：¥{booth.price}</p>
          <button onClick={() => handleBook(booth.id)}>
            立即预订
          </button>
        </div>
      ))}
    </div>
  );
};

export default BoothList;
```

**来源**:
- https://www.drupal.org/docs/develop/decoupled-drupal/getting-started-with-json-api-and-rest

---

## 🔐 权限与安全

### 访问控制

**自定义访问处理器**:
```php
<?php
namespace Drupal\booth;

use Drupal\Core\Entity\EntityAccessControlHandler;
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Session\AccountInterface;

/**
 * 展位访问控制处理器
 */
class BoothAccessControlHandler extends EntityAccessControlHandler {
  
  /**
   * {@inheritdoc}
   */
  protected function checkAccess(EntityInterface $entity, $operation, AccountInterface $account) {
    $access = parent::checkAccess($entity, $operation, $account);
    
    if ($access->allowed) {
      // 额外的业务逻辑检查
      if ($operation === 'view') {
        $exhibition = $entity->get('field_exhibition')->first()->getValue()['target_id'];
        $exhibition_status = \Drupal\node\Entity\Node::load($exhibition)->get('status')->getValue();
        
        if (!$exhibition_status) {
          $access = \Drupal\Core\Access\AccessResult::forbidden();
        }
      }
    }
    
    return $access;
  }
  
  /**
   * {@inheritdoc}
   */
  protected function checkBulkAccess($account, $entity_type) {
    // 批量操作权限检查
    return \Drupal\Core\Access\AccessResult::allowedIfHasPermissions(
      $account,
      ['view own booth content', 'edit any booth content']
    );
  }
}
```

**来源**:
- https://www.augustinfotech.com/blogs/how-to-create-custom-entity-in-drupal-11/

---

## 📚 性能优化

### 缓存策略

**JSON:API 缓存配置**:
```yaml
# 启用 entity tags
jsonapi.settings:
  - resource: 'node--booth'
    cache_contexts: ['user.permissions', 'url.query_args']
    cache TTL: 3600
```

**实体缓存**:
```php
// 自定义缓存标签
public function getCacheTags() {
  $cache_tags = ['node:' . $this->id()];
  
  // 如果展位属于某个展会，添加展会相关缓存
  if ($this->field_exhibition->first()) {
    $exhibition_id = $this->field_exhibition->first()->target_id;
    $cache_tags[] = 'node:' . $exhibition_id;
  }
  
  return array_unique($cache_tags);
}
```

**来源**:
- https://www.drupal.org/docs/core/en/caching
- https://www.drupal.org/docs/ui-and-ux/user-interface-design-guidelines/caching-best-practices

---

## ⚠️ 最佳实践总结

### 推荐做法

**✅ DO**:
- 使用 JSON:API 作为默认 API
- 实现自定义实体时遵循标准模式
- 使用 PHP Attributes 替代 Annotation（Drupal 11）
- 实现完善的权限控制
- 配置缓存策略提升性能
- 所有 API 响应包含错误处理

**❌ DON'T**:
- 不要在 API 中暴露敏感数据
- 不要绕过 Entity API 直接查询数据库
- 不要忽略缓存配置
- 不要在自定义实体中硬编码业务逻辑
- 不要忽略权限检查

**来源**:
- https://gole.ms/blog/best-practices-rest-apis-drupal-11
- https://www.thedroptimes.com/43903/best-practices-rest-api-development-in-drupal-11

---

**文档版本**: v1.0  
**最后更新**: 2026-04-05  
**技术栈**: Drupal 11 + JSON:API + Custom Entities + REST API  
**来源**: Drupal.org 官方文档 + 社区最佳实践 + 开发者讨论

---

**补充说明**: 本文档涵盖展位预定系统的 API 集成、实体处理和前后端分离架构，为现代化前端应用提供后端支持。
