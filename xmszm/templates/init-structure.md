# 初始化目录结构

> 本文件在需要初始化归档目录时加载

---

## 检测触发条件

### 多项目环境
1. 根目录 `.xmszm/` 不存在 → 初始化根索引
2. 子项目 `$PROJECT_ROOT/.xmszm/` 不存在 → 初始化子项目归档

### 单项目环境
1. `.xmszm/` 不存在 → 初始化项目归档

---

## 初始化流程

### 1. 多项目环境 - 根索引初始化

**触发条件**：`.xmszm/` 不存在

**执行步骤**：

#### Step 1: 扫描项目
遍历当前目录下的一级子目录，收集项目信息：
- 项目名称（目录名）
- 技术栈（从 `package.json`、`pom.xml` 等文件中推断）

#### Step 2: 创建根索引目录
```bash
mkdir .xmszm
```

#### Step 3: 创建 projects.md
使用模板：`templates/projects.md.template`

**内容**：自动填充检测到的所有项目

#### Step 4: 追加到 .gitignore（如果存在）
```bash
echo ".xmszm/" >> .gitignore
```

**检查规则**：
- 若 `.gitignore` 不存在，创建新文件
- 若已存在 `.xmszm/` 条目，跳过

---

### 2. 多项目环境 - 子项目初始化

**触发条件**：`$PROJECT_ROOT/.xmszm/` 不存在

**用户确认**：
```
即将在 `tai-enjoy-admin/` 下创建归档目录，包含以下结构：
  - index.md（总纲）
  - pages-index.md（页面索引，仅前端项目）
  - guides/（功能归档）
  - changelog/（变更记录）

是否继续？(Y/n)
```

**执行步骤**：

#### Step 1: 检测项目类型
根据项目标识文件判断：
- 前端项目：存在 `package.json` 且包含 `vue`/`react`/`angular` 等依赖
- 后端项目：存在 `pom.xml`/`go.mod`/`requirements.txt` 等

#### Step 2: 创建目录结构

**前端项目**：
```
$PROJECT_ROOT/.xmszm/
├── index.md
├── pages-index.md
├── changelog.md
├── changelog/
├── pages/
└── guides/
    ├── api.md
    ├── components.md
    ├── store.md
    ├── styles.md
    └── utils.md
```

**后端项目**：
```
$PROJECT_ROOT/.xmszm/
├── index.md
├── changelog.md
├── changelog/
└── guides/
    ├── api.md
    ├── database.md
    ├── services.md
    └── utils.md
```

#### Step 3: 生成模板文件
- `index.md`：使用 `templates/index.md.template`
- `changelog.md`：使用 `templates/changelog.md.template`
- `pages-index.md`：使用 `templates/pages-index.md.template`（仅前端）
- `guides/*.md`：使用 `templates/guide.md.template`

#### Step 4: 追加到项目 .gitignore
```bash
echo ".xmszm/" >> $PROJECT_ROOT/.gitignore
```

---

### 3. 单项目环境初始化

**触发条件**：`.xmszm/` 不存在

**用户确认**：
```
检测到这是单项目环境，即将在当前目录创建归档目录。

项目根目录：E:\HundredsCompany\泰享受
项目名称：（自动识别或手动输入）

是否继续？(Y/n)
```

**执行步骤**：
同 "多项目环境 - 子项目初始化"，但 `$PROJECT_ROOT = .`

---

## 模板填充规则

### index.md 模板

**变量替换**：
- `$PROJECT_NAME`：项目名称
- `$CURRENT_DATE`：创建日期
- `$PROJECT_TYPE`：前端/后端/全栈
- `$TECH_STACK`：技术栈（自动识别或待补充）

**自动识别技术栈**：

**前端**：
- 检测 `package.json` 的 `dependencies`
- Vue 3 → 包含 `"vue": "^3.x"`
- React → 包含 `"react"`
- Element Plus → 包含 `"element-plus"`

**后端**：
- Java → 检测 `pom.xml`，提取 `<groupId>` 和 `<artifactId>`
- Go → 检测 `go.mod`，提取 `module`
- Python → 检测 `requirements.txt`，列出主要框架（Django/Flask/FastAPI）

### changelog.md 模板

**变量替换**：
- `$CURRENT_MONTH`：当前年月（YYYY-MM）

### pages-index.md 模板

**变量替换**：
- `$PROJECT_NAME`：项目名称

**初始内容**：空列表，等待首次记录

### guide.md 模板

**变量替换**：
- `$GUIDE_TYPE`：api/components/store/database/services 等
- `$GUIDE_TITLE`：API 文档/组件库/数据库文档 等

---

## 技术栈识别规则

### 识别优先级
1. 读取配置文件
2. 推断主要框架
3. 无法识别时标记为"待补充"

### 前端识别

**package.json**：
```json
{
  "dependencies": {
    "vue": "^3.4.0",
    "element-plus": "^2.5.0",
    "axios": "^1.6.0"
  }
}
```
→ 识别为：`Vue 3, Element Plus`

### 后端识别

**pom.xml**（Java）：
```xml
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-web</artifactId>
```
→ 识别为：`Spring Boot`

**go.mod**（Go）：
```
module github.com/user/project
require github.com/gin-gonic/gin v1.9.0
```
→ 识别为：`Go, Gin`

**requirements.txt**（Python）：
```
Django==4.2.0
djangorestframework==3.14.0
```
→ 识别为：`Django, DRF`

---

## 项目类型判断

### 前端项目
**条件**（满足任一）：
- 存在 `package.json` 且包含前端框架依赖（vue/react/angular）
- 存在 `vite.config.js`/`vue.config.js`/`next.config.js`

### 后端项目
**条件**（满足任一）：
- 存在 `pom.xml`
- 存在 `go.mod`
- 存在 `requirements.txt` 且包含后端框架
- 存在 `Cargo.toml`

### 全栈项目
**条件**：同时满足前端和后端条件

**归档策略**：
- 创建完整的前端 + 后端归档结构
- `guides/` 包含前后端所有类型

---

## 错误处理

### 场景 1：无法识别项目类型
**处理**：
1. 向用户询问：
   ```
   无法自动识别项目类型，请选择：
   1) 前端项目
   2) 后端项目
   3) 全栈项目
   4) 其他（通用）
   ```
2. 根据用户选择创建对应结构

### 场景 2：.gitignore 无写入权限
**处理**：
1. 跳过 .gitignore 追加
2. 向用户提示：
   ```
   警告：无法写入 .gitignore，请手动添加：
   .xmszm/
   ```

### 场景 3：目录已存在但内容不完整
**处理**：
1. 检测缺失的文件/目录
2. 向用户确认：
   ```
   检测到归档目录已存在但不完整，缺少：
   - pages-index.md
   - guides/components.md

   是否补全？(Y/n)
   ```
3. 仅创建缺失的部分

---

## 完整示例

### 场景：初始化 tai-enjoy-admin（前端项目）

**检测结果**：
- 项目名：`tai-enjoy-admin`
- 类型：前端
- 技术栈：Vue 3, Element Plus

**创建结构**：
```
tai-enjoy-admin/
├── .xmszm/
│   ├── index.md
│   ├── pages-index.md
│   ├── changelog.md
│   ├── changelog/
│   ├── pages/
│   └── guides/
│       ├── api.md
│       ├── components.md
│       ├── store.md
│       ├── styles.md
│       └── utils.md
└── .gitignore（追加 .xmszm/）
```

**index.md 内容**：
```markdown
# tai-enjoy-admin 归档总纲

> 创建时间：2026-01-04
> 项目类型：前端
> 技术栈：Vue 3, Element Plus

## 快速导航
- [页面索引](./pages-index.md)
- [API文档](./guides/api.md)
- [组件库](./guides/components.md)
- [状态管理](./guides/store.md)
- [样式规范](./guides/styles.md)
- [工具函数](./guides/utils.md)

## 变更记录
详见 [changelog](./changelog.md)
```

**更新根索引**（`.xmszm/projects.md`）：
```markdown
## tai-enjoy-admin
- **描述**: 管理后台
- **技术栈**: Vue 3, Element Plus
- **最后变更**: 2026-01-04
- **最近任务**: 初始化归档
- **归档位置**: `tai-enjoy-admin/.xmszm/`
```
