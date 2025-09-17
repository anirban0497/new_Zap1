@echo off
echo Checking ZAP Security Scanner files...
echo.
echo Current directory: %CD%
echo.
echo Files in project directory:
dir /b
echo.
echo Templates directory:
dir /b templates
echo.
echo Static/JS directory:
dir /b static\js
echo.
echo Opening file explorer to project directory...
explorer .
pause
