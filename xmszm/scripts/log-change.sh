#!/bin/bash

# xmszm 快速日志记录工具
# 用法: ./log-change.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认值
MESSAGE=""
FILES=""
CHANGE_TYPE="修改"
SKIP_ARCHIVE=false
AUTO_DETECT=true
IMPORT_MODE=false
IMPORT_SINCE=""

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
    -m, --message MSG       变更描述 (必需,除非使用交互模式)
    -f, --files FILES       变更文件列表,逗号分隔 (可选,自动检测git diff)
    -t, --type TYPE         变更类型 [新增|修改|修复|优化|重构|删除] (默认: 修改)
    -s, --skip-archive      跳过功能归档更新
    -n, --no-auto           禁用自动检测git diff
    --import                导入模式,从git log导入历史记录
    --since TIME            导入时的时间范围 (例如: "1 week ago", "2023-01-01")
    -h, --help              显示此帮助信息

示例:
    # 交互式记录
    $0

    # 快速记录
    $0 -m "修复登录页样式问题"

    # 指定文件和类型
    $0 -m "优化API错误处理" -f "src/api/request.js:45-60" -t "优化"

    # 从git log导入最近一周的记录
    $0 --import --since "1 week ago"

EOF
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            MESSAGE="$2"
            shift 2
            ;;
        -f|--files)
            FILES="$2"
            shift 2
            ;;
        -t|--type)
            CHANGE_TYPE="$2"
            shift 2
            ;;
        -s|--skip-archive)
            SKIP_ARCHIVE=true
            shift
            ;;
        -n|--no-auto)
            AUTO_DETECT=false
            shift
            ;;
        --import)
            IMPORT_MODE=true
            shift
            ;;
        --since)
            IMPORT_SINCE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 检查git是否可用
check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}错误: 未安装git或不在PATH中${NC}"
        return 1
    fi

    if ! git rev-parse --git-dir &> /dev/null; then
        echo -e "${YELLOW}警告: 当前目录不是git仓库,自动检测功能将被禁用${NC}"
        return 1
    fi

    return 0
}

# 自动检测变更文件
auto_detect_files() {
    if ! check_git; then
        return 1
    fi

    echo -e "${BLUE}正在检测变更文件...${NC}"

    # 获取已修改的文件
    local changed_files=$(git diff --name-only HEAD)

    if [ -z "$changed_files" ]; then
        # 没有未提交的变更,检查最后一次提交
        changed_files=$(git diff --name-only HEAD~1..HEAD)
        if [ -z "$changed_files" ]; then
            echo -e "${YELLOW}未检测到任何变更文件${NC}"
            return 1
        fi
        echo -e "${YELLOW}使用最后一次提交的变更${NC}"
    fi

    # 格式化文件列表
    FILES=""
    while IFS= read -r file; do
        if [ -n "$FILES" ]; then
            FILES="$FILES,"
        fi
        FILES="$FILES$file"
    done <<< "$changed_files"

    echo -e "${GREEN}检测到 $(echo "$changed_files" | wc -l) 个文件${NC}"
    echo "$changed_files"

    return 0
}

# 定位项目根目录和归档路径
locate_project() {
    local current_dir=$(pwd)
    local archive_path=""

    # 检查是否存在 .xmszm 目录
    if [ -d ".xmszm" ]; then
        archive_path=".xmszm"
    elif [ -d "../.xmszm" ]; then
        archive_path="../.xmszm"
    else
        echo -e "${RED}错误: 未找到 .xmszm 归档目录${NC}"
        echo -e "${YELLOW}提示: 请先初始化 xmszm 归档结构${NC}"
        return 1
    fi

    echo "$archive_path"
    return 0
}

# 交互式输入
interactive_input() {
    echo -e "${BLUE}=== xmszm 快速日志记录 ===${NC}"
    echo

    # 输入变更描述
    if [ -z "$MESSAGE" ]; then
        read -p "变更描述: " MESSAGE
        if [ -z "$MESSAGE" ]; then
            echo -e "${RED}错误: 变更描述不能为空${NC}"
            exit 1
        fi
    fi

    # 自动检测文件
    if [ "$AUTO_DETECT" = true ] && [ -z "$FILES" ]; then
        auto_detect_files || true
    fi

    # 手动输入文件(如果需要)
    if [ -z "$FILES" ]; then
        echo
        echo "请输入变更文件列表 (逗号分隔,可包含行号,例如: src/main.js:45-60,src/utils.js)"
        read -p "变更文件: " FILES
    fi

    # 选择变更类型
    echo
    echo "变更类型:"
    echo "  1) 新增"
    echo "  2) 修改 (默认)"
    echo "  3) 修复"
    echo "  4) 优化"
    echo "  5) 重构"
    echo "  6) 删除"
    read -p "选择 [1-6]: " type_choice

    case $type_choice in
        1) CHANGE_TYPE="新增" ;;
        3) CHANGE_TYPE="修复" ;;
        4) CHANGE_TYPE="优化" ;;
        5) CHANGE_TYPE="重构" ;;
        6) CHANGE_TYPE="删除" ;;
        *) CHANGE_TYPE="修改" ;;
    esac

    echo
}

# 写入日志
write_log() {
    local archive_path="$1"
    local date=$(date +"%Y-%m-%d")
    local time=$(date +"%H:%M")
    local year=$(date +"%Y")
    local month=$(date +"%m")
    local day=$(date +"%d")

    # 检查是否使用新格式
    local use_new_format=false
    local changelog_dir="$archive_path/changelog"
    local month_dir="$changelog_dir/$year-$month"
    local daily_file="$month_dir/$date.md"
    local monthly_file="$changelog_dir/$year-$month.md"

    # 如果月份目录存在或者月度文件不存在,使用新格式
    if [ -d "$month_dir" ] || [ ! -f "$monthly_file" ]; then
        use_new_format=true
    fi

    # 格式化文件列表
    local formatted_files=""
    IFS=',' read -ra FILE_ARRAY <<< "$FILES"
    for file in "${FILE_ARRAY[@]}"; do
        file=$(echo "$file" | xargs) # 去除空格
        formatted_files="$formatted_files  - \`$file\`\n"
    done

    # 构建日志条目
    local log_entry="### $time
- **任务**: $MESSAGE
- **变更文件**:
$formatted_files- **类型**: $CHANGE_TYPE
"

    if [ "$use_new_format" = true ]; then
        echo -e "${BLUE}使用新格式(按日期分割)${NC}"

        # 创建目录
        mkdir -p "$month_dir"

        # 写入日志
        if [ ! -f "$daily_file" ]; then
            # 创建新文件
            cat > "$daily_file" << EOF
# ${year}年${month}月${day}日变更记录

---

EOF
        fi

        # 追加到文件末尾
        echo -e "$log_entry" >> "$daily_file"
        echo -e "---\n" >> "$daily_file"

        # 更新月份索引
        update_month_index "$changelog_dir" "$year-$month" "$date"

        echo -e "${GREEN}✓ 已记录到: $daily_file${NC}"
    else
        echo -e "${BLUE}使用旧格式(月度聚合)${NC}"

        # 创建目录
        mkdir -p "$changelog_dir"

        # 写入日志
        if [ ! -f "$monthly_file" ]; then
            # 创建新文件
            cat > "$monthly_file" << EOF
# ${year}年${month}月变更记录

---

EOF
        fi

        # 追加到文件开头(在标题之后)
        local temp_file=$(mktemp)
        head -n 3 "$monthly_file" > "$temp_file"
        echo -e "$log_entry" >> "$temp_file"
        echo -e "---\n" >> "$temp_file"
        tail -n +4 "$monthly_file" >> "$temp_file"
        mv "$temp_file" "$monthly_file"

        echo -e "${GREEN}✓ 已记录到: $monthly_file${NC}"
    fi
}

# 更新月份索引
update_month_index() {
    local changelog_dir="$1"
    local year_month="$2"
    local date="$3"
    local index_file="$changelog_dir/$year_month.md"
    local month_dir="$changelog_dir/$year_month"

    # 统计本月变更次数
    local total_changes=0
    if [ -d "$month_dir" ]; then
        total_changes=$(find "$month_dir" -name "*.md" -type f | wc -l)
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

    # 写入索引文件
    local year=$(echo $year_month | cut -d'-' -f1)
    local month=$(echo $year_month | cut -d'-' -f2)

    cat > "$index_file" << EOF
# ${year}年${month}月变更索引

> 本月共 $total_changes 天有变更

## 日期列表

$date_list
## 快速统计

- **变更类型**: 待统计
- **高频文件**: 待统计
EOF

    echo -e "${GREEN}✓ 已更新月份索引: $index_file${NC}"
}

# 导入git历史
import_from_git() {
    if ! check_git; then
        echo -e "${RED}错误: 导入功能需要git支持${NC}"
        exit 1
    fi

    echo -e "${BLUE}正在从git log导入历史记录...${NC}"

    local since_param=""
    if [ -n "$IMPORT_SINCE" ]; then
        since_param="--since=\"$IMPORT_SINCE\""
    fi

    # 获取commit列表
    local commits=$(git log --pretty=format:"%H|%ad|%s" --date=format:"%Y-%m-%d %H:%M" $since_param)

    if [ -z "$commits" ]; then
        echo -e "${YELLOW}未找到任何提交记录${NC}"
        exit 0
    fi

    local count=0
    while IFS='|' read -r hash date message; do
        # 获取该commit的文件变更
        local files=$(git diff-tree --no-commit-id --name-only -r $hash | tr '\n' ',' | sed 's/,$//')

        if [ -n "$files" ]; then
            MESSAGE="$message"
            FILES="$files"
            CHANGE_TYPE="修改"

            # 定位项目
            local archive_path=$(locate_project)
            if [ $? -ne 0 ]; then
                exit 1
            fi

            # 写入日志(使用commit的日期)
            write_log "$archive_path"
            count=$((count + 1))
        fi
    done <<< "$commits"

    echo -e "${GREEN}✓ 共导入 $count 条记录${NC}"
}

# 主流程
main() {
    # 导入模式
    if [ "$IMPORT_MODE" = true ]; then
        import_from_git
        exit 0
    fi

    # 交互式输入
    if [ -z "$MESSAGE" ]; then
        interactive_input
    else
        # 命令行模式,自动检测文件
        if [ "$AUTO_DETECT" = true ] && [ -z "$FILES" ]; then
            auto_detect_files || true
        fi
    fi

    # 检查必需参数
    if [ -z "$MESSAGE" ]; then
        echo -e "${RED}错误: 必须提供变更描述${NC}"
        exit 1
    fi

    # 定位项目
    echo
    echo -e "${BLUE}正在定位项目...${NC}"
    local archive_path=$(locate_project)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    echo -e "${GREEN}✓ 归档路径: $archive_path${NC}"

    # 写入日志
    echo
    echo -e "${BLUE}正在写入日志...${NC}"
    write_log "$archive_path"

    # 完成
    echo
    echo -e "${GREEN}✓ 日志记录完成${NC}"
}

# 执行主流程
main
