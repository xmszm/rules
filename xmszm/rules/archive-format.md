# 归档更新格式规范

> 本文件在 Step 5 执行时按需加载（仅当有代码变更时）

## 📋 目录

- [更新流程](#更新流程)
- [功能归档更新](#1-功能归档更新)
  - 文件位置
  - 更新规则
  - 模板格式
- [Changelog 更新](#2-changelog-更新)
  - 月度文件结构
  - 记录格式
- [根索引更新](#3-根索引更新-多项目环境)

---

## 更新流程

1. 更新功能归档文件（pages/guides）
2. 更新 changelog
3. （多项目环境）更新根索引

---

## 1. 功能归档更新

### 文件位置
- 前端页面：`$ARCHIVE_PATH/pages/[页面名].md`
- 接口功能：`$ARCHIVE_PATH/guides/api/[模块名].md`
- 组件/工具：`$ARCHIVE_PATH/guides/[类型].md`

### 更新规则

#### 文件不存在时
创建新文件，使用以下模板：

```markdown
# [功能名称]

> 归档创建时间：YYYY-MM-DD

## 功能说明
[简要描述该功能的作用]

## 核心文件
- **主文件**：`path/to/main.js:行号范围`
- **样式文件**：`path/to/style.scss:行号`
- **依赖组件**：`path/to/component.vue`

## 关键实现
[重要逻辑的简要说明，如：认证流程、数据流向等]

## 最近变更
- YYYY-MM-DD：[变更描述]（涉及文件：`path/to/file.js:行号`）
```

#### 文件已存在时
追加到 `## 最近变更` 章节：

```markdown
## 最近变更
- YYYY-MM-DD：[变更描述]（涉及文件：`path/to/file.js:行号`）
- YYYY-MM-DD：修改登录表单校验逻辑（涉及文件：`src/views/Login.vue:45-60`）
```

**格式要求**：
- 日期格式：`YYYY-MM-DD`
- 描述：简洁明了，说明"做了什么"而非"怎么做"
- 文件信息：相对于项目根目录的路径 + 具体行号或行号范围

---

## 2. Changelog 更新

### 文件位置
`$ARCHIVE_PATH/changelog/YYYY-MM.md`

### 月度文件不存在时
创建新文件：

```markdown
# YYYY年MM月变更记录

---

### YYYY-MM-DD HH:mm
- **任务**：[任务描述]
- **变更文件**：
  - `src/views/Login.vue:45-60`
  - `src/styles/login.scss:12`
- **类型**：修改
- **说明**：[可选的补充说明]
```

### 月度文件已存在时
追加新记录到文件开头（最新记录在最上方）：

```markdown
### YYYY-MM-DD HH:mm
- **任务**：修改登录页样式为深色主题
- **变更文件**：
  - `src/views/Login.vue:15-30`
  - `src/styles/login.scss:8-25`
- **类型**：修改
- **说明**：响应用户深色模式偏好

---

### YYYY-MM-DD HH:mm
（之前的记录...）
```

### 变更类型

使用以下标准类型之一：
- **新增**：全新功能或文件
- **修改**：改进现有功能
- **修复**：修复 Bug
- **重构**：代码结构调整，功能不变
- **删除**：移除功能或文件
- **优化**：性能优化、代码简化

---

## 3. 根索引更新（多项目环境）

### 文件位置
`.xmszm/projects.md`（根目录，非项目内）

### 更新内容
修改对应项目的 `最后变更` 和 `最近任务` 字段：

**更新前**：
```markdown
## project-a
- **描述**: 管理后台
- **技术栈**: Vue 3, Element Plus
- **最后变更**: 2026-01-03
- **最近任务**: 修改用户列表样式
- **归档位置**: `project-a/.xmszm/`
```

**更新后**：
```markdown
## project-a
- **描述**: 管理后台
- **技术栈**: Vue 3, Element Plus
- **最后变更**: 2026-01-04
- **最近任务**: 修改登录页样式为深色主题
- **归档位置**: `project-a/.xmszm/`
```

### 更新规则
1. 仅更新 `最后变更` 和 `最近任务` 两个字段
2. `最近任务` 保持为单行描述，最多 50 字符
3. 不修改其他项目的信息

---

## 4. 更新 changelog 索引

### 文件位置
`$ARCHIVE_PATH/changelog.md`

### 更新时机
**仅当创建新的月度 changelog 文件时**

### 格式
追加新月份链接到列表开头：

**更新前**：
```markdown
# 变更记录索引

- [2025-12](./changelog/2025-12.md)
- [2025-11](./changelog/2025-11.md)
```

**更新后**：
```markdown
# 变更记录索引

- [2026-01](./changelog/2026-01.md)
- [2025-12](./changelog/2025-12.md)
- [2025-11](./changelog/2025-11.md)
```

---

## 特殊情况处理

### 情况 1：批量修改多个文件
changelog 中列出所有变更文件：

```markdown
### 2026-01-04 14:30
- **任务**：重构用户认证模块
- **变更文件**：
  - `src/api/auth.js:全文`
  - `src/store/user.js:20-45`
  - `src/utils/token.js:新增`
  - `src/views/Login.vue:60-80`
- **类型**：重构
```

### 情况 2：删除文件
标注文件已删除：

```markdown
- **变更文件**：
  - `src/old-component.vue:已删除`
```

### 情况 3：新增文件
标注为新增：

```markdown
- **变更文件**：
  - `src/components/NewButton.vue:新增`
```

### 情况 4：影响多个项目
在各自项目的 changelog 中记录，并在说明中注明：

```markdown
### 2026-01-04 15:00
- **任务**：统一接口返回格式
- **变更文件**：
  - `src/utils/response.js:10-30`
- **类型**：修改
- **说明**：同时修改了 project-b 项目的对应接口
```

---

## 行号规范

### 单行修改
`file.js:45`

### 连续多行
`file.js:45-60`

### 全文重写
`file.js:全文`

### 新增文件
`file.js:新增`

### 删除文件
`file.js:已删除`

### 多处不连续修改
`file.js:20-25,45-50,80`

---

## 完整示例

假设任务：修改登录页样式为深色主题

### 1. 更新功能归档
**文件**：`project-a/.xmszm/pages/login.md`

```markdown
## 最近变更
- 2026-01-04：修改为深色主题（涉及文件：`src/views/Login.vue:15-30`, `src/styles/login.scss:8-25`）
- 2026-01-02：添加记住密码功能（涉及文件：`src/views/Login.vue:45-60`）
```

### 2. 更新 changelog
**文件**：`project-a/.xmszm/changelog/2026-01.md`

```markdown
### 2026-01-04 14:20
- **任务**：修改登录页样式为深色主题
- **变更文件**：
  - `src/views/Login.vue:15-30`
  - `src/styles/login.scss:8-25`
- **类型**：修改
- **说明**：支持系统深色模式，优化夜间使用体验

---

### 2026-01-02 10:30
（之前的记录...）
```

### 3. 更新根索引
**文件**：`.xmszm/projects.md`

```markdown
## project-a
- **描述**: 管理后台
- **技术栈**: Vue 3, Element Plus
- **最后变更**: 2026-01-04
- **最近任务**: 修改登录页样式为深色主题
- **归档位置**: `project-a/.xmszm/`
```
