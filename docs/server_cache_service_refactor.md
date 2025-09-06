# ServerCacheService 重构文档

## 重构目标

将WebRTC服务中的服务端HTTP请求方法封装到独立的`ServerCacheService`中，保持业务逻辑在`WebRTCService`中，提高代码的可维护性和复用性。

## 架构设计

### 职责分离
- **ServerCacheService**: 纯粹封装服务端HTTP请求方法，不包含业务逻辑
- **WebRTCService**: 保留所有WebRTC业务逻辑，使用ServerCacheService进行数据操作

## 重构内容

### 1. 创建 ServerCacheService

**文件位置**: `lib/services/server_cache_service.dart`

**功能特性**:
- 单例模式设计，确保全局唯一实例
- 纯粹封装服务端HTTP请求方法
- 不包含任何业务逻辑
- 提供通用的数据存储/获取方法

**主要方法**:

#### 通用HTTP方法
- `setData(String key, Map<String, dynamic> data)` - 存储数据
- `getData(String key)` - 获取数据
- `deleteData(String key)` - 删除数据

### 2. 重构 WebRTCService

**修改内容**:
- 移除直接的HTTP客户端调用
- 使用`ServerCacheService`的通用方法进行数据操作
- 保留所有WebRTC业务逻辑
- 保持原有功能不变

**重构的方法**:
- `_storeRoomData()` - 使用`ServerCacheService.setData(roomCode, data)`
- `_fetchRoomData()` - 使用`ServerCacheService.getData(roomCode)`
- `_storeAnswerToRoom()` - 使用`ServerCacheService.setData('${roomCode}_answer', answerData)`
- `_pollForAnswer()` - 使用`ServerCacheService.getData('${roomCode}_answer')`

## 重构优势

### 1. **职责分离**
- HTTP请求逻辑与业务逻辑完全分离
- `ServerCacheService`专注于HTTP通信
- `WebRTCService`专注于WebRTC业务逻辑

### 2. **复用性**
- `ServerCacheService`可以被其他服务复用
- 通用的HTTP请求接口

### 3. **维护性**
- 业务逻辑集中在WebRTCService中
- HTTP请求逻辑统一管理
- 更清晰的代码结构

### 4. **测试友好**
- 可以独立测试HTTP服务
- 便于Mock和单元测试
- 业务逻辑测试更简单

### 5. **扩展性**
- 易于添加新的HTTP接口
- 支持不同的存储后端
- 业务逻辑变更不影响HTTP层

## 使用示例

### ServerCacheService 基本用法
```dart
// 存储数据
final success = await ServerCacheService().setData('key', {'data': 'value'});

// 获取数据
final data = await ServerCacheService().getData('key');

// 删除数据
final deleted = await ServerCacheService().deleteData('key');
```

### WebRTCService 中的使用
```dart
// 存储房间数据
final success = await ServerCacheService().setData(roomCode, roomData);

// 获取房间数据
final roomData = await ServerCacheService().getData(roomCode);

// 存储Answer数据
final success = await ServerCacheService().setData('${roomCode}_answer', answerData);

// 获取Answer数据
final answerData = await ServerCacheService().getData('${roomCode}_answer');
```

## API接口

### 存储接口
- **路径**: `/api/cache/set`
- **方法**: POST
- **参数**: `{key: string, value: string}`

### 获取接口
- **路径**: `/api/cache/get`
- **方法**: POST
- **参数**: `{key: string}`
- **返回**: `{data: string}`

### 删除接口
- **路径**: `/api/cache/delete`
- **方法**: POST
- **参数**: `{key: string}`

## 注意事项

1. **职责分离**: `ServerCacheService`只负责HTTP请求，不包含业务逻辑
2. **数据格式**: 所有数据都以JSON字符串形式存储
3. **错误处理**: 所有方法都有异常捕获，失败时返回null或false
4. **单例模式**: 使用单例模式确保全局唯一实例
5. **向后兼容**: 保持原有WebRTC功能完全不变

## 架构优势

### 清晰的职责分离
- **ServerCacheService**: 纯粹的HTTP请求封装
- **WebRTCService**: 完整的WebRTC业务逻辑
- **职责明确**: 每个服务都有明确的职责范围

### 更好的可维护性
- 业务逻辑集中在WebRTCService中
- HTTP请求逻辑统一管理
- 代码结构更清晰

## 后续优化建议

1. **缓存过期**: 添加TTL支持
2. **批量操作**: 支持批量存储和获取
3. **监控统计**: 添加缓存命中率统计
4. **数据压缩**: 对大数据进行压缩存储
5. **持久化**: 支持本地缓存备份
6. **重试机制**: 添加网络请求重试逻辑
