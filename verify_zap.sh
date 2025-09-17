#!/bin/bash

echo "=== ZAP Configuration Verification ==="
echo "Date: $(date)"
echo

# Check if ZAP is installed
echo "1. Checking ZAP installation..."
if [ -f "/opt/zaproxy/zap.sh" ]; then
    echo "✓ ZAP executable found at /opt/zaproxy/zap.sh"
    ls -la /opt/zaproxy/zap.sh
else
    echo "✗ ZAP executable NOT found at /opt/zaproxy/zap.sh"
fi
echo

# Check Java installation
echo "2. Checking Java installation..."
if command -v java &> /dev/null; then
    echo "✓ Java is installed:"
    java -version
else
    echo "✗ Java is NOT installed"
fi
echo

# Check if ZAP process is running
echo "3. Checking ZAP process..."
ZAP_PROCESSES=$(ps aux | grep -i zap | grep -v grep)
if [ -n "$ZAP_PROCESSES" ]; then
    echo "✓ ZAP processes found:"
    echo "$ZAP_PROCESSES"
else
    echo "✗ No ZAP processes running"
fi
echo

# Check if port 8081 is listening
echo "4. Checking port 8081..."
if command -v netstat &> /dev/null; then
    PORT_CHECK=$(netstat -tlnp | grep :8081)
    if [ -n "$PORT_CHECK" ]; then
        echo "✓ Port 8081 is listening:"
        echo "$PORT_CHECK"
    else
        echo "✗ Port 8081 is NOT listening"
    fi
elif command -v ss &> /dev/null; then
    PORT_CHECK=$(ss -tlnp | grep :8081)
    if [ -n "$PORT_CHECK" ]; then
        echo "✓ Port 8081 is listening:"
        echo "$PORT_CHECK"
    else
        echo "✗ Port 8081 is NOT listening"
    fi
else
    echo "? Cannot check port 8081 (netstat/ss not available)"
    # Alternative check using lsof
    if command -v lsof &> /dev/null; then
        LSOF_CHECK=$(lsof -i :8081)
        if [ -n "$LSOF_CHECK" ]; then
            echo "✓ Port 8081 is listening (lsof):"
            echo "$LSOF_CHECK"
        else
            echo "✗ Port 8081 is NOT listening (lsof)"
        fi
    fi
fi

# Test socket connection from within container
echo "Testing socket connection to 127.0.0.1:8081..."
if timeout 5 bash -c "</dev/tcp/127.0.0.1/8081"; then
    echo "✓ Socket connection to 127.0.0.1:8081 successful"
else
    echo "✗ Socket connection to 127.0.0.1:8081 failed"
fi

echo "Testing socket connection to localhost:8081..."
if timeout 5 bash -c "</dev/tcp/localhost/8081"; then
    echo "✓ Socket connection to localhost:8081 successful"
else
    echo "✗ Socket connection to localhost:8081 failed"
fi
echo

# Test ZAP API connection
echo "5. Testing ZAP API connection..."
API_KEY="n8j4egcp9764kits0iojhf7kk5"
for HOST in "127.0.0.1" "localhost" "0.0.0.0"; do
    echo "Testing $HOST:8081..."
    if curl -s --connect-timeout 5 "http://$HOST:8081/JSON/core/view/version/?apikey=$API_KEY" > /dev/null 2>&1; then
        VERSION=$(curl -s "http://$HOST:8081/JSON/core/view/version/?apikey=$API_KEY" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        echo "✓ ZAP API accessible on $HOST:8081 (Version: $VERSION)"
    else
        echo "✗ ZAP API NOT accessible on $HOST:8081"
    fi
done
echo

# Check ZAP logs
echo "6. Checking ZAP logs..."
if [ -f "/tmp/zap.log" ]; then
    echo "✓ ZAP log found. Last 20 lines:"
    tail -20 /tmp/zap.log
else
    echo "✗ ZAP log NOT found at /tmp/zap.log"
fi
echo

# Check memory usage
echo "7. Checking memory usage..."
if command -v free &> /dev/null; then
    echo "Memory status:"
    free -h
else
    echo "? Cannot check memory (free command not available)"
fi
echo

echo "=== Verification Complete ==="
