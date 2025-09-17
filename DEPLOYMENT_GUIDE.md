# Deployment Guide for Security Scanner App

## Overview
This Flask application requires OWASP ZAP to be running, which makes deployment more complex than typical web apps. Here are your hosting options:

## Option 1: DigitalOcean Droplet (Recommended)

### Cost: $6-12/month
### Steps:
1. Create a DigitalOcean droplet with Ubuntu 22.04
2. SSH into your server
3. Install Docker and Docker Compose:
```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
```
4. Clone your repository:
```bash
git clone <your-repo-url>
cd windsurf-project
```
5. Build and run:
```bash
docker-compose up -d
```
6. Configure firewall:
```bash
sudo ufw allow 5000
sudo ufw enable
```

### Access: http://your-server-ip:5000

## Option 2: AWS EC2

### Steps:
1. Launch EC2 instance (t3.medium recommended)
2. Configure security group (allow port 5000)
3. Follow same Docker steps as DigitalOcean
4. Consider using Elastic IP for static IP

## Option 3: Railway (Simplified)

### Steps:
1. Connect your GitHub repository to Railway
2. Railway will detect the Dockerfile automatically
3. Set environment variables:
   - `PORT=5000`
   - `ZAP_HOST=127.0.0.1`
   - `ZAP_PORT=8081`
4. Deploy

### Note: ZAP may have resource limitations on Railway's free tier

## Option 4: Heroku (Limited)

### Issues:
- ZAP requires significant resources
- Ephemeral filesystem
- Complex setup for Java dependencies

### Not recommended for this application

## Option 5: Self-Hosted VPS

### Providers:
- Linode ($5-10/month)
- Vultr ($6-12/month)
- Hetzner ($4-8/month)

### Same Docker deployment process as DigitalOcean

## Environment Variables

Set these in your hosting platform:
```
PORT=5000
ZAP_HOST=127.0.0.1
ZAP_PORT=8081
```

## Security Considerations

1. **API Key**: Change the hardcoded ZAP API key in production
2. **Firewall**: Only allow necessary ports
3. **HTTPS**: Use reverse proxy (nginx) with SSL certificate
4. **Authentication**: Add user authentication for production use

## Monitoring

Consider adding:
- Health check endpoints
- Logging configuration
- Resource monitoring
- Backup strategy for scan results

## Scaling

For high traffic:
- Use load balancer
- Multiple ZAP instances
- Database for scan results
- Queue system for scan requests
