# 🆓 Free Deployment Guide for ZAP Security Scanner

## 🚀 Ready-to-Deploy Configuration

Your application is now configured for multiple free deployment platforms. Choose the one that works best for you:

## Option 1: Railway (Recommended) 🚂

**Why Railway?**
- Excellent Docker support
- Generous free tier (512MB RAM, 1GB disk)
- Automatic deployments from GitHub
- Good for ZAP's resource requirements

**Steps:**
1. Push your code to GitHub
2. Go to [Railway.app](https://railway.app)
3. Sign up with GitHub
4. Click "Deploy from GitHub repo"
5. Select your repository
6. Railway will automatically detect the Dockerfile
7. Your app will be deployed with a public URL

**Environment Variables (Auto-configured):**
- `PORT=5000`
- `ZAP_HOST=127.0.0.1`
- `ZAP_PORT=8081`

## Option 2: Render 🎨

**Why Render?**
- Free tier with 512MB RAM
- Easy Docker deployments
- Automatic SSL certificates
- Good uptime

**Steps:**
1. Push code to GitHub
2. Go to [Render.com](https://render.com)
3. Sign up with GitHub
4. Click "New Web Service"
5. Connect your repository
6. Render will use the `render.yaml` configuration
7. Deploy automatically

## Option 3: Fly.io 🪰

**Why Fly.io?**
- Generous free allowance
- Excellent performance
- Global edge deployment
- Great for containerized apps

**Steps:**
1. Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Sign up: `fly auth signup`
3. Navigate to your project directory
4. Deploy: `fly deploy`
5. Your app will be live with a `.fly.dev` domain

## 🔧 Pre-Deployment Checklist

✅ **Dockerfile** - Updated with latest ZAP version (2.16.1)
✅ **Requirements.txt** - Includes gunicorn for production
✅ **Railway.json** - Railway-specific configuration
✅ **Render.yaml** - Render deployment configuration  
✅ **Fly.toml** - Fly.io configuration
✅ **.dockerignore** - Optimized Docker builds

## 🚨 Important Notes

### Resource Requirements
- **Minimum RAM**: 512MB (ZAP needs memory)
- **Startup Time**: 30-60 seconds (ZAP initialization)
- **CPU**: Shared CPU is sufficient

### Limitations on Free Tiers
- **Scan Duration**: Limited by platform timeouts
- **Concurrent Scans**: One at a time recommended
- **Storage**: Ephemeral (reports not persistent)

### Security Considerations
- Change the ZAP API key in production
- Consider adding authentication
- Use HTTPS (provided by all platforms)

## 🎯 Quick Deploy Commands

### Railway
```bash
# Push to GitHub, then connect via Railway dashboard
git add .
git commit -m "Ready for Railway deployment"
git push origin main
```

### Render
```bash
# Push to GitHub, then connect via Render dashboard
git add .
git commit -m "Ready for Render deployment"
git push origin main
```

### Fly.io
```bash
# Direct deployment
fly deploy
```

## 🔍 Testing Your Deployment

Once deployed, test these endpoints:
- `GET /` - Main interface
- `GET /debug_scan` - ZAP connection test
- `GET /force_results` - Sample vulnerability data
- `POST /start_scan` - Start actual scans

## 💡 Troubleshooting

**If ZAP fails to start:**
- Check platform logs
- Increase startup timeout
- Verify Java installation in container

**If scans timeout:**
- Use shorter scan durations
- Focus on specific endpoints
- Use the Force Results feature for demos

## 🎉 Success!

Your ZAP Security Scanner will be accessible at:
- **Railway**: `https://your-app-name.railway.app`
- **Render**: `https://your-app-name.onrender.com`
- **Fly.io**: `https://your-app-name.fly.dev`

Choose your preferred platform and deploy! 🚀
