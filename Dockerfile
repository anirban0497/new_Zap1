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
    && rm /tmp/zap.sh

# Set ZAP environment
ENV ZAP_HOME=/opt/zaproxy
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
    # Start ZAP daemon and wait for it to be ready\n\
    echo "Starting ZAP daemon..."\n\
    /zap/zap.sh -daemon -host 0.0.0.0 -port 8081 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config api.key=n8j4egcp9764kits0iojhf7kk5 -config api.disablekey=false -Xmx2g &\n\
\n\
    # Wait for ZAP to start (increased timeout and better health check)\n\
    echo "Waiting for ZAP to start..."\n\
    for i in {1..120}; do\n\
        if curl -s http://127.0.0.1:8081/JSON/core/view/version/?apikey=n8j4egcp9764kits0iojhf7kk5 > /dev/null 2>&1; then\n\
            echo "ZAP is ready!"\n\
            # Additional health check - make sure ZAP is fully operational\n\
            sleep 5\n\
            if curl -s http://127.0.0.1:8081/JSON/core/view/urls/?apikey=n8j4egcp9764kits0iojhf7kk5 > /dev/null 2>&1; then\n\
                echo "ZAP is fully operational!"\n\
                break\n\
            fi\n\
        fi\n\
        echo "Waiting for ZAP... ($i/120)"\n\
        sleep 3\n\
    done\n\
\n\
    # Set ZAP to not timeout and increase memory\n\
    curl -s "http://127.0.0.1:8081/JSON/core/action/setOptionTimeoutInSecs/?Integer=0&apikey=n8j4egcp9764kits0iojhf7kk5" > /dev/null 2>&1 || true\n\
    \n\
    echo "ZAP failed to start in 180 seconds. Log:"\n\
    cat /tmp/zap.log || echo "No ZAP log available"\n\
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
# Start Flask app on Railway's assigned PORT (ZAP uses 8081)\n\
echo "Starting Flask application..."\n\
cd /app\n\
exec python -m gunicorn --bind 0.0.0.0:$PORT --timeout 300 --workers 1 app:app' > /app/start.sh \
    && chmod +x /app/start.sh

# Expose port (Railway dynamically assigns PORT)
EXPOSE 8080

# Start command
CMD ["/app/start.sh"]
