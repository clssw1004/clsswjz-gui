# 数据同步 API 规范

## 获取初始数据

获取服务器端的所有数据，用于客户端首次同步。

**请求**

```
GET /api/sync/initial
```

**响应**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "accountBooks": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountCategories": [
      {
        "id": "string",
        "name": "string",
        "icon": "string",
        "type": "number",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountItems": [
      {
        "id": "string",
        "accountBookId": "string",
        "categoryId": "string",
        "amount": "number",
        "type": "number",
        "description": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountShops": [
      {
        "id": "string",
        "name": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountSymbols": [
      {
        "id": "string",
        "name": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountFunds": [
      {
        "id": "string",
        "name": "string",
        "balance": "number",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountBookFunds": [
      {
        "id": "string",
        "accountBookId": "string",
        "fundId": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountBookUsers": [
      {
        "id": "string",
        "accountBookId": "string",
        "userId": "string",
        "role": "number",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ]
  }
}
```

## 批量同步数据

同步客户端和服务器端的数据变更。

**请求**

```
POST /api/sync/batch
```

**请求体**

```json
{
  "lastSyncTime": "string",
  "changes": {
    "accountBooks": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountCategories": [
      {
        "id": "string",
        "name": "string",
        "icon": "string",
        "type": "number",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountItems": [
      {
        "id": "string",
        "accountBookId": "string",
        "categoryId": "string",
        "amount": "number",
        "type": "number",
        "description": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountShops": [
      {
        "id": "string",
        "name": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountSymbols": [
      {
        "id": "string",
        "name": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountFunds": [
      {
        "id": "string",
        "name": "string",
        "balance": "number",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountBookFunds": [
      {
        "id": "string",
        "accountBookId": "string",
        "fundId": "string",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ],
    "accountBookUsers": [
      {
        "id": "string",
        "accountBookId": "string",
        "userId": "string",
        "role": "number",
        "createdAt": "number",
        "updatedAt": "number"
      }
    ]
  }
}
```

**响应**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "serverChanges": {
      // 与请求体中的 changes 结构相同
    },
    "conflicts": {
      // 与请求体中的 changes 结构相同
    }
  }
}
```

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 同步流程说明

1. 客户端首次同步时，调用 `GET /api/sync/initial` 获取服务器端的所有数据
2. 客户端后续同步时，调用 `POST /api/sync/batch` 上传本地变更并获取服务器端变更
3. 客户端处理服务器返回的变更：
   - 如果存在冲突，根据业务需求处理冲突
   - 如果没有冲突，直接应用服务器端的变更
4. 更新本地的最后同步时间
5. 完成同步 