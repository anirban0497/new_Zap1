@echo off
echo Alternative installation methods for SSL certificate issues...
echo.

echo Method 1: Using --trusted-host flags
echo python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt
echo.

echo Method 2: Upgrade pip first, then install
echo python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --upgrade pip
echo python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt
echo.

echo Method 3: Install packages individually
echo python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org Flask
echo python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org python-owasp-zap-v2.4
echo python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org requests
echo python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org flask-cors
echo.

echo Choose a method and run the command manually, or run install_packages.bat
pause
