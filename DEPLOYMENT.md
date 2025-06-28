# Deployment Instructions for Vercel

## Prerequisites
1. Install Git if not already installed
2. Create a GitHub account if you don't have one
3. Create a Vercel account (you can sign up with GitHub)

## Step 1: Initialize Git Repository
Open PowerShell in your project folder and run:

```powershell
cd "c:\Users\ZoomStore\Desktop\oufq"
git init
git add .
git commit -m "Initial commit: Arabic Business Management System"
```

## Step 2: Create GitHub Repository
1. Go to GitHub.com and create a new repository
2. Name it something like "oufq-business-management"
3. Don't initialize with README (we already have one)
4. Copy the repository URL

## Step 3: Push to GitHub
```powershell
git remote add origin https://github.com/YOUR_USERNAME/oufq-business-management.git
git branch -M main
git push -u origin main
```

## Step 4: Deploy to Vercel
1. Go to vercel.com and sign in
2. Click "New Project"
3. Import your GitHub repository
4. Vercel will automatically detect it's a static site
5. Click "Deploy"

## Step 5: Configure Custom Domain (Optional)
After deployment, you can:
1. Add a custom domain in Vercel dashboard
2. Configure DNS settings
3. Enable automatic HTTPS

## Environment Setup
No environment variables needed for this static site.

## Features Enabled
- ✅ Static file serving
- ✅ Automatic HTTPS
- ✅ Global CDN
- ✅ Automatic deployments on Git push
- ✅ Cache optimization
- ✅ Security headers

Your site will be available at: https://your-project-name.vercel.app
