# 项目识别规则

> 本文件在 Step 0 执行时按需加载

## 📋 目录

- [项目识别逻辑](#项目识别逻辑)
  - 一级子目录遍历
  - 项目标识文件检测
  - 环境判断
- [任务定位策略](#任务定位策略)
  - 路径提取
  - 关键词匹配
  - 交互式选择
- [变量生成](#变量生成)

---

## 项目识别逻辑

### 1. 一级子目录遍历

**遍历范围**：当前工作目录下的**一级子目录**

**排除目录**：
- `node_modules/`
- `.git/`
- `dist/`
- `build/`
- `.xmszm/`
- `target/`
- `.vscode/`
- `.idea/`
- `__pycache__/`

### 2. 项目标识文件检测

检测子目录是否包含以下**任一**项目标识文件：

**前端项目**：
- `package.json`
- `vite.config.js` / `vite.config.ts`
- `vue.config.js`
- `next.config.js`
- `nuxt.config.js`
- `angular.json`

**后端项目**：
- `pom.xml`（Maven/Java）
- `build.gradle` / `build.gradle.kts`（Gradle）
- `go.mod`（Go）
- `requirements.txt` / `pyproject.toml`（Python）
- `Cargo.toml`（Rust）
- `composer.json`（PHP）

**其他**：
- `.csproj`（C#）
- `Gemfile`（Ruby）

### 3. 环境判断

**多项目环境条件**（满足任一即可）：
1. 识别到 ≥ 2 个包含项目标识文件的子目录
2. 当前目录本身包含项目标识文件，且至少 1 个子目录也包含项目标识文件

**单项目环境**：
- 仅当前目录包含项目标识文件，子目录均不包含
- 或无任何项目标识文件（视为普通文件夹）

---

## 项目定位策略

### 策略 1：路径提取（优先级最高）

**触发条件**：用户消息中包含明确的文件路径

**示例**：
- 用户输入："修改 `project-admin/src/views/Login.vue`"
- 提取项目前缀：`project-admin/`

**实现**：
- 使用正则匹配：`([a-zA-Z0-9_-]+)/.*\.(js|ts|vue|java|py|go|rs|php|cs|rb)`
- 验证提取的目录是否存在且包含项目标识文件

### 策略 2：关键词匹配

**触发条件**：用户仅描述功能，未提供路径

**步骤**：
1. 读取根目录 `.xmszm/projects.md`
2. 从项目描述和技术栈中提取关键词
3. 匹配用户输入中的关键词

**示例**：
```markdown
## project-admin
- **描述**: 管理后台
- **技术栈**: Vue 3, Element Plus
```
用户输入："修改管理后台的登录页" → 匹配到"管理后台" → `project-admin/`

### 策略 3：交互式选择（兜底）

**触发条件**：策略 1 和 2 均无法定位

**执行**：
- 列出所有检测到的项目
- 向用户询问：
  ```
  无法自动定位项目，请选择目标项目：
  1) project-admin - 管理后台
  2) project-api - 后端API
  3) project-weapp - 微信小程序
  ```

---

## 变量输出

定位成功后，设置以下变量：

**$PROJECT_ROOT**：项目根目录的**相对路径**
- 多项目环境示例：`project-admin/`
- 单项目环境：`.`

**$PROJECT_NAME**：项目名称（取目录名）
- 示例：`$PROJECT_ROOT = project-admin/` → `$PROJECT_NAME = project-admin`

**$ARCHIVE_PATH**：归档路径
- 多项目环境：`$PROJECT_ROOT/.xmszm/`（如 `project-admin/.xmszm/`）
- 单项目环境：`.xmszm/`
