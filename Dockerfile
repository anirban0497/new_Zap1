FROM python:3.9

# Install system dependencies including Java
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/default-java

# Download and install ZAP
RUN wget -q https://github.com/zaproxy/zaproxy/releases/download/v2.16.1/ZAP_2_16_1_unix.sh -O /tmp/zap.sh \
    && chmod +x /tmp/zap.sh \
    && /tmp/zap.sh -q -dir /opt/zaproxy \
    && rm /tmp/zap.sh \
    && mkdir -p /zap \
    && ln -s /opt/zaproxy/zap.sh /zap/zap.sh

# Set ZAP environment
ENV ZAP_HOME=/opt/zaproxy
ENV PATH=$PATH:/opt/zaproxy
ENV PATH=$ZAP_HOME:$PATH

# Create app directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create startup script that handles ZAP startup more robustly
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Function to start ZAP\n\
start_zap() {\n\
    echo "Starting ZAP daemon..."\n\
    cd $ZAP_HOME\n\
    \n\
    # Check if ZAP executable exists\n\
    if [ ! -f "$ZAP_HOME/zap.sh" ]; then\n\
        echo "ERROR: ZAP executable not found at $ZAP_HOME/zap.sh"\n\
        return 1\n\
    fi\n\
    \n\
    # Start ZAP daemon with reduced memory and logging\n\
    echo "Starting ZAP daemon with 256MB memory..."\n\
    $ZAP_HOME/zap.sh -daemon -host 0.0.0.0 -port 8081 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config api.key=n8j4egcp9764kits0iojhf7kk5 -config api.disablekey=false -config api.incerrordetails=true -Xmx256m > /tmp/zap.log 2>&1 &\n\
    ZAP_PID=$!\n\
    echo "ZAP started with PID: $ZAP_PID"\n\
\n\
    # Wait for ZAP to start with better error checking\n\
    echo "Waiting for ZAP to start..."\n\
    for i in {1..40}; do\n\
        # Check if ZAP process is still running\n\
        if ! kill -0 $ZAP_PID 2>/dev/null; then\n\
            echo "ERROR: ZAP process died. Log:"\n\
            cat /tmp/zap.log || echo "No ZAP log available"\n\
            return 1\n\
        fi\n\
        \n\
        # Check if ZAP is responding\n\
        if curl -s http://127.0.0.1:8081/JSON/core/view/version/?apikey=n8j4egcp9764kits0iojhf7kk5 > /dev/null 2>&1; then\n\
            echo "ZAP is ready!"\n\
            sleep 3\n\
            if curl -s http://127.0.0.1:8081/JSON/core/view/urls/?apikey=n8j4egcp9764kits0iojhf7kk5 > /dev/null 2>&1; then\n\
                echo "ZAP is fully operational!"\n\
                curl -s "http://127.0.0.1:8081/JSON/core/action/setOptionTimeoutInSecs/?Integer=0&apikey=n8j4egcp9764kits0iojhf7kk5" > /dev/null 2>&1 || true\n\
                return 0\n\
            fi\n\
        fi\n\
        echo "Waiting for ZAP... ($i/40) PID: $ZAP_PID"\n\
        sleep 3\n\
    done\n\
    \n\
    echo "ZAP failed to start in 120 seconds. Final log:"\n\
    cat /tmp/zap.log || echo "No ZAP log available"\n\
    echo "ZAP process status:"\n\
    ps aux | grep zap || echo "No ZAP processes found"\n\
    return 1\n\
}\n\
\n\
# Try to start ZAP, but continue even if it fails\n\
if start_zap; then\n\
    echo "ZAP started successfully"\n\
else\n\
    echo "ZAP failed to start - continuing with fallback mode"\n\
fi\n\
\n\
# Run ZAP verification script\n\
echo "Running ZAP verification..."\n\
chmod +x /app/verify_zap.sh\n\
/app/verify_zap.sh\n\
\n\
# Start Flask app on Railway's assigned PORT (ZAP uses 8081)\n\
echo "Starting Flask application..."\n\
cd /app\n\
exec python -m gunicorn --bind 0.0.0.0:$PORT --timeout 300 --workers 1 app:app' > /app/start.sh \
    && chmod +x /app/start.sh

# Expose ports - Flask on dynamic PORT, ZAP on 8081
EXPOSE 8080 8081

# Start command
CMD ["/app/start.sh"]
