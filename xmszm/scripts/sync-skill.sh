#!/bin/bash

# xmszm Skill 更新脚本
# 作用：将当前目录的 xmszm 复制/更新到 ~/.claude/skills/xmszm

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XMSZM_SOURCE="$(dirname "$SCRIPT_DIR")"  # 父目录（xmszm）
SKILLS_DIR="${HOME}/.claude/skills"
XMSZM_TARGET="${SKILLS_DIR}/xmszm"
BACKUP_SUFFIX=".backup-$(date +%Y%m%d-%H%M%S)"

# 显示帮助
show_help() {
    cat << EOF
用法: $0 [选项]

作用：将当前的 xmszm 目录更新到 ~/.claude/skills/xmszm

选项:
    -h, --help              显示此帮助信息
    -f, --force             强制覆盖，不提示确认
    -b, --no-backup         不备份原有的 skill（默认会备份）
    -s, --sync              使用 rsync 同步模式（仅删除不同的文件）
    --dry-run               模拟运行，显示将执行的操作但不实际执行

示例:
    $0                      # 正常更新（有备份，需确认）
    $0 -f                   # 强制覆盖，不提示
    $0 --no-backup -f       # 强制覆盖，不备份
    $0 --sync               # 同步模式（更安全）
    $0 --dry-run            # 查看将执行的操作

EOF
}

# 参数解析
FORCE=false
BACKUP=true
SYNC=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -b|--no-backup)
            BACKUP=false
            shift
            ;;
        -s|--sync)
            SYNC=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 显示配置信息
echo -e "${BLUE}=== xmszm Skill 更新工具 ===${NC}"
echo
echo "源目录: $XMSZM_SOURCE"
echo "目标目录: $XMSZM_TARGET"
echo

# 检查源目录
if [ ! -d "$XMSZM_SOURCE" ]; then
    echo -e "${RED}错误: 源目录不存在: $XMSZM_SOURCE${NC}"
    exit 1
fi

# 检查源目录是否是有效的 xmszm
if [ ! -f "$XMSZM_SOURCE/SKILL.md" ]; then
    echo -e "${RED}错误: 源目录不是有效的 xmszm（缺少 SKILL.md）${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 源目录有效${NC}"
echo

# 检查或创建 skills 目录
if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${YELLOW}创建目录: $SKILLS_DIR${NC}"
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$SKILLS_DIR"
    fi
fi

# 处理备份
if [ -d "$XMSZM_TARGET" ] && [ "$BACKUP" = true ]; then
    BACKUP_DIR="${XMSZM_TARGET}${BACKUP_SUFFIX}"
    echo -e "${YELLOW}备份原有的 skill...${NC}"
    echo "备份路径: $BACKUP_DIR"

    if [ "$DRY_RUN" = false ]; then
        cp -r "$XMSZM_TARGET" "$BACKUP_DIR"
        echo -e "${GREEN}✓ 备份完成${NC}"
    else
        echo -e "${BLUE}[DRY-RUN] 将备份到: $BACKUP_DIR${NC}"
    fi
    echo
fi

# 执行更新
echo -e "${BLUE}正在更新 skill...${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}[DRY-RUN] 模拟执行以下操作:${NC}"
    if [ "$SYNC" = true ]; then
        echo "rsync -av --delete '$XMSZM_SOURCE/' '$XMSZM_TARGET/'"
    else
        echo "rm -rf '$XMSZM_TARGET'"
        echo "cp -r '$XMSZM_SOURCE' '$XMSZM_TARGET'"
    fi
else
    if [ "$SYNC" = true ]; then
        # 同步模式：只同步不同的文件
        if command -v rsync &> /dev/null; then
            echo -e "${BLUE}使用 rsync 同步模式...${NC}"
            rsync -av --delete "$XMSZM_SOURCE/" "$XMSZM_TARGET/"
        else
            echo -e "${YELLOW}警告: rsync 未安装，使用普通复制模式${NC}"
            if [ -d "$XMSZM_TARGET" ]; then
                rm -rf "$XMSZM_TARGET"
            fi
            cp -r "$XMSZM_SOURCE" "$XMSZM_TARGET"
        fi
    else
        # 普通模式：完全覆盖
        if [ -d "$XMSZM_TARGET" ]; then
            rm -rf "$XMSZM_TARGET"
        fi
        cp -r "$XMSZM_SOURCE" "$XMSZM_TARGET"
    fi

    echo -e "${GREEN}✓ 更新完成${NC}"
fi

echo

# 验证更新
if [ "$DRY_RUN" = false ]; then
    if [ -f "$XMSZM_TARGET/SKILL.md" ]; then
        echo -e "${GREEN}✓ 验证成功: 目标 skill 有效${NC}"
        echo
        echo "信息:"
        echo "  源目录: $XMSZM_SOURCE"
        echo "  目标目录: $XMSZM_TARGET"
        [ "$BACKUP" = true ] && echo "  备份目录: $BACKUP_DIR"
        echo
        echo -e "${GREEN}=== 更新完成 ===${NC}"
    else
        echo -e "${RED}错误: 更新后的 skill 无效（缺少 SKILL.md）${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}[DRY-RUN] 模拟执行完成${NC}"
    echo "如果上述操作符合预期，运行不带 --dry-run 参数的命令来实际执行"
fi
