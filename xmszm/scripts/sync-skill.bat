@echo off
REM xmszm Skill 更新脚本（Windows 版本）
REM 作用：将当前目录的 xmszm 复制/更新到 %USERPROFILE%\.claude\skills\xmszm

setlocal enabledelayedexpansion

REM 颜色定义（模拟）
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM 配置
set "SCRIPT_DIR=%~dp0"
for %%A in ("!SCRIPT_DIR!..") do set "XMSZM_SOURCE=%%~fA"
set "SKILLS_DIR=%USERPROFILE%\.claude\skills"
set "XMSZM_TARGET=%SKILLS_DIR%\xmszm"

REM 参数解析
set "FORCE=false"
set "BACKUP=true"
set "DRY_RUN=false"

:parse_args
if "%~1"=="" goto parse_done
if "%~1"=="-h" goto show_help
if "%~1"=="--help" goto show_help
if "%~1"=="-f" (
    set "FORCE=true"
    shift
    goto parse_args
)
if "%~1"=="--force" (
    set "FORCE=true"
    shift
    goto parse_args
)
if "%~1"=="-b" (
    set "BACKUP=false"
    shift
    goto parse_args
)
if "%~1"=="--no-backup" (
    set "BACKUP=false"
    shift
    goto parse_args
)
if "%~1"=="--dry-run" (
    set "DRY_RUN=true"
    shift
    goto parse_args
)
echo 错误: 未知选项 %~1
goto show_help

:parse_done
echo ===== xmszm Skill 更新工具 =====
echo.
echo 源目录: %XMSZM_SOURCE%
echo 目标目录: %XMSZM_TARGET%
echo.

REM 检查源目录
if not exist "%XMSZM_SOURCE%" (
    echo 错误: 源目录不存在: %XMSZM_SOURCE%
    exit /b 1
)

REM 检查源目录是否是有效的 xmszm
if not exist "%XMSZM_SOURCE%\SKILL.md" (
    echo 错误: 源目录不是有效的 xmszm（缺少 SKILL.md）
    exit /b 1
)

echo ✓ 源目录有效
echo.

REM 检查或创建 skills 目录
if not exist "%SKILLS_DIR%" (
    echo 创建目录: %SKILLS_DIR%
    if "!DRY_RUN!"=="false" (
        mkdir "%SKILLS_DIR%"
    )
)

REM 处理备份
if exist "%XMSZM_TARGET%" (
    if "!BACKUP!"=="true" (
        for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
        for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
        set "BACKUP_DIR=%XMSZM_TARGET%.backup-!mydate!-!mytime!"

        echo 备份原有的 skill...
        echo 备份路径: !BACKUP_DIR!

        if "!DRY_RUN!"=="false" (
            xcopy "%XMSZM_TARGET%" "!BACKUP_DIR!" /E /I /Y >nul 2>&1
            echo ✓ 备份完成
        ) else (
            echo [DRY-RUN] 将备份到: !BACKUP_DIR!
        )
        echo.
    )
)

REM 执行更新
echo 正在更新 skill...
echo.

if "!DRY_RUN!"=="true" (
    echo [DRY-RUN] 模拟执行以下操作:
    echo rmdir /S /Q "%XMSZM_TARGET%"
    echo xcopy "%XMSZM_SOURCE%" "%XMSZM_TARGET%" /E /I /Y
) else (
    if exist "%XMSZM_TARGET%" (
        rmdir /S /Q "%XMSZM_TARGET%"
    )
    xcopy "%XMSZM_SOURCE%" "%XMSZM_TARGET%" /E /I /Y >nul 2>&1
    echo ✓ 更新完成
)

echo.

REM 验证更新
if "!DRY_RUN!"=="false" (
    if exist "%XMSZM_TARGET%\SKILL.md" (
        echo ✓ 验证成功: 目标 skill 有效
        echo.
        echo 信息:
        echo   源目录: %XMSZM_SOURCE%
        echo   目标目录: %XMSZM_TARGET%
        if "!BACKUP!"=="true" if defined BACKUP_DIR (
            echo   备份目录: !BACKUP_DIR!
        )
        echo.
        echo ===== 更新完成 =====
    ) else (
        echo 错误: 更新后的 skill 无效（缺少 SKILL.md）
        exit /b 1
    )
) else (
    echo [DRY-RUN] 模拟执行完成
    echo 如果上述操作符合预期，运行不带 --dry-run 参数的命令来实际执行
)

goto :eof

:show_help
echo 用法: %~nx0 [选项]
echo.
echo 作用：将当前的 xmszm 目录更新到 %%USERPROFILE%%\.claude\skills\xmszm
echo.
echo 选项:
echo     -h, --help              显示此帮助信息
echo     -f, --force             强制覆盖，不提示确认
echo     -b, --no-backup         不备份原有的 skill（默认会备份）
echo     --dry-run               模拟运行，显示将执行的操作但不实际执行
echo.
echo 示例:
echo     %~nx0                   REM 正常更新（有备份）
echo     %~nx0 -f                REM 强制覆盖，不提示
echo     %~nx0 --no-backup -f    REM 强制覆盖，不备份
echo     %~nx0 --dry-run         REM 查看将执行的操作
echo.
exit /b 0
