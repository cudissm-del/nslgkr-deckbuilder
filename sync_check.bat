@echo off
chcp 65001 >nul
cd /d "%~dp0"
set LOG=%~dp0sync_check_log.txt

echo == Deckbuilder Sync Diagnostic == > "%LOG%"
echo Date: %DATE% %TIME% >> "%LOG%"
echo. >> "%LOG%"

echo [1] git version >> "%LOG%"
git --version >> "%LOG%" 2>&1
echo   exit=%ERRORLEVEL% >> "%LOG%"
echo. >> "%LOG%"

echo [2] current folder >> "%LOG%"
echo %CD% >> "%LOG%"
echo. >> "%LOG%"

echo [3] is this a git repo? >> "%LOG%"
git rev-parse --is-inside-work-tree >> "%LOG%" 2>&1
echo   exit=%ERRORLEVEL% >> "%LOG%"
echo. >> "%LOG%"

echo [4] current branch >> "%LOG%"
git branch --show-current >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo [5] remote >> "%LOG%"
git remote -v >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo [6] status >> "%LOG%"
git status >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo [7] last 5 local commits >> "%LOG%"
git log --oneline -5 >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo [8] fetch from remote (auth test) >> "%LOG%"
git fetch origin >> "%LOG%" 2>&1
echo   exit=%ERRORLEVEL%   ^(non-zero = auth or network problem^) >> "%LOG%"
echo. >> "%LOG%"

echo [9] local vs remote gap  ^(behind  ahead^) >> "%LOG%"
git rev-list --left-right --count origin/main...HEAD >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo [10] unpushed commits >> "%LOG%"
git log origin/main..HEAD --oneline >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo [11] user config >> "%LOG%"
git config user.name >> "%LOG%" 2>&1
git config user.email >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo [12] credential helper >> "%LOG%"
git config --get credential.helper >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo == done ==
echo.
type "%LOG%"
echo.
echo ----------------------------------------
echo Log saved to: %LOG%
echo Send this file to Claude.
echo ----------------------------------------
pause
