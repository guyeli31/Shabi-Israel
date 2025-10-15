@echo off
REM ==========================================================
REM  Generate_Structure.bat
REM  Creates a text file with full folder/file hierarchy
REM  relative to the current directory
REM ==========================================================

REM ---- move to script directory ----
cd /d "%~dp0"

REM ---- name of output file ----
set OUTPUT=project_structure.txt

REM ---- delete old file if exists ----
if exist "%OUTPUT%" del "%OUTPUT%"

echo Project directory structure generated on %DATE% %TIME%> "%OUTPUT%"
echo Root: %cd%>> "%OUTPUT%"
echo.>> "%OUTPUT%"

REM ---- list all folders and files ----
REM /F - list files
REM /S - recursive
REM /A:-D - include files only
REM /B - bare format (no headers)
REM For tree view, we use TREE command instead

echo Directory tree:>> "%OUTPUT%"
echo ---------------------------------------------------------->> "%OUTPUT%"
tree /F /A >> "%OUTPUT%"

echo.>> "%OUTPUT%"
echo Done! File saved as "%OUTPUT%"
pause
