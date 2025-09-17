# ZAP External Connection Setup Guide

## Overview
This webapp can connect to your local OWASP ZAP instance instead of using the built-in containerized ZAP. This allows you to use your existing ZAP configuration, plugins, and session data.

## Prerequisites
1. **OWASP ZAP installed locally** - Download from https://www.zaproxy.org/download/
2. **ZAP running with API enabled**
3. **Correct port configuration**

## Setup Instructions

### Step 1: Start ZAP with API Enabled

#### Option A: ZAP Desktop (Recommended)
1. Launch ZAP Desktop application
2. Go to **Tools → Options → API**
3. Check **"Enable API"**
4. Set or note your **API Key** (e.g., `n8j4egcp9764kits0iojhf7kk5`)
5. Click **OK**

#### Option B: ZAP Daemon Mode
```bash
# Windows
zap.bat -daemon -host 0.0.0.0 -port 8080 -config api.key=n8j4egcp9764kits0iojhf7kk5

# Linux/Mac
./zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.key=n8j4egcp9764kits0iojhf7kk5
```

### Step 2: Configure Webapp Connection

1. **Open the webapp** in your browser
2. **Find the "ZAP Configuration" section** at the top
3. **Enter your ZAP details**:
   - **ZAP Proxy Address**: `localhost` (or your ZAP server IP)
   - **ZAP Proxy Port**: `8080` (default ZAP port)
   - **ZAP API Key**: Your ZAP API key (from Step 1)

4. **Click "Update Configuration"**
5. **Click "Test Connection"** to verify

### Step 3: Verify Connection

You should see:
```
✅ Connected to ZAP v2.x.x at localhost:8080
Found X URLs in ZAP session
```

## Troubleshooting

### Connection Refused Error
```
Connection Failed: Cannot reach localhost:8080 - connection refused
```

**Solutions**:
1. **Check ZAP is running**: Visit http://localhost:8080 in browser
2. **Verify port**: ZAP default is 8080, not 8081
3. **Check firewall**: Ensure port 8080 is not blocked
4. **Try 127.0.0.1**: Use `127.0.0.1` instead of `localhost`

### API Key Issues
```
Connection Failed: Unauthorized - Invalid API key
```

**Solutions**:
1. **Get correct API key**: Tools → Options → API in ZAP
2. **Enable API**: Make sure "Enable API" is checked
3. **Disable key requirement**: Uncheck "Require API key" for testing

### Port Conflicts
If port 8080 is in use:
1. **Change ZAP port**: Tools → Options → Local Proxies → Port
2. **Update webapp config**: Use the new port in configuration

## Default Configuration Values

| Setting | Default Value | Description |
|---------|---------------|-------------|
| ZAP Proxy Address | `localhost` | IP/hostname of ZAP instance |
| ZAP Proxy Port | `8080` | ZAP proxy port (not API port) |
| ZAP API Key | `n8j4egcp9764kits0iojhf7kk5` | API authentication key |

## Advanced Usage

### Using Remote ZAP
To connect to ZAP on another machine:
1. **Start ZAP with external binding**:
   ```bash
   zap.sh -daemon -host 0.0.0.0 -port 8080
   ```
2. **Update webapp config**:
   - ZAP Proxy Address: `192.168.1.100` (remote IP)
   - ZAP Proxy Port: `8080`

### Multiple ZAP Instances
You can switch between different ZAP instances by:
1. Updating the configuration fields
2. Clicking "Update Configuration"
3. Testing the new connection

## Benefits of External ZAP

- **Persistent sessions**: Your scan data survives webapp restarts
- **Custom plugins**: Use your installed ZAP add-ons
- **Better performance**: No container resource limits
- **Familiar interface**: Access ZAP GUI alongside webapp
- **Advanced configuration**: Full ZAP settings available

## Security Notes

- **API Key**: Keep your API key secure
- **Network access**: Only allow trusted networks to access ZAP
- **Firewall**: Configure appropriate firewall rules
- **HTTPS**: Consider using HTTPS for remote connections
