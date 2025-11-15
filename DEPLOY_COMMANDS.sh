#!/bin/bash

##############################################################################
# Deploy Enhanced Homepage - Run these commands
##############################################################################

cat << 'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 DEPLOY ENHANCED HOMEPAGE TO SERVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Run these commands in your terminal:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 STEP 1: Copy updated files to server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

scp /Users/jamessunheart/Development/dashboard/app/routers/api.py root@198.54.123.234:/root/dashboard/app/routers/

scp /Users/jamessunheart/Development/dashboard/app/templates/home.html root@198.54.123.234:/root/dashboard/app/templates/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 STEP 2: Restart Dashboard on server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ssh root@198.54.123.234

# Once connected to server, run:
cd /root/dashboard
pkill -f "uvicorn app.main:app"
nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8002 > dashboard.log 2>&1 &
exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ STEP 3: Verify deployment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

curl http://198.54.123.234:8002/api/paradise-progress | python3 -m json.tool

# Open in browser:
# http://198.54.123.234:8002/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ After deployment, you'll see:
   ✅ 27% → Paradise (large dynamic display)
   ✅ Live system health (3/3 services online)
   ✅ Real-time service cards with animations
   ✅ 4-phase roadmap with progress bars
   ✅ Investment opportunity section
   ✅ Recent wins
   ✅ Auto-refresh every 30 seconds

🌐 Next: Point fullpotential.ai to the Dashboard

EOF
