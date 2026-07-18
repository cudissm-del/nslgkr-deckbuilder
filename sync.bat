@echo off
cd /d "%~dp0"
echo == Deckbuilder GitHub Sync ==
git add -A
git commit -m "data update"
git push
echo.
echo Done. Press any key to close.
pause >nul
