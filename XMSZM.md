
# 日常模式

## 1. 核心原则

### 规则优先级
用户项目规则 > .xmszm/rules.md > CLAUDE.md

### 工作节奏
查（读归档）→ 问（确认细节）→ 做（实施）→ 记（归档）

---

## 2. 归档目录 .xmszm

> 本地归档目录，需加入 `.gitignore`

### 目录结构

```
.xmszm/
├── index.md                # 总纲
├── pages-index.md          # 页面索引 L1
├── rules.md                # 项目规范（可选）
├── pages/                  # 页面详情 L2
│   └── [页面].md           # Block 拆分
├── guides/                 # 分类文档
│   ├── api.md              # 接口总览
│   ├── api/[模块].md       # 接口详情
│   ├── utils.md
│   ├── components.md
│   └── store.md
├── changelog.md            # 变更索引 L1
└── changelog/              # 变更详情 L2
    └── YYYY-MM.md          # 按月拆分
```

### 多项目结构

```
dir/
├── .xmszm/index.md         # 子项目总览
├── frontend/.xmszm/
├── backend/.xmszm/
└── api/.xmszm/
```
### 多项目结构职责划分

| 层级 | 内容 | 示例 |
|-----|------|------|
| dir/.xmszm/index.md | **仅**子项目路径+简介 | `tai-enjoy-api: 后端API` |
| 子项目/.xmszm/ | 该项目的完整归档 | pages/guides/changelog |

### 初始化判断

检测到多子项目时（存在多个独立项目目录）：
1. 父目录 `.xmszm/` 只建 index.md（子项目总览）
2. 实际归档在对应子项目的 `.xmszm/` 下

---

## 3. 渐进式读取

| 层级 | 读取内容 | 时机 |
|-----|---------|-----|
| L1 | index.md / pages-index.md | 首先 |
| L2 | pages/[页面].md / guides/[分类].md | 按需 |
| L3 | 源码 | 必要时 |

---

## 4. 页面 Block

### pages/[页面].md

```markdown
# 页面名
路径：pages/xxx | 接口：xxx | 设计稿：[链接]

| 别名 | 区域 | 组件 | 状态 |
|-----|------|-----|------|
| 会员卡片 | 中部 | swiper | ✅ |
```

- 使用**中文别名**，用户可直接引用

---

## 5. 变更归档

### 触发
代码变更完成后自动执行

### 更新规则

| 变更类型 | 更新目标 |
|---------|---------|
| 页面 | pages-index.md + pages/[页面].md |
| 接口 | guides/api.md + guides/api/[模块].md |
| 工具/组件/状态 | guides/ 对应文件 |
| 所有 | changelog/YYYY-MM.md |

### changelog 规则
- **AI 只写不读**（用户查阅用）
- AI 了解变更用 git log
- 索引：changelog.md 记录月份 + 变更数
- 详情：changelog/YYYY-MM.md 记录具体变更

```markdown
# changelog.md（索引）
| 月份 | 变更数 |
|-----|-------|
| 2025-12 | 15 |

# changelog/2025-12.md（详情）
[2025-12-30] 范围 | 内容 | @操作者
```

---

## 6. 初始化

检测 `.xmszm/` 不存在时：
1. 识别项目根目录
2. 向用户确认路径
3. 创建目录 + 空模板
4. 追加 .gitignore
5. 继续任务

---

## 7. 前后端协作

| 前端 | 后端 | 处理 |
|-----|-----|------|
| ❌ | ❌ | 初始化全部 |
| ✅ | ❌ | 初始化后端 |
| ❌ | ✅ | 初始化前端，读后端接口联调 |
| ✅ | ✅ | 正常流程 |

接口关联：
- 后端 guides/api/ = 定义源
- 前端 guides/api/ = 调用清单

