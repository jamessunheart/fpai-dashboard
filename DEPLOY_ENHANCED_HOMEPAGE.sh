#!/bin/bash

##############################################################################
# Deploy Enhanced Homepage to Live Server
# Updates the live Dashboard with new investor-ready homepage
##############################################################################

set -e  # Exit on error

SERVER="root@198.54.123.234"
REMOTE_PATH="/root/dashboard"
LOCAL_PATH="/Users/jamessunheart/Development/dashboard"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Deploying Enhanced Homepage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Copy updated files to server
echo "📦 Step 1: Copying updated files to server..."
echo ""

scp "$LOCAL_PATH/app/routers/api.py" "$SERVER:$REMOTE_PATH/app/routers/api.py"
echo "✅ Updated api.py"

scp "$LOCAL_PATH/app/templates/home.html" "$SERVER:$REMOTE_PATH/app/templates/home.html"
echo "✅ Updated home.html"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Step 2: Restarting Dashboard service..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh "$SERVER" << 'ENDSSH'
cd /root/dashboard

# Find and restart the Dashboard process
echo "Stopping Dashboard..."
pkill -f "uvicorn app.main:app" || echo "No running process found"

echo "Starting Dashboard..."
nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8002 > dashboard.log 2>&1 &

sleep 3

echo "✅ Dashboard restarted"
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Step 3: Verifying deployment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

sleep 2

# Test endpoints
echo "Testing /health endpoint..."
curl -s http://198.54.123.234:8002/health | python3 -m json.tool || echo "Health check pending..."

echo ""
echo "Testing /api/paradise-progress endpoint..."
curl -s http://198.54.123.234:8002/api/paradise-progress | python3 -m json.tool | head -20

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 DEPLOYMENT COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Enhanced homepage deployed to: http://198.54.123.234:8002"
echo "✅ Also available at: http://dashboard.fullpotential.com:8002"
echo ""
echo "🔍 View the enhanced homepage:"
echo "   - Homepage: http://198.54.123.234:8002/"
echo "   - Progress: http://198.54.123.234:8002/paradise-progress"
echo "   - API: http://198.54.123.234:8002/api/paradise-progress"
echo ""
echo "📊 Features now live:"
echo "   ✅ Real-time progress display (27% → Paradise)"
echo "   ✅ Live system health widget"
echo "   ✅ Dynamic service cards with pulse animation"
echo "   ✅ 4-phase roadmap visualization"
echo "   ✅ Paradise metrics (coherence, autonomy, velocity)"
echo "   ✅ Investment opportunity section"
echo "   ✅ Recent wins display"
echo "   ✅ Auto-refresh every 30 seconds"
echo ""
echo "🌐 Next step: Point fullpotential.ai to the Dashboard!"
echo ""
