# 变量定义说明

> 本文档定义了 xmszm-code-workflow skill 中使用的所有变量及其含义

## 📋 目录

- [核心变量](#核心变量)
  - $PROJECT_ROOT
  - $PROJECT_NAME
  - $ARCHIVE_PATH
- [使用示例](#使用示例)
  - 多项目环境示例
  - 单项目环境示例
- [变量关系图](#变量关系图)

---

## 核心变量

### $PROJECT_ROOT
**定义**：项目根目录的**相对路径**（相对于当前工作目录）

**取值规则**：
- **多项目环境**：子项目目录名（含末尾斜杠）
  - 示例：`project-a/`、`project-b/`
- **单项目环境**：当前目录
  - 值：`.`

**用途**：
- 限定搜索范围（Grep/Glob 的 `path` 参数）
- 构建文件路径
- 确定归档位置

**示例**：
```javascript
// 多项目环境
$PROJECT_ROOT = "project-a/"
文件路径 = $PROJECT_ROOT + "src/views/Login.vue"
      = "project-a/src/views/Login.vue"

// 单项目环境
$PROJECT_ROOT = "."
文件路径 = $PROJECT_ROOT + "/src/views/Login.vue"
      = "./src/views/Login.vue"
```

---

### $PROJECT_NAME
**定义**：项目名称，取自 `$PROJECT_ROOT` 的目录名

**取值规则**：
- 去除 `$PROJECT_ROOT` 末尾的斜杠
- 若 `$PROJECT_ROOT = .`，则从 `package.json` 等配置文件中读取项目名

**示例**：
```javascript
$PROJECT_ROOT = "tai-enjoy-admin/"
$PROJECT_NAME = "tai-enjoy-admin"

$PROJECT_ROOT = "."
$PROJECT_NAME = (从 package.json 的 name 字段读取，如 "my-project")
```

**用途**：
- 更新根索引 `projects.md` 时的章节标题
- 初始化归档文件时的项目标识
- 生成 changelog 时的项目引用

---

### $ARCHIVE_PATH
**定义**：归档目录的完整路径

**取值规则**：
```javascript
$ARCHIVE_PATH = $PROJECT_ROOT + ".xmszm/"
```

**示例**：
```javascript
// 多项目环境
$PROJECT_ROOT = "tai-enjoy-admin/"
$ARCHIVE_PATH = "tai-enjoy-admin/.xmszm/"

// 单项目环境
$PROJECT_ROOT = "."
$ARCHIVE_PATH = ".xmszm/"
```

**用途**：
- 读取归档文件：`$ARCHIVE_PATH/index.md`
- 读取页面归档：`$ARCHIVE_PATH/pages/login.md`
- 更新 changelog：`$ARCHIVE_PATH/changelog/2026-01.md`

---

## 辅助变量

### $TASK_TYPE
**定义**：任务类型，用于定位归档文件

**可能值**：
- `page`：页面相关
- `component`：组件相关
- `api`：接口/API
- `database`：数据库/模型
- `service`：业务逻辑
- `utils`：工具函数
- `config`：配置
- `unknown`：无法判断

**取值来源**：根据用户输入的关键词判断（参见 `task-type-mapping.md`）

**用途**：确定读取哪个归档文件

---

### $TARGET_FILE
**定义**：归档目标文件的路径

**取值规则**：
```javascript
if ($TASK_TYPE == "page") {
  $TARGET_FILE = $ARCHIVE_PATH + "pages/" + 页面名 + ".md"
} else if ($TASK_TYPE == "api") {
  $TARGET_FILE = $ARCHIVE_PATH + "guides/api.md"
} else {
  $TARGET_FILE = $ARCHIVE_PATH + "guides/" + $TASK_TYPE + ".md"
}
```

**示例**：
```javascript
$TASK_TYPE = "page", 页面名 = "login"
$TARGET_FILE = "tai-enjoy-admin/.xmszm/pages/login.md"

$TASK_TYPE = "api"
$TARGET_FILE = "tai-enjoy-admin/.xmszm/guides/api.md"
```

---

### $CURRENT_DATE
**定义**：当前日期（YYYY-MM-DD 格式）

**示例**：`2026-01-04`

**用途**：
- 更新 changelog
- 标记最后变更时间
- 创建归档记录

---

### $CURRENT_MONTH
**定义**：当前年月（YYYY-MM 格式）

**示例**：`2026-01`

**用途**：
- 确定 changelog 文件名：`$CURRENT_MONTH.md`

---

## 环境检测变量

### $IS_MULTI_PROJECT
**定义**：是否为多项目环境

**可能值**：
- `true`：多项目环境
- `false`：单项目环境

**取值规则**：
- 检测到 ≥ 2 个包含项目标识文件的子目录 → `true`
- 否则 → `false`

**用途**：
- 决定是否创建/更新根索引 `projects.md`
- 确定 `$PROJECT_ROOT` 的取值方式

---

### $DETECTED_PROJECTS
**定义**：检测到的所有项目列表（仅多项目环境）

**数据结构**：
```javascript
[
  {
    name: "tai-enjoy-admin",
    path: "tai-enjoy-admin/",
    description: "管理后台",
    tech_stack: "Vue 3, Element Plus"
  },
  {
    name: "tai-enjoy-api",
    path: "tai-enjoy-api/",
    description: "后端API",
    tech_stack: "Spring Boot"
  }
]
```

**用途**：
- 初始化根索引 `projects.md`
- 提供项目选择列表

---

## 变量优先级

在执行过程中，变量的设置顺序：

1. **Step 0 开始前**：检测环境，设置 `$IS_MULTI_PROJECT`、`$DETECTED_PROJECTS`
2. **Step 0 执行**：设置 `$PROJECT_ROOT`、`$PROJECT_NAME`、`$ARCHIVE_PATH`
3. **Step 1 执行**：设置 `$TASK_TYPE`、`$TARGET_FILE`
4. **Step 5 执行**：设置 `$CURRENT_DATE`、`$CURRENT_MONTH`

---

## 变量使用示例

### 示例 1：读取归档文件
```javascript
// Step 1: 查（归档定位）
Read {
  file_path: $ARCHIVE_PATH + "index.md"
}
// 实际读取：tai-enjoy-admin/.xmszm/index.md
```

### 示例 2：搜索限定范围
```javascript
// Step 2: 搜（兜底补充）
Grep {
  pattern: "function login",
  path: $PROJECT_ROOT
}
// 实际搜索路径：tai-enjoy-admin/
```

### 示例 3：更新 changelog
```javascript
// Step 5: 记（归档）
Edit {
  file_path: $ARCHIVE_PATH + "changelog/" + $CURRENT_MONTH + ".md",
  ...
}
// 实际文件：tai-enjoy-admin/.xmszm/changelog/2026-01.md
```

### 示例 4：更新根索引
```javascript
// Step 5: 记（归档） - 多项目环境
Edit {
  file_path: ".xmszm/projects.md",
  old_string: "## " + $PROJECT_NAME + "\n- **最后变更**: ...",
  new_string: "## " + $PROJECT_NAME + "\n- **最后变更**: " + $CURRENT_DATE + "\n..."
}
```

---

## 注意事项

1. **路径规范**：
   - 所有相对路径相对于**当前工作目录**
   - 多项目环境的 `$PROJECT_ROOT` 必须包含末尾斜杠
   - 单项目环境使用 `.` 而非 `./`

2. **变量生命周期**：
   - 变量在每次调用 skill 时重新计算
   - 不跨会话保存

3. **错误处理**：
   - 若变量未设置就使用，立即报错并中止流程
   - 向用户说明缺失的变量及原因
