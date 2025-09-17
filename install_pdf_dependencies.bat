@echo off
echo Installing PDF generation dependencies...
echo.

echo Attempting to install reportlab...
py -m pip install reportlab==4.0.4 --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
if %errorlevel% neq 0 (
    echo Failed to install reportlab 4.0.4, trying older version...
    py -m pip install reportlab==3.6.0 --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
)

echo.
echo Attempting to install Pillow (pre-compiled wheel)...
py -m pip install --only-binary=all Pillow --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
if %errorlevel% neq 0 (
    echo Failed to install latest Pillow, trying compatible version...
    py -m pip install --only-binary=all Pillow==9.3.0 --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
)

echo.
echo Installation complete! You can now run the application with PDF support.
echo Run: py app.py
pause
