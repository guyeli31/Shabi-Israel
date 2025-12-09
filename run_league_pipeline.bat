@echo off
echo ===============================================
echo Running LeagueMain.m in MATLAB...
echo ===============================================

REM Run MATLAB script and wait until it finishes
matlab -nosplash -nodesktop -wait -r "run('G:\\My Drive\\Matlab_Proj\\Olds\\ShabiLeague\\Git\\ShabiIsrael\\LeagueMain.m'); exit"

echo.
echo ===============================================
echo MATLAB finished. Running update_leagues.bat...
echo ===============================================

REM Change to the batch directory (IMPORTANT: /d switches drive)
cd /d "G:\My Drive\Matlab_Proj\Olds\ShabiLeague\Git\ShabiIsrael"

REM Run the update_leagues batch file
call "update_leagues.bat"

echo.
echo ===============================================
echo All tasks completed successfully.
echo ===============================================
pause
