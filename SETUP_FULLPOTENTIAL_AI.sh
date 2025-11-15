#!/bin/bash

##############################################################################
# Setup fullpotential.ai → Dashboard
# Makes the enhanced homepage accessible at https://fullpotential.ai
##############################################################################

cat << 'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 SETUP FULLPOTENTIAL.AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PART A: Update DNS (on 209.74.93.72 DNS panel)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Log into DNS management panel at 209.74.93.72
2. Find fullpotential.ai DNS records
3. Update A record:

   Type: A
   Name: @ (or fullpotential.ai)
   Value: 198.54.123.234
   TTL: 300

4. Save changes
5. Wait 5-10 minutes for DNS propagation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PART B: Setup Nginx + SSL on Server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ssh root@198.54.123.234

# Once connected, run these commands:

# 1. Install Nginx and Certbot
apt update
apt install -y nginx certbot python3-certbot-nginx

# 2. Create Nginx configuration
cat > /etc/nginx/sites-available/fullpotential.ai << 'NGINX'
server {
    listen 80;
    server_name fullpotential.ai www.fullpotential.ai;

    location / {
        proxy_pass http://localhost:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }
}
NGINX

# 3. Enable the site
ln -s /etc/nginx/sites-available/fullpotential.ai /etc/nginx/sites-enabled/

# 4. Test Nginx configuration
nginx -t

# 5. Reload Nginx
systemctl reload nginx

# 6. Get SSL certificate (automatic HTTPS setup)
certbot --nginx -d fullpotential.ai -d www.fullpotential.ai --non-interactive --agree-tos --email james@fullpotential.ai

# 7. Test auto-renewal
certbot renew --dry-run

# Done!
exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ VERIFY DEPLOYMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Test HTTP (should redirect to HTTPS)
curl -I http://fullpotential.ai

# Test HTTPS
curl -I https://fullpotential.ai

# Open in browser:
https://fullpotential.ai

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 SUCCESS!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your enhanced homepage is now live at:

  🌐 https://fullpotential.ai

Features:
  ✅ Professional domain
  ✅ SSL certificate (secure HTTPS)
  ✅ Auto-redirect HTTP → HTTPS
  ✅ Real-time progress metrics
  ✅ Live system visualization
  ✅ Investment opportunity section
  ✅ Auto-refresh every 30 seconds

Share with investors! 💼
Share with contributors! 🧑‍💻
Share with the world! 🌟

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
