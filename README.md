# PR Dashboard - GitHub + Netlify Deployment Guide

## 🚀 Deploy Your PowerBI Dashboard to GitHub + Netlify

This guide will help you deploy your PR Dashboard as a static site using GitHub for version control and Netlify for hosting.

## 📋 Prerequisites

- GitHub account
- Netlify account (free tier available)
- Supabase account (free tier available)

## 🗂️ Project Structure

```
pr-dashboard/
├── 📄 index.html              # Main dashboard (PowerBI replica)
├── 📄 admin.html              # Admin interface for uploads
├── 📄 package.json            # Project configuration
├── 📄 netlify.toml           # Netlify configuration
├── 📄 .env.example           # Environment variables template
├── 📄 README.md              # This deployment guide
├── 📁 netlify/
│   └── 📁 functions/
│       ├── 📄 upload.js      # Serverless function for file uploads
│       └── 📄 package.json   # Function dependencies
└── 📁 database/
    └── 📄 schema.sql         # Supabase database setup
```

## 🏗️ Step-by-Step Deployment

### Step 1: Set Up Supabase Database

1. **Create Supabase Project:**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Choose organization and enter project details
   - Wait for project creation (2-3 minutes)

2. **Run Database Schema:**
   - Go to your Supabase dashboard
   - Navigate to **SQL Editor**
   - Copy the contents from `database/schema.sql`
   - Paste and execute the SQL
   - Verify tables are created in **Table Editor**

3. **Get API Credentials:**
   - Go to **Settings → API**
   - Copy your **Project URL**
   - Copy your **anon public** key
   - Copy your **service_role** key (keep secret!)

### Step 2: Prepare GitHub Repository

1. **Create GitHub Repository:**
   ```bash
   # Create new repository on GitHub (public or private)
   # Clone to your local machine
   git clone https://github.com/yourusername/pr-dashboard.git
   cd pr-dashboard
   ```

2. **Add Project Files:**
   - Copy all files from the netlify-version folder to your repository
   - Ensure the structure matches the project structure above

3. **Commit and Push:**
   ```bash
   git add .
   git commit -m "Initial commit: PR Dashboard for Netlify"
   git push origin main
   ```

### Step 3: Deploy to Netlify

1. **Connect Repository:**
   - Log in to [netlify.com](https://netlify.com)
   - Click "New site from Git"
   - Choose "GitHub" and authorize access
   - Select your `pr-dashboard` repository

2. **Configure Build Settings:**
   - **Branch to deploy:** `main`
   - **Build command:** `npm run build`
   - **Publish directory:** `.` (root)
   - Click "Deploy site"

3. **Set Environment Variables:**
   - Go to **Site settings → Environment variables**
   - Add these variables:
     ```
     VITE_SUPABASE_URL = https://your-project.supabase.co
     VITE_SUPABASE_ANON_KEY = your_anon_key_here
     SUPABASE_URL = https://your-project.supabase.co
     SUPABASE_ANON_KEY = your_anon_key_here
     SUPABASE_SERVICE_KEY = your_service_role_key_here
     JWT_SECRET = your_random_jwt_secret_here
     ```

4. **Redeploy Site:**
   - Go to **Deploys** tab
   - Click "Trigger deploy" → "Deploy site"
   - Wait for deployment to complete

### Step 4: Configure Custom Domain (Optional)

1. **Add Custom Domain:**
   - Go to **Site settings → Domain management**
   - Click "Add custom domain"
   - Enter your domain (e.g., `dashboard.yourcompany.com`)
   - Follow DNS configuration instructions

2. **Enable HTTPS:**
   - Netlify automatically provisions SSL certificates
   - HTTPS will be enabled within 24 hours

## 🔧 Configuration Details

### Environment Variables Explained

| Variable | Purpose | Example |
|----------|---------|---------|
| `VITE_SUPABASE_URL` | Supabase project URL (public) | `https://abc123.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | Public API key (public) | `eyJhbG...` |
| `SUPABASE_SERVICE_KEY` | Admin API key (secret) | `eyJhbG...` |
| `JWT_SECRET` | Token signing secret | Random 32+ char string |

### Netlify Functions

The admin upload functionality uses Netlify Functions (serverless):
- **File:** `netlify/functions/upload.js`
- **Endpoint:** `/.netlify/functions/upload`
- **Purpose:** Process Excel uploads and save to Supabase

## 📱 How to Use Your Deployed Dashboard

### For End Users (Dashboard Viewing):
1. **Access Dashboard:** Visit your Netlify site URL
2. **View Real-time Data:** All charts update automatically
3. **Mobile Access:** Dashboard works on phones/tablets
4. **Bookmark:** Add to favorites for easy access

### For Administrators (Data Upload):
1. **Access Admin Panel:** Visit `yoursite.netlify.app/admin.html`
2. **Upload Excel Files:** Drag and drop your weekly files
3. **Select Week Category:** Choose THIS_WEEK, PREVIOUS_WEEK, etc.
4. **Monitor Progress:** Watch real-time upload progress
5. **Verify Results:** Check dashboard updates immediately

## 🔄 Regular Update Workflow

### Weekly Data Updates:
1. **Generate Excel file** from your PR system
2. **Visit admin panel** at your Netlify URL
3. **Upload new file** with correct week category
4. **Dashboard updates** automatically
5. **Previous data preserved** in database

### Code Updates:
1. **Make changes** to your local repository
2. **Commit and push** to GitHub
3. **Netlify automatically rebuilds** and deploys
4. **Site updates** within 1-2 minutes

## 🛡️ Security Features

### Netlify Security:
- **HTTPS enforced** - All traffic encrypted
- **DDoS protection** - Built-in attack prevention
- **Environment variables** - Secure credential storage
- **Function isolation** - Serverless security

### Supabase Security:
- **Row Level Security** - Optional database protection
- **API rate limiting** - Prevents abuse
- **Automatic backups** - Daily database snapshots
- **Audit logging** - Complete activity tracking

## 📊 Performance & Scaling

### Expected Performance:
- **Dashboard load time:** < 2 seconds
- **File upload:** 4,000 records in ~5-10 seconds
- **Real-time updates:** Immediate
- **Concurrent users:** 100+ supported

### Scaling Options:
- **Netlify Pro:** Higher bandwidth and build minutes
- **Supabase Pro:** More database connections and storage
- **CDN:** Global content delivery included
- **Functions:** Automatic scaling included

## 🔧 Troubleshooting

### Common Issues:

**Dashboard not loading:**
- Check Supabase environment variables in Netlify
- Verify database schema is properly created
- Check browser console for errors

**Upload failing:**
- Ensure Excel file has correct structure
- Check Netlify function logs in dashboard
- Verify Supabase service key permissions

**Charts not displaying:**
- Clear browser cache and reload
- Check network connectivity
- Verify data exists in Supabase

### Debug Steps:
1. **Check Netlify Deploy Logs** - Site overview → Production deploys
2. **Monitor Function Logs** - Functions tab in Netlify dashboard
3. **Inspect Supabase Logs** - Logs section in Supabase dashboard
4. **Browser Developer Tools** - Console tab for JavaScript errors

## 💰 Cost Breakdown

### Free Tier Limits:
- **Netlify:** 300 build minutes/month, 100GB bandwidth
- **Supabase:** 500MB database, 2GB bandwidth
- **GitHub:** Unlimited public repos

### Typical Costs (if exceeded):
- **Netlify Pro:** $19/month - Higher limits
- **Supabase Pro:** $25/month - Production features
- **Total:** $0-44/month depending on usage

## 🚀 Production Checklist

Before going live:
- [ ] Database schema deployed to Supabase
- [ ] All environment variables configured
- [ ] Test upload with sample Excel file
- [ ] Verify all charts display correctly
- [ ] Set up custom domain (optional)
- [ ] Configure team access to Netlify/Supabase
- [ ] Document admin procedures for staff
- [ ] Test on mobile devices
- [ ] Set up monitoring/alerts (optional)

## 📞 Support Resources

### Documentation:
- [Netlify Docs](https://docs.netlify.com/)
- [Supabase Docs](https://supabase.com/docs)
- [GitHub Actions](https://docs.github.com/en/actions)

### Community:
- [Netlify Community](https://community.netlify.com/)
- [Supabase Discord](https://discord.supabase.com/)
- [Stack Overflow](https://stackoverflow.com/)

---

## 🎉 Your Dashboard is Now Live!

After completing these steps, you'll have:
- ✅ **Professional web dashboard** accessible anywhere
- ✅ **Automatic deployments** from GitHub changes
- ✅ **Secure data management** with Supabase
- ✅ **Excel upload capability** for regular updates
- ✅ **No server maintenance** required
- ✅ **Scalable infrastructure** for growth
- ✅ **Cost-effective solution** with free tiers

Your PowerBI dashboard is now a modern, cloud-native web application!
