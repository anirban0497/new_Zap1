#!/bin/bash

# Quick deployment script for Ubuntu/Debian servers

echo "🚀 Starting deployment of Security Scanner App..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt install -y docker.io docker-compose
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. Please log out and back in, then run this script again."
    exit 1
fi

# Install Git if not present
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git..."
    sudo apt install -y git
fi

# Clone or update repository
if [ -d "windsurf-project" ]; then
    echo "📁 Updating existing repository..."
    cd windsurf-project
    git pull
else
    echo "📁 Cloning repository..."
    # Replace with your actual repository URL
    git clone https://github.com/yourusername/windsurf-project.git
    cd windsurf-project
fi

# Build and start the application
echo "🔨 Building and starting the application..."
docker-compose down
docker-compose build
docker-compose up -d

# Configure firewall
echo "🔒 Configuring firewall..."
sudo ufw allow 5000
sudo ufw --force enable

# Check if application is running
sleep 10
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Application is running successfully!"
    echo "🌐 Access your app at: http://$(curl -s ifconfig.me):5000"
else
    echo "❌ Application may not be running correctly. Check logs with:"
    echo "   docker-compose logs"
fi

echo "🎉 Deployment complete!"
