@echo off
REM ============================================
REM UPDATE_LEAGUES.BAT
REM - Run compiled MATLAB exe on all leagues
REM - Commit and push to GitHub Pages
REM ============================================

cd /d "%~dp0"
echo.
echo ==========================
echo Updating Shabi Leagues...
echo ==========================

REM Run analyzer (compiled from MATLAB)

if %errorlevel% neq 0 (
    echo Error running analyzer.
    pause
    exit /b
)

REM Git update section
echo.
echo Committing changes to GitHub...
git add .
git commit -m "Auto-update leagues"
git push origin main

echo.
echo Update complete! Check GitHub Pages link.
pause
