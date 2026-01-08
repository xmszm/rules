---
name: xmszm-code-workflow
description: 处理代码任务时自动执行项目定位、归档查询、代码搜索、实施和归档的标准流程。支持多项目环境，自动分项目归档。当需要修改、排查、开发、修复或查看代码时使用。同时提供快速日志记录功能。
---

# xmszm 项目说明书模式

> **简称**：xmszm | **全称**：xmszm-code-workflow

## 📚 规则加载机制

本 skill 采用**渐进式加载**策略，减少 token 消耗：
- **入口**：SKILL.md（当前文件，只做任务路由判断）
- **详细规则**：`rules/` 目录（按需读取）
- **工作流程**：`guides/CODE-WORKFLOW.md`（代码开发详细流程）
- **日志管理**：`guides/LOG-SKILL.md`（日志操作详细流程）
- **模板**：`templates/` 目录（初始化时读取）

**执行策略**：根据任务类型智能路由到对应的详细文档。

---

## 🔀 任务类型智能路由

**第一步：识别任务类型，选择执行路径**

### 判断矩阵

| 任务特征 | 任务类型 | 执行文档 | 执行方式 |
|---------|---------|---------|---------|
| 包含"记录/log/记一下" | 日志操作 | `guides/LOG-SKILL.md` | 独立执行，跳过开发流程 |
| 包含"查看日志/历史/changelog" | 日志查询 | `guides/LOG-SKILL.md` | 独立执行，跳过开发流程 |
| 包含"统计/分析/报告" | 日志统计 | `guides/LOG-SKILL.md` | 独立执行，跳过开发流程 |
| 需要修改/开发/修复代码 | 代码开发 | `guides/CODE-WORKFLOW.md` | 执行完整工作流 |
| 既修改代码又需记录 | 代码开发 | `guides/CODE-WORKFLOW.md` | 执行完整工作流，Step 5自动记录 |

### 路由示例

```
用户输入: "记录一下刚改的登录页"
  → 识别关键词: "记录"
  → 任务类型: 日志操作
  → 执行: 读取 guides/LOG-SKILL.md

用户输入: "修改登录页的样式"
  → 识别关键词: "修改"
  → 任务类型: 代码开发
  → 执行: 读取 guides/CODE-WORKFLOW.md

用户输入: "修复登录bug并记录一下"
  → 识别关键词: "修复"（代码修改优先于记录）
  → 任务类型: 代码开发
  → 执行: 读取 guides/CODE-WORKFLOW.md（Step 5会处理记录）
```

### 路由规则详解

#### 1️⃣ 日志操作类任务 → `guides/LOG-SKILL.md`

**特征**：
- 用户明确说"记录/log"某个已完成的变更
- 仅查看历史记录不修改代码
- 需要生成变更统计报告

**处理**：
- 立即读取 `guides/LOG-SKILL.md`
- 按照日志管理流程执行
- 不涉及代码修改，不走开发流程

---

#### 2️⃣ 代码开发类任务 → `guides/CODE-WORKFLOW.md`

**特征**：
- 需要查看、修改、开发、修复代码
- 涉及功能实现或bug排查
- 需要搜索代码或读取项目归档

**处理**：
- 读取 `guides/CODE-WORKFLOW.md`
- 执行完整的工作流：定→查→搜→问→做→记
- Step 5会自动处理变更记录

---

## 快速参考

### 核心文件结构

```
xmszm/
├── SKILL.md                    # 入口文件（任务路由）
├── guides/                     # 工作流指南
│   ├── CODE-WORKFLOW.md        # 代码开发详细工作流
│   └── LOG-SKILL.md            # 日志管理详细工作流
├── rules/                      # 详细规则（按需读取）
│   ├── project-detection.md
│   ├── task-type-mapping.md
│   ├── archive-format.md
│   ├── log-operations.md
│   ├── search-strategy.md
│   ├── variables.md
│   └── edge-cases.md
├── scripts/                    # 辅助脚本
│   ├── log-change.sh
│   └── migrate-changelog.sh
└── templates/                  # 模板文件
    └── *.md.template
```

### 文件速查表

| 文件 | 用途 | 触发时机 |
|------|------|---------|
| `SKILL.md` | **入口**，任务路由判断 | 始终先读 |
| `guides/CODE-WORKFLOW.md` | 代码开发工作流详解 | 代码开发任务 |
| `guides/LOG-SKILL.md` | 日志操作工作流详解 | 日志操作任务 |
| `rules/project-detection.md` | 项目定位规则 | CODE-WORKFLOW Step 0 |
| `rules/task-type-mapping.md` | 任务类型映射 | CODE-WORKFLOW Step 1 |
| `rules/archive-format.md` | 归档更新格式 | CODE-WORKFLOW Step 5 |
| `rules/log-operations.md` | 日志操作规则 | LOG-SKILL 详细步骤 |
| `rules/search-strategy.md` | 代码搜索策略 | CODE-WORKFLOW Step 2 |
| `rules/edge-cases.md` | 特殊场景处理 | 遇到异常时 |

### 归档结构速览

**新格式（推荐）** - 按日期分割：
```
changelog/
├── YYYY-MM.md              # 月份索引
└── YYYY-MM/                # 月份文件夹
    ├── YYYY-MM-01.md       # 每日日志
    └── ...
```

**旧格式（兼容）** - 月度聚合：
```
changelog/
└── YYYY-MM.md              # 整月日志
```

---

## 📋 执行流程速览

### 代码开发流程（详见 `guides/CODE-WORKFLOW.md`）

```
Step 0: 定（项目定位）
  ↓
Step 1: 查（归档定位）
  ↓
Step 2: 搜（兜底补充）
  ↓
Step 3: 问（确认细节）
  ↓
Step 4: 做（实施）
  ↓
Step 5: 记（归档）
```

### 日志操作流程（详见 `guides/LOG-SKILL.md`）

```
Step 1: 识别操作类型
  ├─ 快速记录 → Step 2A
  ├─ 历史查询 → Step 2B
  └─ 统计分析 → Step 2C
```

---

## ⚠️ 重要约定

1. **渐进式披露**：SKILL.md 只做路由判断，详细内容在对应的 guides/* 文件中
2. **按需加载**：只读取当前任务相关的文件，避免过度加载
3. **路径一致**：所有文件引用使用相对路径，便于移动
4. **链接优先**：遇到"详见 xxx.md"的提示，立即读取对应文件获取完整信息

---

## 使用示例

### 示例 1：快速记录变更

```
用户: "记录一下刚修改的登录页"
↓
SKILL.md: 识别"记录"关键词 → 日志操作
↓
读取 guides/LOG-SKILL.md
↓
执行日志记录流程，完成
```

### 示例 2：修改代码

```
用户: "修改登录页的样式"
↓
SKILL.md: 识别"修改"关键词 → 代码开发
↓
读取 guides/CODE-WORKFLOW.md
↓
执行完整工作流：定→查→搜→问→做→记
↓
自动在Step 5中记录变更
```

---

## 需要帮助？

- **路由不确定？** → 检查本文件的 [任务类型智能路由](#-任务类型智能路由) 部分
- **工作流细节？** → 读取 `guides/CODE-WORKFLOW.md` 或 `guides/LOG-SKILL.md`
- **特定规则？** → 查看 `rules/` 目录下的对应文件
- **遇到异常？** → 读取 `rules/edge-cases.md`
