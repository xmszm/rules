# 搜索工具选择策略

> 本文件在 Step 2 执行时按需加载（仅当归档未找到或信息不完整时）

## 📋 目录

- [工具选择决策树](#工具选择决策树)
  - Ripgrep/Grep（精确文本搜索）
  - 文件名匹配（Glob 或 `rg --files`）
  - Read（上下文读取）
- [工具对比矩阵](#工具对比矩阵)
- [多项目环境特殊处理](#多项目环境特殊处理)
- [搜索结果处理](#搜索结果处理)

---

## 工具选择决策树

### 1. Ripgrep/Grep（精确文本搜索）

**使用场景**：
- ✅ 已知类名/函数名/变量名
- ✅ 查找具体字符串出现的位置
- ✅ 需要查找所有引用

**优势**：
- 精确匹配
- 支持正则表达式
- 可以限定搜索路径

**参数配置**：
```javascript
{
  pattern: "class UserController",  // 搜索内容
  path: "$PROJECT_ROOT",            // 限定搜索范围
  output_mode: "content",           // 显示匹配行内容
  -n: true,                         // 显示行号
  -C: 3                             // 显示上下3行
}
```

**常用模式**：

#### 查找类定义
```javascript
pattern: "class LoginComponent"
pattern: "interface UserInfo"
pattern: "function calculateTotal"
```

#### 查找导入/引用
```javascript
pattern: "import.*UserService"
pattern: "from.*auth.*import"
```

#### 查找配置/常量
```javascript
pattern: "API_BASE_URL"
pattern: "const.*THEME"
```

**约束**：
- ⚠️ **必须指定 `path: "$PROJECT_ROOT"`**，避免搜索其他项目

---

### 2. Glob（文件名模式匹配）

**使用场景**：
- ✅ 已知文件名或文件名模式
- ✅ 查找特定类型的文件
- ✅ 快速定位文件位置

**优势**：
- 速度快
- 支持通配符
- 不读取文件内容

**参数配置**：
```javascript
{
  pattern: "**/*.vue",       // 查找所有 Vue 文件
  path: "$PROJECT_ROOT"      // 限定搜索范围
}
```

**常用模式**：

#### 查找特定文件
```javascript
pattern: "**/Login.vue"
pattern: "**/UserController.java"
```

#### 查找特定类型文件
```javascript
pattern: "**/*.scss"          // 所有样式文件
pattern: "**/*Service.ts"     // 所有服务文件
pattern: "**/api/*.js"        // api 目录下的 JS 文件
```

**约束**：
- ⚠️ **必须指定 `path: "$PROJECT_ROOT"`**

---

### 3. Read（上下文读取）

**使用场景**：
- ✅ 已定位到目标文件
- ✅ 需要确认上下文、调用链、边界条件

**策略**：
- 只读取必要片段，避免整库扫描

---

## 组合使用策略

### 场景 1：完全不知道在哪里
**步骤**：
1. 先用 **Grep/Ripgrep** 搜业务关键词（如 `login|auth|token`）
2. 获得文件路径后，用 **Read** 工具读取关键片段

### 场景 2：知道关键词但不知道文件
**步骤**：
1. 用 **Grep** 搜索关键词（如 `pattern: "login"`）
2. 从结果中定位具体文件
3. 用 **Read** 工具读取

### 场景 3：知道文件名模式
**步骤**：
1. 用 **Glob** 快速找到文件（如 `pattern: "**/Login*"`）
2. 用 **Read** 工具读取

### 场景 4：需要查找所有引用
**步骤**：
1. 用 **Grep** 搜索（如 `pattern: "UserService"`）
2. 设置 `output_mode: "files_with_matches"` 查看所有包含该引用的文件

---

## 搜索约束（强制）

### 1. 路径限定
**所有搜索必须限定在 `$PROJECT_ROOT` 范围内**

**正确示例**：
```javascript
// Grep
{ pattern: "xxx", path: "project-a/" }

// Glob
{ pattern: "**/*.js", path: "project-a/" }
```

**错误示例**：
```javascript
// ❌ 未指定 path，会搜索所有项目
{ pattern: "xxx" }
```

### 2. 搜索深度
**前端项目常见目录**：
- `src/`
- `components/`
- `views/` 或 `pages/`
- `store/`
- `utils/`

**后端项目常见目录**：
- `src/main/java/`（Java）
- `controller/`、`service/`、`dao/`
- `api/`、`handlers/`

### 3. 排除目录
**建议在 Grep 中排除**：
- `node_modules/`
- `dist/`、`build/`
- `.git/`
- 测试覆盖率报告目录

---

## 输出处理

### Grep 输出模式

**content**（默认）：
- 显示匹配的行及其内容
- 适合阅读代码上下文

**files_with_matches**：
- 仅显示文件路径
- 适合快速定位文件

**count**：
- 显示每个文件的匹配数量
- 适合统计分析

---

## 实战示例

### 示例 1：查找登录功能
```javascript
// 第一步：关键词搜索
Grep {
  pattern: "function.*login|login.*function",
  path: "project-a/",
  output_mode: "content",
  -n: true
}
```

### 示例 2：查找所有 API 接口文件
```javascript
// 第一步：文件模式匹配
Glob {
  pattern: "**/api/*.ts",
  path: "tai-enjoy-api/"
}

// 第二步：读取具体文件
Read { file_path: "tai-enjoy-api/src/api/user.ts" }
```

### 示例 3：查找某个组件的所有引用
```javascript
Grep {
  pattern: "import.*LoginForm",
  path: "project-a/",
  output_mode: "files_with_matches"
}
```
