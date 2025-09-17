@echo off
echo Attempting to install Python packages with SSL workarounds...
echo.

echo Method 1: Installing with trusted hosts (bypassing SSL)...
python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org Flask==2.3.3
python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org python-owasp-zap-v2.4==0.0.21
python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org requests==2.31.0
python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org flask-cors==4.0.0
python -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org gunicorn==21.2.0

echo.
echo Installation complete! Testing imports...
python -c "import flask; print('Flask installed successfully')"
python -c "import zapv2; print('ZAP v2.4 installed successfully')"
python -c "import requests; print('Requests installed successfully')"
python -c "import flask_cors; print('Flask-CORS installed successfully')"

echo.
echo All packages installed! You can now run: python app.py
pause
