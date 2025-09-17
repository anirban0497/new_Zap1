# ZAP Setup Guide for Security Scanner

## The Problem
You're getting a connection error because ZAP isn't properly configured or running on port 8081.

## Solution Steps

### Step 1: Download and Install OWASP ZAP
1. Go to https://www.zaproxy.org/download/
2. Download ZAP for Windows
3. Install ZAP

### Step 2: Start ZAP with Correct Configuration

**Option A: GUI Mode (Recommended for beginners)**
1. Launch ZAP from Start Menu
2. Choose "No, I do not want to persist this session"
3. Go to Tools → Options → Local Proxies
4. Change port from 8080 to 8081
5. Click OK
6. ZAP should now show "ZAP is now listening on 127.0.0.1:8081"

**Option B: Headless Mode (Command Line)**
```cmd
cd "C:\Program Files\OWASP\Zed Attack Proxy"
zap.bat -daemon -port 8081 -host 127.0.0.1
```

### Step 3: Verify ZAP is Running
1. Open browser and go to: http://127.0.0.1:8081
2. You should see ZAP API page
3. Or check the ZAP Status in our web app at: http://localhost:5000

### Step 4: Configure API (if needed)
1. In ZAP GUI: Tools → Options → API
2. Ensure "Enable API" is checked
3. Note the API Key (usually empty by default)

## Common Issues and Fixes

### Issue 1: Port Already in Use
- Change ZAP to use port 8082 instead
- Update our app.py to use port 8082

### Issue 2: Windows Firewall
- Allow ZAP through Windows Firewall
- Or temporarily disable firewall for testing

### Issue 3: ZAP Not Starting
- Run ZAP as Administrator
- Check if another application is using port 8081

## Quick Test Commands
Test ZAP connection from command line:
```cmd
curl http://127.0.0.1:8081/JSON/core/view/version/
```

Should return ZAP version information.

## Alternative: Use Default Port 8080
If you can't change ZAP to 8081, update the app.py file:
```python
zap_port = os.getenv('ZAP_PORT', '8080')  # Change from 8081 to 8080
```
