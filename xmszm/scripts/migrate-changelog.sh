#!/bin/bash

# xmszm Changelog 格式迁移工具
# 将旧格式(月度聚合)转换为新格式(按日期分割)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 显示帮助
show_help() {
    cat << EOF
用法: $0 <归档路径>

将旧格式的changelog(月度聚合)转换为新格式(按日期分割)

参数:
    归档路径    .xmszm 目录的路径 (例如: .xmszm 或 project-a/.xmszm)

选项:
    -h, --help  显示此帮助信息
    -b, --backup 迁移前备份原文件 (默认启用)
    -f, --force  强制覆盖已存在的新格式文件

示例:
    $0 .xmszm
    $0 project-a/.xmszm
    $0 .xmszm --force

EOF
}

# 参数解析
ARCHIVE_PATH=""
BACKUP=true
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            if [ -z "$ARCHIVE_PATH" ]; then
                ARCHIVE_PATH="$1"
            else
                echo -e "${RED}错误: 未知参数 $1${NC}"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# 检查参数
if [ -z "$ARCHIVE_PATH" ]; then
    echo -e "${RED}错误: 必须指定归档路径${NC}"
    show_help
    exit 1
fi

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}错误: 归档路径不存在: $ARCHIVE_PATH${NC}"
    exit 1
fi

CHANGELOG_DIR="$ARCHIVE_PATH/changelog"

if [ ! -d "$CHANGELOG_DIR" ]; then
    echo -e "${RED}错误: changelog目录不存在: $CHANGELOG_DIR${NC}"
    exit 1
fi

# 查找旧格式文件
OLD_FILES=$(find "$CHANGELOG_DIR" -maxdepth 1 -name "????-??.md" -type f)

if [ -z "$OLD_FILES" ]; then
    echo -e "${YELLOW}未找到旧格式的changelog文件${NC}"
    exit 0
fi

echo -e "${BLUE}=== xmszm Changelog 迁移工具 ===${NC}"
echo
echo "归档路径: $ARCHIVE_PATH"
echo "找到 $(echo "$OLD_FILES" | wc -l) 个旧格式文件"
echo

# 备份
if [ "$BACKUP" = true ]; then
    BACKUP_DIR="$CHANGELOG_DIR/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo -e "${BLUE}正在备份到: $BACKUP_DIR${NC}"
    cp -r "$CHANGELOG_DIR"/*.md "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ 备份完成${NC}"
    echo
fi

# 迁移每个文件
TOTAL=0
SUCCESS=0
SKIPPED=0

for old_file in $OLD_FILES; do
    TOTAL=$((TOTAL + 1))
    filename=$(basename "$old_file")
    year_month="${filename%.md}"
    year=$(echo $year_month | cut -d'-' -f1)
    month=$(echo $year_month | cut -d'-' -f2)

    echo -e "${BLUE}处理: $filename${NC}"

    # 创建月份目录
    month_dir="$CHANGELOG_DIR/$year_month"
    mkdir -p "$month_dir"

    # 检查是否已存在新格式文件
    if [ -d "$month_dir" ] && [ "$(ls -A $month_dir)" ] && [ "$FORCE" = false ]; then
        echo -e "${YELLOW}  跳过: 月份目录已存在且非空,使用 --force 强制覆盖${NC}"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # 解析旧文件,按日期分割
    current_date=""
    current_content=""
    line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # 跳过文件头(前3行)
        if [ $line_num -le 3 ]; then
            continue
        fi

        # 检查是否是日期时间行 (### YYYY-MM-DD HH:mm)
        if [[ $line =~ ^###\ ([0-9]{4}-[0-9]{2}-[0-9]{2})\ ([0-9]{2}:[0-9]{2}) ]]; then
            # 保存上一个日期的内容
            if [ -n "$current_date" ] && [ -n "$current_content" ]; then
                save_daily_log "$month_dir" "$current_date" "$current_content"
            fi

            # 开始新的日期
            current_date="${BASH_REMATCH[1]}"
            current_time="${BASH_REMATCH[2]}"
            current_content="### $current_time\n"
        elif [ -n "$current_date" ]; then
            # 累积当前日期的内容
            current_content="$current_content$line\n"
        fi
    done < "$old_file"

    # 保存最后一个日期的内容
    if [ -n "$current_date" ] && [ -n "$current_content" ]; then
        save_daily_log "$month_dir" "$current_date" "$current_content"
    fi

    # 生成月份索引
    generate_month_index "$CHANGELOG_DIR" "$year_month"

    echo -e "${GREEN}  ✓ 迁移完成${NC}"
    SUCCESS=$((SUCCESS + 1))
done

# 保存日志到日期文件
save_daily_log() {
    local month_dir="$1"
    local date="$2"
    local content="$3"

    local daily_file="$month_dir/$date.md"
    local day=$(echo $date | cut -d'-' -f3)
    local year=$(echo $date | cut -d'-' -f1)
    local month=$(echo $date | cut -d'-' -f2)

    if [ ! -f "$daily_file" ]; then
        # 创建新文件
        cat > "$daily_file" << EOF
# ${year}年${month}月${day}日变更记录

---

EOF
    fi

    # 追加内容
    echo -e "$content" >> "$daily_file"
}

# 生成月份索引
generate_month_index() {
    local changelog_dir="$1"
    local year_month="$2"
    local month_dir="$changelog_dir/$year_month"
    local index_file="$changelog_dir/$year_month-index.md"

    local year=$(echo $year_month | cut -d'-' -f1)
    local month=$(echo $year_month | cut -d'-' -f2)

    # 统计变更次数
    local total_days=0
    if [ -d "$month_dir" ]; then
        total_days=$(find "$month_dir" -name "*.md" -type f | wc -l)
    fi

    # 生成日期列表
    local date_list=""
    if [ -d "$month_dir" ]; then
        for file in $(ls -r "$month_dir"/*.md 2>/dev/null); do
            local filename=$(basename "$file" .md)
            local count=$(grep -c "^### " "$file" || echo 0)
            date_list="$date_list- [$filename](./$year_month/$filename.md) - ${count}次变更\n"
        done
    fi

    # 写入索引
    cat > "$index_file" << EOF
# ${year}年${month}月变更索引

> 本月共 $total_days 天有变更

## 日期列表

$date_list
## 快速统计

- **变更类型**: 待统计
- **高频文件**: 待统计

---

> 此文件由迁移工具自动生成
EOF

    echo -e "${GREEN}  ✓ 已生成月份索引: $index_file${NC}"
}

# 完成总结
echo
echo -e "${GREEN}=== 迁移完成 ===${NC}"
echo "总计: $TOTAL 个文件"
echo "成功: $SUCCESS 个"
echo "跳过: $SKIPPED 个"
echo

if [ "$BACKUP" = true ]; then
    echo -e "${YELLOW}提示: 原文件已备份到 $BACKUP_DIR${NC}"
    echo -e "${YELLOW}      确认迁移无误后可删除备份${NC}"
fi

echo
echo -e "${BLUE}新格式文件位于: $CHANGELOG_DIR/<YYYY-MM>/<YYYY-MM-DD>.md${NC}"
