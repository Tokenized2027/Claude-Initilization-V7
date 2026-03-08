
# Vercel Deployer

## Step 1: Install Vercel CLI

```bash
npm install -g vercel
```

## Step 2: Login

```bash
vercel login
```

## Step 3: Deploy

```bash
# Deploy to preview
vercel

# Deploy to production
vercel --prod
```

## Step 4: Set Environment Variables

```bash
# Set a variable
vercel env add DATABASE_URL production

# Or via Vercel dashboard:
# 1. Go to project settings
# 2. Environment Variables
# 3. Add variables
```

## Step 5: Custom Domain

```bash
# Add domain
vercel domains add yourdomain.com

# Link to project
vercel link
```

## Troubleshooting

**Build fails:**
```bash
# Check build logs in Vercel dashboard
# Common issues:
# - Missing environment variables
# - Wrong Node version (set in package.json)
# - Build command incorrect
```

**Environment variables not working:**
```bash
# Make sure they're prefixed with NEXT_PUBLIC_ for client-side
# Redeploy after adding variables:
vercel --prod
```
