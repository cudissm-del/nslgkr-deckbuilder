@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo == Deckbuilder GitHub Sync ==
echo.

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Not a git repository: %CD%
  echo         The .git folder is missing or damaged.
  goto :end
)

echo [1/4] staging...
git add -A
if errorlevel 1 goto :fail

echo [2/4] committing...
git diff --cached --quiet
if not errorlevel 1 (
  echo       nothing to commit - skipping
) else (
  git commit -m "data update"
  if errorlevel 1 goto :fail
)

echo [3/4] pulling remote changes...
git pull --rebase origin main
if errorlevel 1 (
  echo.
  echo [ERROR] Pull/rebase failed - likely a conflict or auth problem.
  echo         Run:  git status     to see conflicted files
  echo         Undo: git rebase --abort
  goto :end
)

echo [4/4] pushing...
git push origin main
if errorlevel 1 goto :fail

echo.
echo == SUCCESS ==
goto :end

:fail
echo.
echo == FAILED ==  ^(see the error message above^)
echo.
echo Common causes:
echo   - Auth expired      : re-login via Windows Credential Manager
echo   - Remote ahead      : someone edited on github.com
echo   - Wrong branch      : run  git branch --show-current

:end
echo.
pause
