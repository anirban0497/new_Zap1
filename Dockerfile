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

# Create startup script
RUN echo '#!/bin/bash\n\
# Start ZAP in daemon mode\n\
$ZAP_HOME/zap.sh -daemon -host 0.0.0.0 -port 8081 -config api.key=n8j4egcp9764kits0iojhf7kk5 &\n\
\n\
# Wait for ZAP to start\n\
sleep 10\n\
\n\
# Start Flask app\n\
exec gunicorn --bind 0.0.0.0:$PORT app:app' > /app/start.sh \
    && chmod +x /app/start.sh

# Expose port
EXPOSE 5000

# Start command
CMD ["/app/start.sh"]
