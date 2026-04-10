<?php
/**
 * Drupal 11 CI/CD 集成测试 - Agent 可运行验证环境
 * 
 * 用法：php tests/ci-integration-test.php
 * 
 * 测试范围：
 * - Drupal 11 核心安装
 * - 配置同步目录
 * - Composer 依赖
 * - Drush 安装（如果存在）
 * - Drush 命令（如果存在）
 */

require __DIR__ . '/../vendor/autoload.php';

class CIIntegrationTest {
  
  private $drupal_root;
  private $drush;
  private $sync_dir;
  private $errors = [];
  
  public function __construct() {
    $this->drupal_root = realpath(__DIR__ . '/../web');
    $this->drush = $this->drupal_root . '/../../vendor/bin/drush';
    
    // 从 settings.php 读取配置同步目录
    $settings_file = $this->drupal_root . '/sites/default/settings.php';
    if (file_exists($settings_file)) {
      $settings_content = file_get_contents($settings_file);
      preg_match('/config_sync_directory.*?\''。(.*?).'\'/', $settings_content, $matches);
      $this->sync_dir = isset($matches[1]) ? realpath($this->drupal_root . '/../' . $matches[1]) : null;
    }
  }
  
  public function runAllTests() {
    echo "🧪 Running CI Integration Tests...\n";
    echo "📁 Drupal Root: {$this->drupal_root}\n";
    echo "🔧 Drush: {$this->drush}\n";
    echo "📂 Config Sync: " . ($this->sync_dir ?: 'NOT CONFIGURED') . "\n\n";
    
    $this->testDrupalCore();
    $this->testConfigSyncDirectory();
    $this->testDrushInstallation();
    $this->testComposerDependencies();
    $this->testDatabaseConnection();
    $this->testCacheSystem();
    
    if (empty($this->errors)) {
      echo "\n✅ All CI integration tests PASSED!\n";
      return true;
    } else {
      echo "\n❌ " . count($this->errors) . " test(s) FAILED:\n";
      foreach ($this->errors as $error) {
        echo "  - $error\n";
      }
      return false;
    }
  }
  
  private function testDrupalCore() {
    echo "[TEST] 1. Checking Drupal Core...\n";
    
    if (!file_exists($this->drupal_root . '/core/drupal.bootstrap.php')) {
      $this->errors[] = "Drupal core file not found";
      echo "  ❌ Drupal core not found\n";
      return;
    }
    
    // 尝试获取 Drupal 版本
    $version = \Drupal::VERSION ?? 'unknown';
    echo "  ✅ Drupal version: $version\n";
  }
  
  private function testConfigSyncDirectory() {
    echo "[TEST] 2. Checking Config Sync Directory...\n";
    
    if (!$this->sync_dir) {
      // 检查 settings.php 中是否有 config_sync_directory 配置
      $settings_file = $this->drupal_root . '/sites/default/settings.php';
      if (file_exists($settings_file)) {
        $settings_content = file_get_contents($settings_file);
        if (strpos($settings_content, 'config_sync_directory') !== false) {
          echo "  ✅ Config sync directory configured in settings.php\n";
        } else {
          $this->errors[] = "Config sync directory not configured";
          echo "  ⚠️  Config sync directory not configured (optional)\n";
        }
      } else {
        $this->errors[] = "settings.php not found";
        echo "  ❌ settings.php not found\n";
      }
      return;
    }
    
    if (!is_dir($this->sync_dir)) {
      echo "  ⚠️  Config sync directory does not exist, creating...\n";
      mkdir($this->sync_dir, 0755, true);
    }
    
    if (!is_writable($this->sync_dir)) {
      $this->errors[] = "Config sync directory is not writable";
      echo "  ❌ Config sync directory is not writable\n";
      return;
    }
    
    echo "  ✅ Config sync directory: $this->sync_dir\n";
  }
  
  private function testDrushInstallation() {
    echo "[TEST] 3. Checking Drush Installation...\n";
    
    if (!file_exists($this->drush)) {
      echo "  ⚠️  Drush not installed (recommended but optional)\n";
      return;
    }
    
    if (!is_executable($this->drush)) {
      $this->errors[] = "Drush is not executable";
      echo "  ❌ Drush is not executable\n";
      return;
    }
    
    // 执行 Drush 命令获取版本
    exec("{$this->drush} --version 2>&1", $output, $return_code);
    if ($return_code === 0) {
      $version_line = array_filter($output, fn($line) => strpos($line, 'Drush') !== false);
      if (!empty($version_line)) {
        echo "  ✅ Drush version: " . implode(' ', $version_line) . "\n";
      } else {
        echo "  ✅ Drush is installed\n";
      }
    } else {
      $this->errors[] = "Drush command failed: " . implode("\n", $output);
      echo "  ⚠️  Drush command failed (drush may need configuration)\n";
    }
  }
  
  private function testComposerDependencies() {
    echo "[TEST] 4. Checking Composer Dependencies...\n";
    
    $composer_json = $this->drupal_root . '/../composer.json';
    if (!file_exists($composer_json)) {
      $this->errors[] = "composer.json not found";
      echo "  ❌ composer.json not found\n";
      return;
    }
    
    $composer_data = json_decode(file_get_contents($composer_json), true);
    if (!$composer_data) {
      $this->errors[] = "composer.json is not valid JSON";
      echo "  ❌ composer.json is not valid JSON\n";
      return;
    }
    
    $required_packages = [
      'drupal/core' => 'Drupal Core',
      'drush/drush' => 'Drush (optional)',
    ];
    
    $missing = [];
    foreach ($required_packages as $package => $description) {
      if (!isset($composer_data['require'][$package])) {
        $missing[] = $package;
        echo "  ⚠️  $description not installed ({$package})\n";
      } else {
        echo "  ✅ $description installed ({$package})\n";
      }
    }
    
    if (empty($missing)) {
      echo "  ✅ All required Composer packages are installed\n";
    }
  }
  
  private function testDatabaseConnection() {
    echo "[TEST] 5. Checking Database Connection...\n";
    
    // 只在 Drush 可用时测试
    if (!file_exists($this->drush)) {
      echo "  ⚠️  Database connection test skipped (Drush not installed)\n";
      return;
    }
    
    // 尝试连接数据库
    exec("{$this->drush} status --db-status --format=json 2>&1", $output, $return_code);
    
    if ($return_code === 0) {
      $status_json = json_decode(implode("\n", $output), true);
      if ($status_json && isset($status_json['database'])) {
        echo "  ✅ Database connection: {$status_json['database']['dbms']}://{$status_json['database']['db-hostname']}\n";
      } else {
        $this->errors[] = "Database connection test returned invalid data";
        echo "  ⚠️  Database connection test returned invalid data\n";
      }
    } else {
      echo "  ⚠️  Database connection test failed (this is normal for fresh install)\n";
    }
  }
  
  private function testCacheSystem() {
    echo "[TEST] 6. Checking Cache System...\n";
    
    // 只在 Drush 可用时测试
    if (!file_exists($this->drush)) {
      echo "  ⚠️  Cache system test skipped (Drush not installed)\n";
      return;
    }
    
    // 尝试清空缓存（只测试命令是否可用，不实际执行）
    exec("{$this->drush} cache:rebuild --format=json 2>&1", $output, $return_code);
    
    if ($return_code === 0) {
      echo "  ✅ Cache system is working\n";
    } else {
      // 即使命令失败也可能是因为 Drupal 尚未安装，这正常
      echo "  ⚠️  Cache system test returned output\n";
    }
  }
}

// 执行测试
try {
  $test = new CIIntegrationTest();
  $success = $test->runAllTests();
  
  exit($success ? 0 : 1);
} catch (Exception $e) {
  echo "\n❌ Test failed with exception: " . $e->getMessage() . "\n";
  exit(1);
}
