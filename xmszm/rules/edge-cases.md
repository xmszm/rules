# 边界情况处理

> 本文件在遇到特殊场景时按需加载

---

## 1. 任务涉及多个项目

### 场景描述
用户任务同时涉及多个子项目的修改。

**示例**：
- "统一前后端接口返回格式"（涉及 tai-enjoy-admin 和 tai-enjoy-api）
- "修改支付流程"（涉及 tai-enjoy-weapp 和 tai-enjoy-api）

### 处理策略

#### Step 0：确认主要项目
向用户询问：
```
检测到任务可能涉及多个项目：
- tai-enjoy-admin（前端）
- tai-enjoy-api（后端）

请选择主要修改项目（或输入"全部"）：
1) tai-enjoy-admin
2) tai-enjoy-api
3) 全部项目
```

#### Step 5：分项目记录
若选择"全部项目"：
1. 在每个涉及项目的 changelog 中分别记录
2. 在说明中注明关联项目：
   ```markdown
   ### 2026-01-04 15:00
   - **任务**：统一接口返回格式
   - **变更文件**：
     - `src/api/response.ts:10-30`
   - **类型**：修改
   - **说明**：同时修改了 tai-enjoy-api 项目的 ResponseUtil.java
   ```

---

## 2. 无法自动定位项目

### 场景描述
- 用户描述模糊，无法匹配到具体项目
- `projects.md` 中的项目描述不足

**示例**：
- "优化性能"（所有项目都可能需要）
- "修复Bug"（未指明具体功能）

### 处理策略

#### Step 0：列出所有项目供选择
```
无法自动定位项目，请选择：
1) tai-enjoy-admin - 管理后台（Vue 3）
2) tai-enjoy-api - 后端API（Spring Boot）
3) tai-enjoy-weapp - 微信小程序（uni-app）
4) tai-enjoy-stockholder - 股东端（Vue 3）
```

#### 优化建议
向用户建议完善 `projects.md` 的描述字段，添加更多关键词。

---

## 3. 嵌套项目（不支持）

### 场景描述
项目目录嵌套，如：
```
tai-enjoy-admin/
├── admin-web/      （子项目）
└── admin-mobile/   （子项目）
```

### 处理策略

#### 当前策略
仅识别**一级子目录**作为项目，嵌套项目视为父项目的一部分。

**示例**：
- 识别：`tai-enjoy-admin/`
- 不识别：`tai-enjoy-admin/admin-web/`

#### 归档方式
在 `tai-enjoy-admin/.xmszm/` 中区分子模块：
```
tai-enjoy-admin/.xmszm/
└── guides/
    ├── admin-web/
    │   ├── api.md
    │   └── components.md
    └── admin-mobile/
        └── api.md
```

#### 向用户说明
```
检测到 tai-enjoy-admin/ 下有嵌套项目：
- admin-web
- admin-mobile

当前将它们视为 tai-enjoy-admin 的子模块。
归档将在 tai-enjoy-admin/.xmszm/ 下分模块记录。
```

---

## 4. 项目标识文件缺失

### 场景描述
目录看起来像项目，但没有标准的项目标识文件。

**示例**：
```
custom-tools/
├── src/
└── scripts/
（无 package.json、pom.xml 等）
```

### 处理策略

#### Step 0：向用户确认
```
检测到目录 custom-tools/ 可能是项目，但缺少项目标识文件。

是否将其视为项目？(Y/n)
```

#### 若用户确认
1. 将其纳入多项目环境
2. 技术栈标记为"待补充"
3. 提示用户手动完善 `projects.md`

---

## 5. .gitignore 冲突

### 场景描述
- `.gitignore` 中已存在 `.xmszm/` 但规则不同
- `.xmszm/` 未被忽略导致被提交到 Git

### 处理策略

#### 初始化时检查
读取 `.gitignore`，检测是否包含以下任一规则：
- `.xmszm/`
- `.xmszm`
- `**/.xmszm/`

#### 若不存在
自动追加：
```bash
echo "" >> .gitignore
echo "# xmszm 归档目录" >> .gitignore
echo ".xmszm/" >> .gitignore
```

#### 若已存在但规则不同
向用户提示：
```
检测到 .gitignore 中已有 .xmszm 相关规则：
  .xmszm

建议统一为：.xmszm/
是否自动修正？(Y/n)
```

---

## 6. 归档目录已存在但不完整

### 场景描述
`.xmszm/` 已存在，但缺少部分文件或目录。

**示例**：
```
.xmszm/
├── index.md
└── changelog.md
（缺少 guides/、pages/ 等）
```

### 处理策略

#### Step 0：完整性检查
对比当前结构与标准结构，列出缺失项。

#### 向用户确认
```
检测到归档目录不完整，缺少：
- guides/api.md
- guides/components.md
- pages-index.md

是否补全？(Y/n)
```

#### 执行补全
仅创建缺失的文件/目录，不覆盖已有内容。

---

## 7. 归档文件损坏或格式错误

### 场景描述
- `index.md` 无法解析
- `changelog.md` 格式混乱
- YAML front matter 缺失

### 处理策略

#### Step 1：读取归档时
若解析失败，向用户报告：
```
警告：归档文件 index.md 格式错误，无法解析。

是否重新生成？(Y/n)
警告：这将覆盖现有内容！
```

#### 备份旧文件
```bash
mv $ARCHIVE_PATH/index.md $ARCHIVE_PATH/index.md.backup
```

#### 生成新文件
使用模板重新创建。

---

## 8. 跨操作系统路径差异

### 场景描述
- Windows：`E:\HundredsCompany\泰享受\`
- Linux/Mac：`/home/user/projects/`

### 处理策略

#### 归档中使用相对路径
**强制规则**：所有文件路径必须相对于项目根目录。

**正确**：
```markdown
- `src/views/Login.vue:15`
```

**错误**：
```markdown
- `E:\HundredsCompany\泰享受\tai-enjoy-admin\src\views\Login.vue:15`
```

#### 路径分隔符统一
统一使用 `/`（即使在 Windows 上）：
```markdown
src/views/Login.vue  ✅
src\views\Login.vue  ❌
```

---

## 9. 用户中断初始化

### 场景描述
初始化过程中用户取消操作，导致归档目录不完整。

### 处理策略

#### 检测中断
若创建过程中出错，删除部分创建的目录：
```bash
rm -rf $ARCHIVE_PATH
```

#### 向用户说明
```
初始化已取消，已清理部分创建的文件。
下次执行任务时可重新初始化。
```

---

## 10. 归档文件过大

### 场景描述
- `changelog/2026-01.md` 超过 1000 行
- `guides/api.md` 包含大量接口

### 处理策略

#### 触发条件
文件行数 > 1000 行时提示。

#### 向用户建议
```
检测到 changelog/2026-01.md 已超过 1000 行，建议：
1. 归档旧的变更记录
2. 拆分为多个文件（如按周）

是否自动归档超过 3 个月的记录？(Y/n)
```

#### 自动归档
将 3 个月前的 changelog 移动到 `changelog/archive/` 目录。

---

## 11. 多人协作冲突

### 场景描述
团队成员同时修改归档文件，导致 Git 冲突。

### 处理策略

#### 检测冲突标记
读取归档文件时，检测是否包含：
```
<<<<<<< HEAD
=======
>>>>>>> branch
```

#### 向用户报告
```
检测到归档文件存在 Git 冲突标记，请先解决冲突：
  tai-enjoy-admin/.xmszm/guides/api.md

解决后重新执行任务。
```

---

## 12. 权限问题

### 场景描述
无法创建归档目录或文件（权限不足）。

### 处理策略

#### 捕获错误
创建文件/目录时捕获权限错误。

#### 向用户报告
```
错误：无法创建归档目录，权限不足。

请检查：
1. 当前用户是否有写入权限
2. 目录是否被占用或锁定

建议使用 sudo 或管理员权限执行。
```

---

## 总结

遇到边界情况时的通用原则：
1. **优先向用户询问**：不确定时不要猜测
2. **提供明确选项**：避免开放式问题
3. **保护现有数据**：覆盖前先备份
4. **记录处理过程**：在 changelog 中注明特殊情况
5. **提供恢复方案**：出错时能回滚
