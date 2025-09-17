# Troubleshooting Guide

## Issue: Python not found or SSL Certificate errors

### Solution 1: Fix Python PATH
1. Open Windows Settings → Apps → Advanced app settings → App execution aliases
2. Turn OFF the Python aliases that redirect to Microsoft Store
3. Add Python to your PATH:
   - Find your Python installation (usually in `C:\Users\[username]\AppData\Local\Programs\Python\` or `C:\Python39\`)
   - Add both the Python directory and Scripts directory to PATH

### Solution 2: Use py launcher instead of python
Try using `py` instead of `python`:
```cmd
py -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org Flask==2.3.3
```

### Solution 3: Install packages with SSL bypass
```cmd
py -m pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt
```

### Solution 4: Use Anaconda/Miniconda (Recommended)
1. Download Anaconda from https://www.anaconda.com/products/distribution
2. Install Anaconda
3. Open Anaconda Prompt
4. Navigate to project directory
5. Run: `conda install flask requests`
6. Run: `pip install python-owasp-zap-v2.4 flask-cors`

### Solution 5: Create a Standalone Version
I can create a version that doesn't require external packages by using only Python standard library.

## Quick Test Commands
Test if Python is working:
```cmd
py --version
py -c "print('Python is working')"
```

Test package installation:
```cmd
py -c "import flask; print('Flask installed')"
```
