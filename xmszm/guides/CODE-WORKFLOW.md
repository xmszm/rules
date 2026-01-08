---
name: xmszm-code-workflow-detailed
description: 代码开发详细工作流，包含Step 0-5的完整执行规则。
---

# 代码开发详细工作流

> **本文档**：CODE-WORKFLOW.md | **触发**：SKILL.md 识别为代码开发类任务
> **参考**：当需要修改、排查、开发、修复代码时阅读本文档

## 📖 文档索引

- [强制流程](#强制流程)
- [Step 0：定（项目定位）](#step-0定项目定位)
- [Step 1：查（归档定位）](#step-1查归档定位)
- [Step 2：搜（兜底补充）](#step-2搜兜底补充)
- [Step 3：问（确认细节）](#step-3问确认细节)
- [Step 4：做（实施）](#step-4做实施)
- [Step 5：记（归档）](#step-5记归档)
- [违规处理](#违规处理)
- [初始化逻辑](#初始化逻辑)

---

## 强制流程

任何代码开发类任务都必须遵循以下流程：

```
定（项目定位）→ 查（归档定位）→ 搜（兜底补充）→ 问（确认细节）→ 做（实施）→ 记（归档）
```

### 任务进度清单

复制此清单并跟踪进度：
```
任务执行进度：
- [ ] Step 0：定（项目定位）
- [ ] Step 1：查（归档定位）
- [ ] Step 2：搜（兜底补充）- 如需要
- [ ] Step 3：问（确认细节）- 如需要
- [ ] Step 4：做（实施）
- [ ] Step 5：记（归档）
```

---

## Step 0：定（项目定位）⚠️ 优先执行

> 📖 **详细规则**：读取 `../rules/project-detection.md`
> 📖 **变量定义**：读取 `../rules/variables.md`

### 执行概要

1. 检测多项目环境（遍历一级子目录，查找项目标识文件）
2. 多项目环境：定位任务所属项目（路径提取/关键词匹配/交互选择）
3. 单项目环境：使用当前目录

### 输出变量

- `$PROJECT_ROOT`：项目根目录
- `$PROJECT_NAME`：项目名称
- `$ARCHIVE_PATH`：归档路径（通常为 `$PROJECT_ROOT/.xmszm`）

### 输出示例

「检测到多项目环境，本次任务定位到：`$PROJECT_NAME/`」

---

## Step 1：查（归档定位）⚠️ 不可跳过

> 📖 **任务类型判断**：读取 `../rules/task-type-mapping.md`

### 执行概要

1. 读取 `$ARCHIVE_PATH/index.md`（如存在）
2. 根据任务关键词判断类型（页面/组件/API/数据库等）
3. 定位到对应归档文件并读取

### 输出示例

- 找到：「根据归档（`$ARCHIVE_PATH`），该功能位于 `src/views/Login.vue:15`」
- 未找到：「归档中未找到相关记录，将进行搜索」

### 跳过条件

仅当用户明确说"不用看归档"

---

## Step 2：搜（兜底补充）

> 📖 **搜索策略**：读取 `../rules/search-strategy.md`

### 触发条件

- `$ARCHIVE_PATH` 不存在
- 归档中无相关记录
- 归档信息不完整

### 执行概要

- 优先使用 **codebase-retrieval**（语义搜索）
- 精确搜索使用 **Grep**（已知类名/函数名）
- 文件查找使用 **Glob**（文件名模式）
- **强制约束**：所有搜索必须限定 `path: $PROJECT_ROOT`

---

## Step 3：问（确认细节）

### 执行概要

向用户确认关键信息（如有不确定之处）

### 跳过条件

- 用户已提供完整上下文
- 纯查询类任务
- Step 1 已定位成功且任务明确

---

## Step 4：做（实施）

正常执行任务，使用 TodoWrite 跟踪进度。

---

## Step 5：记（归档）⚠️ 有变更必执行

> 📖 **归档格式**：读取 `../rules/archive-format.md`

### 执行概要

1. 更新功能归档文件（`pages/`、`guides/`）
2. 更新 `$ARCHIVE_PATH/changelog/`（新格式或旧格式）
3. 多项目环境：更新根索引 `.xmszm/projects.md`

### 跳过条件

- 未产生代码变更
- 用户明确说"不用记录"

---

## 违规处理

若需跳过 Step 1 或 Step 5，**必须**先向用户报告并等待确认：

> "我准备跳过[查/记]步骤，原因是 xxx。是否同意？"

---

## 初始化逻辑

> 📖 **初始化详情**：读取 `../templates/init-structure.md`

### 多项目环境

1. 根目录 `.xmszm/` 不存在 → 创建 `projects.md` 索引
2. 子项目 `$PROJECT_ROOT/.xmszm/` 不存在 → 创建完整归档结构

### 单项目环境

1. `.xmszm/` 不存在 → 创建完整归档结构

### 执行原则

**用户确认后执行**，并追加到对应 `.gitignore`

---

## 边界情况

> 📖 **特殊场景处理**：读取 `../rules/edge-cases.md`

包含以下场景的处理策略：
- 任务涉及多个项目
- 无法自动定位项目
- 嵌套项目（不支持）
- 项目标识文件缺失
- .gitignore 冲突
- 归档目录不完整
- 文件损坏/格式错误
- 跨操作系统路径差异
- 用户中断初始化
- 归档文件过大
- 多人协作冲突
- 权限问题

---

## 完整示例：修改登录页样式

### 用户输入
```
修改登录页的样式为深色主题
```

### Step 0：定（项目定位）
```
检测到单项目环境
PROJECT_ROOT = E:\HundredsCompany\rule\xmszm
ARCHIVE_PATH = E:\HundredsCompany\rule\xmszm/.xmszm
```

### Step 1：查（归档定位）
```
读取 .xmszm/index.md
根据关键词"登录页"定位到 pages/login.md
找到相关记录：
  - 主文件：src/views/Login.vue:15-30
  - 样式文件：src/styles/login.scss:8-25
```

### Step 2：搜（兜底补充）
```
归档中已有记录，无需搜索
```

### Step 3：问（确认细节）
```
用户输入已清晰，无需确认
```

### Step 4：做（实施）
```
修改 src/views/Login.vue（深色主题相关代码）
修改 src/styles/login.scss（样式调整）
运行测试，确认无误
```

### Step 5：记（归档）
```
更新功能归档：pages/login.md
追加到 ## 最近变更 章节

更新 changelog：
- 新格式：changelog/2026-01/2026-01-07.md
- 旧格式：changelog/2026-01.md

多项目环境：更新 .xmszm/projects.md

完成记录
```

---

## 快速检查表

| 检查项 | 说明 |
|-------|------|
| Step 0 完成？ | 确认项目根目录和归档路径已定位 |
| Step 1 完成？ | 确认已查看或确认不存在归档 |
| Step 2 完成？ | 确认已搜索或已跳过 |
| Step 3 完成？ | 确认已确认或已跳过 |
| Step 4 完成？ | 确认代码已修改并测试 |
| Step 5 完成？ | 确认已记录或用户明确不需要 |

---

## 相关文件导航

- **SKILL.md** - 任务路由入口（先看这个）
- **LOG-SKILL.md** - 日志操作工作流
- **rules/project-detection.md** - Step 0 详细规则
- **rules/task-type-mapping.md** - Step 1 详细规则
- **rules/search-strategy.md** - Step 2 详细规则
- **rules/archive-format.md** - Step 5 详细规则
- **rules/edge-cases.md** - 特殊场景处理
