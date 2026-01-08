---
name: xmszm-log
description: 快速记录代码变更日志到changelog,支持查询历史记录。无需走完整workflow,适合小改动的快速记录。
---

# xmszm 日志管理工具

> **简称**: log | **全称**: xmszm-log

## 📚 规则加载机制

本文件提供日志管理的核心流程：
- 核心流程在 LOG-SKILL.md（当前文件）
- 详细规则在 `../rules/log-operations.md`（按需读取）
- 模板文件在 `../templates/changelog-*.md.template`
- 辅助脚本在 `../scripts/log-change.sh` 和 `../scripts/migrate-changelog.sh`

**执行时，根据操作类型主动读取对应规则章节。**

---

## 功能概述

本 skill 提供独立的日志管理能力:
- **快速记录**: 无需完整 workflow,直接记录变更
- **历史查询**: 按日期、文件、类型查询变更记录
- **日志统计**: 生成变更统计报告
- **智能归档**: 自动按日期分割,支持新旧两种格式

---

## 执行流程

### Step 1: 操作类型判断

> 📖 **详细规则**: 读取 `../rules/log-operations.md` → [操作类型判断]

根据用户输入的关键词，确定操作类型：

| 关键词 | 操作类型 | 跳转章节 |
|-------|---------|---------|
| 记录/log/记一下 | 快速记录 | [Step 2A](#step-2a-快速记录) |
| 查看/历史/changelog | 历史查询 | [Step 2B](#step-2b-历史查询) |
| 统计/分析/报告 | 统计分析 | [Step 2C](#step-2c-统计分析) |

---

### Step 2A: 快速记录

> 📖 **详细规则**: 读取 `../rules/log-operations.md` → [快速记录操作]

**执行概要**：
1. 项目定位（定位 `$PROJECT_ROOT` 和 `$ARCHIVE_PATH`）
2. 变更信息收集：
   - 自动检测：`git diff --name-only HEAD`
   - 手动输入：解析用户描述
3. 格式检测：
   - 检查 `changelog/YYYY-MM/` 目录 → 新格式
   - 检查 `changelog/YYYY-MM.md` 文件 → 旧格式
   - 都不存在 → 使用新格式
4. 写入日志：
   - 新格式：`changelog/YYYY-MM/YYYY-MM-DD.md`（追加到末尾）
   - 旧格式：`changelog/YYYY-MM.md`（插入到开头）
5. 可选：更新功能归档（`pages/` 或 `guides/`）
6. 多项目环境：更新根索引 `.xmszm/projects.md`

**输出示例**：
```
✓ 已记录到: project-a/.xmszm/changelog/2026-01/2026-01-07.md
✓ 已更新功能归档: pages/login.md
✓ 已更新根索引
```

---

### Step 2B: 历史查询

> 📖 **详细规则**: 读取 `../rules/log-operations.md` → [历史查询操作]

**执行概要**：
1. 解析查询条件：
   - 日期范围（今天/本周/本月/自定义）
   - 文件路径
   - 变更类型
   - 关键词
2. 根据格式定位文件：
   - 新格式：列出日期范围内的文件
   - 旧格式：读取月份文件并过滤
3. 提取匹配记录
4. 格式化输出

**输出示例**：
```markdown
## 查询结果 (共 3 条记录)

### 2026-01-07 14:30
- **任务**: 修复登录页样式问题
- **变更文件**: `src/views/Login.vue:15-30`
- **类型**: 修复

### 2026-01-06 10:20
- **任务**: 优化登录API错误处理
- **变更文件**: `src/api/auth.js:45-60`
- **类型**: 优化

---

**筛选条件**:
- 日期范围: 2026-01-01 ~ 2026-01-07
- 文件: src/views/Login.vue
```

---

### Step 2C: 统计分析

> 📖 **详细规则**: 读取 `../rules/log-operations.md` → [统计分析操作]

**执行概要**：
1. 确定统计时间范围
2. 遍历changelog文件，提取数据
3. 生成统计报告：
   - 变更类型分布
   - 文件修改热度 Top 10
   - 每日变更趋势
   - 高频变更预警

**输出示例**：
```markdown
## 本月变更统计报告

### 变更类型分布
| 类型 | 数量 | 占比 |
|-----|------|------|
| 修改 | 45   | 60%  |
| 新增 | 12   | 16%  |
| 修复 | 8    | 11%  |

### 文件修改热度 Top 5
1. src/views/Login.vue - 15次
2. src/api/request.js - 12次
3. src/styles/common.scss - 8次

### ⚠️ 高频变更预警
- `src/views/Login.vue` - 8次修改（建议重构）
```

---

## 使用场景

### 场景 1: 快速记录小改动
```
用户: "记录一下,刚修改了登录页的样式"
→ 直接追加到当天的changelog,无需走完整流程
```

### 场景 2: 查看历史记录
```
用户: "看一下登录页最近有哪些改动"
→ 搜索相关文件的变更记录并展示
```

### 场景 3: 生成变更报告
```
用户: "统计一下这个月的变更情况"
→ 生成本月的变更统计(类型分布、文件热度等)
```

---

## 核心命令

### 1. 快速记录 (log)

**触发词**: "记录"、"log"、"记一下"

**执行流程**:
1. 检测项目环境(读取 `rules/project-detection.md`)
2. 获取变更信息:
   - 自动检测: 运行 `git diff --name-only` 获取变更文件
   - 手动指定: 用户直接说明文件和改动
3. 记录到changelog:
   - 新格式: `changelog/YYYY-MM/YYYY-MM-DD.md`
   - 旧格式: `changelog/YYYY-MM.md`
4. 可选: 更新功能归档文件

**输入参数**:
- `--message`: 变更描述(必需)
- `--files`: 变更文件列表(可选,自动检测 git diff)
- `--type`: 变更类型(可选,默认"修改")
- `--skip-archive`: 跳过功能归档更新

**示例**:
```bash
# 自动检测变更文件
log --message "修复登录页样式问题"

# 手动指定文件
log --message "优化API错误处理" --files "src/api/request.js:45-60" --type "优化"

# 仅记录不更新归档
log --message "临时调试代码" --skip-archive
```

---

### 2. 查询历史 (log-query)

**触发词**: "查看日志"、"历史记录"、"changelog"

**查询维度**:
- **按日期**: 查看指定日期或日期范围的变更
- **按文件**: 查看特定文件的变更历史
- **按类型**: 筛选特定类型的变更(修复/新增/优化等)
- **按关键词**: 搜索变更描述中的关键词

**示例**:
```bash
# 查看今天的变更
log-query --date today

# 查看本周的变更
log-query --date this-week

# 查看特定文件的历史
log-query --file "src/views/Login.vue"

# 查看所有修复类型的变更
log-query --type "修复"

# 关键词搜索
log-query --keyword "登录"
```

---

### 3. 统计分析 (log-stats)

**触发词**: "统计"、"分析"、"报告"

**统计内容**:
- 变更类型分布(饼图数据)
- 文件修改热度排行
- 每日变更趋势
- 高频变更文件预警

**示例**:
```bash
# 本月统计
log-stats --period this-month

# 自定义时间范围
log-stats --from 2026-01-01 --to 2026-01-31

# 按项目统计(多项目环境)
log-stats --project project-a
```

---

## 日志格式支持

### 新格式(推荐) - 按日期分割

```
changelog/
├── 2026-01.md                 # 月份索引
└── 2026-01/                   # 月份文件夹
    ├── 2026-01-01.md          # 每日日志
    ├── 2026-01-02.md
    └── ...
```

**优势**:
- 文件更小,加载更快
- 便于按日期查询
- 避免单文件过大

### 旧格式(兼容) - 月度聚合

```
changelog/
├── 2026-01.md                 # 整月日志在一个文件
└── 2025-12.md
```

**自动检测**: 优先使用新格式,若不存在则使用旧格式

---

## 执行逻辑

### Step 1: 项目定位

> 📖 读取 `rules/project-detection.md`

1. 检测多项目环境
2. 定位 `$PROJECT_ROOT` 和 `$ARCHIVE_PATH`
3. 检查归档目录是否存在

---

### Step 2: 变更信息收集

**自动模式**(默认):
```bash
git diff --name-only HEAD
git diff --stat HEAD
```

**手动模式**:
- 解析用户输入的文件路径和行号
- 识别变更类型关键词

---

### Step 3: 日志写入

#### 3.1 确定日志文件路径

**新格式路径**:
```
$ARCHIVE_PATH/changelog/YYYY-MM/YYYY-MM-DD.md
```

**旧格式路径**:
```
$ARCHIVE_PATH/changelog/YYYY-MM.md
```

#### 3.2 格式化日志条目

```markdown
### YYYY-MM-DD HH:mm
- **任务**: [变更描述]
- **变更文件**:
  - `src/views/Login.vue:15-30`
  - `src/styles/login.scss:8-25`
- **类型**: [修改/新增/修复/优化/重构/删除]
- **说明**: [可选的补充说明]
```

#### 3.3 写入策略

**新格式**:
1. 检查 `changelog/YYYY-MM/` 目录是否存在,不存在则创建
2. 检查 `YYYY-MM-DD.md` 文件是否存在:
   - 不存在: 创建新文件,使用日志模板
   - 已存在: 追加到文件末尾
3. 更新月份索引 `changelog/YYYY-MM.md`

**旧格式**:
1. 检查 `changelog/YYYY-MM.md` 是否存在:
   - 不存在: 创建新文件
   - 已存在: 追加到文件开头(最新在上)
2. 更新 `changelog.md` 索引

---

### Step 4: 可选功能归档更新

当 `--skip-archive` 未设置时:

1. 根据变更文件类型确定归档文件(参考 `rules/task-type-mapping.md`)
2. 追加到功能归档的 `## 最近变更` 章节

---

### Step 5: 多项目环境索引更新

若为多项目环境,更新 `.xmszm/projects.md`:
- `最后变更`: 当前日期
- `最近任务`: 变更描述(截取前50字符)

---

## 历史查询实现

### 查询算法

**新格式查询**:
1. 根据日期范围确定需要读取的文件列表
2. 并行读取多个日期文件
3. 过滤匹配条件的记录

**旧格式查询**:
1. 读取对应月份的文件
2. 正则匹配日期范围
3. 过滤匹配条件的记录

### 输出格式

```markdown
## 查询结果 (共 N 条记录)

### 2026-01-07 14:30
- **任务**: 修复登录页样式问题
- **变更文件**: `src/views/Login.vue:15-30`
- **类型**: 修复

### 2026-01-06 10:20
- **任务**: 优化API错误处理
- **变更文件**: `src/api/request.js:45-60`
- **类型**: 优化

---

**筛选条件**:
- 日期范围: 2026-01-01 ~ 2026-01-07
- 文件: src/views/Login.vue
```

---

## 统计分析实现

### 数据采集

从 changelog 中提取:
- 变更时间戳
- 变更类型
- 变更文件
- 变更描述

### 统计指标

**1. 类型分布**
```json
{
  "修改": 45,
  "新增": 12,
  "修复": 8,
  "优化": 5,
  "重构": 3,
  "删除": 2
}
```

**2. 文件热度(Top 10)**
```markdown
1. src/views/Login.vue - 15次变更
2. src/api/request.js - 12次变更
3. src/styles/common.scss - 8次变更
...
```

**3. 每日趋势**
```markdown
| 日期       | 变更次数 |
|-----------|---------|
| 2026-01-07 | 8       |
| 2026-01-06 | 5       |
| 2026-01-05 | 12      |
```

---

## 辅助脚本

> 📖 脚本位置: `scripts/log-change.sh`

### 功能
- Git hooks 集成(可选)
- 命令行快速记录
- 批量导入历史记录

### 使用方式
```bash
# 快速记录(交互式)
./scripts/log-change.sh

# 一键记录
./scripts/log-change.sh -m "修复bug" -f "src/main.js:45"

# 从 git log 导入
./scripts/log-change.sh --import --since="1 week ago"
```

---

## 与主 workflow 的关系

### 协同工作
- **主 workflow(xmszm)**: 完整的定→查→搜→问→做→记流程
- **log skill**: 独立的快速记录工具

### 使用建议
- **大改动**: 使用主 workflow(包含归档查询、代码搜索等)
- **小改动**: 使用 log skill 快速记录
- **查询/统计**: 使用 log skill 的查询功能

---

## 快速参考

### 命令速查

| 命令 | 描述 | 示例 |
|------|------|------|
| `log` | 快速记录变更 | `log -m "修复bug"` |
| `log-query` | 查询历史记录 | `log-query --date today` |
| `log-stats` | 统计分析 | `log-stats --period this-month` |

### 变更类型

| 类型 | 使用场景 |
|------|---------|
| 新增 | 全新功能或文件 |
| 修改 | 改进现有功能 |
| 修复 | 修复 Bug |
| 重构 | 代码结构调整,功能不变 |
| 删除 | 移除功能或文件 |
| 优化 | 性能优化、代码简化 |

### 文件路径

| 格式 | 含义 |
|------|------|
| `file.js:45` | 单行修改 |
| `file.js:45-60` | 连续多行 |
| `file.js:全文` | 全文重写 |
| `file.js:新增` | 新增文件 |
| `file.js:已删除` | 删除文件 |
| `file.js:20-25,45-50` | 多处不连续修改 |

---

## 边界情况处理

### 1. 归档目录不存在
**处理**: 提示用户是否初始化归档结构,或仅记录到临时文件

### 2. Git 未安装或非 Git 项目
**处理**: 禁用自动检测,要求手动指定变更文件

### 3. 日志文件冲突(多人协作)
**处理**: 追加时使用文件锁,或采用 append-only 模式

### 4. 日期跨时区问题
**处理**: 统一使用本地时区,记录时保留时区信息

### 5. 历史日志迁移
**处理**: 提供迁移工具 `scripts/migrate-changelog.sh`,从旧格式转换到新格式

---

## 配置选项

可在 `$ARCHIVE_PATH/.xmszm-config.json` 中配置:

```json
{
  "changelog": {
    "format": "daily",          // "daily" 新格式 | "monthly" 旧格式
    "autoDetectGit": true,      // 自动检测 git diff
    "updateArchive": true,      // 默认更新功能归档
    "timezone": "Asia/Shanghai" // 时区
  },
  "log": {
    "maxFileSize": "1MB",       // 单个日志文件最大大小
    "retention": "1 year"       // 日志保留时长
  }
}
```

---

## 示例场景

### 完整示例: 快速记录一次样式修改

**用户输入**:
```
记录一下,刚把登录页改成深色主题了
```

**执行过程**:
1. 检测项目: 定位到 `project-a`
2. 自动检测变更:
   ```bash
   git diff --name-only
   → src/views/Login.vue
   → src/styles/login.scss
   ```
3. 写入日志到 `project-a/.xmszm/changelog/2026-01/2026-01-07.md`:
   ```markdown
   ### 2026-01-07 14:30
   - **任务**: 把登录页改成深色主题
   - **变更文件**:
     - `src/views/Login.vue:15-30`
     - `src/styles/login.scss:8-25`
   - **类型**: 修改
   ```
4. 更新功能归档 `pages/login.md`:
   ```markdown
   ## 最近变更
   - 2026-01-07: 改成深色主题(涉及文件: `src/views/Login.vue:15-30`, `src/styles/login.scss:8-25`)
   ```
5. 输出确认: "已记录到 2026-01-07 的日志"

---

## 注意事项

1. **权限检查**: 确保对 `$ARCHIVE_PATH` 有写权限
2. **并发安全**: 多人协作时避免同时写入同一文件
3. **文件大小**: 建议使用新格式,避免单文件过大
4. **备份策略**: 重要日志建议纳入版本控制
5. **敏感信息**: 不要在日志中记录密码、密钥等敏感信息
