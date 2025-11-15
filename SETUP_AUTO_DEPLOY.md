# 🚀 AUTO-DEPLOY SETUP

Your dashboard now auto-deploys on every `git push`!

## One-Time Setup (2 minutes)

### Step 1: Add GitHub Secrets

Go to your GitHub repo: https://github.com/jamessunheart/dashboard/settings/secrets/actions

Click **"New repository secret"** and add these 3 secrets:

1. **SERVER_HOST**
   - Value: `198.54.123.234`

2. **SERVER_USER**
   - Value: `root`

3. **SERVER_PASSWORD**
   - Value: `[your server root password]`

### Step 2: Push this workflow

```bash
cd /Users/jamessunheart/development/SERVICES/dashboard
git add .github/workflows/deploy.yml
git add SETUP_AUTO_DEPLOY.md
git commit -m "Add GitHub Actions auto-deploy"
git push
```

### Step 3: Deploy the homepage (first time)

```bash
git add app/templates/home.html
git commit -m "Enhanced conversion-focused homepage"
git push
```

**That's it!** GitHub Actions will automatically deploy to your server.

---

## 🎉 From Now On

Every time you (or Claude) push code:

1. ✅ GitHub Actions triggers automatically
2. ✅ SSHs to your server
3. ✅ Pulls latest code
4. ✅ Rebuilds Docker container
5. ✅ Verifies deployment

**You never have to manually deploy again!**

---

## View Deployment Status

Watch deployments here: https://github.com/jamessunheart/dashboard/actions

---

## Security Note

**IMPORTANT:** After setting up the secrets, change your server root password:

```bash
ssh root@198.54.123.234
passwd
```

Then update the `SERVER_PASSWORD` secret in GitHub.
