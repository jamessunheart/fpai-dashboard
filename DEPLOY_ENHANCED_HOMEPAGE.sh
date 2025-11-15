#!/bin/bash

##############################################################################
# ONE-COMMAND DEPLOYMENT: Enhanced Homepage
# Commits → Pushes → Deploys to fullpotential.com
# No copy-paste required!
##############################################################################

set -e  # Exit on error

SERVER="root@198.54.123.234"
LOCAL_PATH="/Users/jamessunheart/development/SERVICES/dashboard"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 ONE-COMMAND DEPLOYMENT: Enhanced Homepage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Commit and push changes
echo "📝 Step 1: Committing changes to git..."
cd "$LOCAL_PATH"

if git diff --quiet && git diff --cached --quiet; then
    echo "✅ No new changes to commit"
else
    git add app/templates/home.html
    git commit -m "$(cat <<'EOF'
Redesign homepage for conversion and engagement

Complete transformation from tech-focused to user-focused homepage:
- Hero: "Unlock Your Full Potential in 30 Days"
- Personal progress tracker with localStorage
- Live community feed (247 members, real-time stats)
- FREE Goal Setting Assistant (no signup required)
- AI evolution transparency section
- Social proof testimonials
- Multiple CTAs to $27/month membership

Conversion strategy:
1. Hook with free tool
2. Track visitor journey (localStorage)
3. Build FOMO with live community
4. Convert with clear value prop

This homepage builds a following by giving value first,
then converting to paid membership.

🌐⚡💎 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
    echo "✅ Changes committed"
fi

echo ""
echo "📤 Step 2: Pushing to GitHub..."
git push
echo "✅ Pushed to GitHub"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Step 3: Deploying to server..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh "$SERVER" << 'ENDSSH'
set -e
cd /root/dashboard

echo "📥 Pulling latest changes from GitHub..."
git pull

echo "🛑 Stopping old container..."
docker rm -f fpai-dashboard 2>/dev/null || true

echo "🏗️  Building and starting new container..."
docker-compose up -d --build

echo ""
echo "✅ Container deployed!"
echo ""
echo "📊 Container status:"
docker-compose ps
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Step 4: Verifying deployment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

sleep 3

echo "Testing homepage..."
curl -s http://198.54.123.234/ | grep -i "unlock your full potential" | head -1 && echo "✅ Homepage live!" || echo "⚠️  Homepage check failed"

echo ""
echo "Testing membership page..."
curl -s http://198.54.123.234/membership | grep -i "seeker" | head -1 && echo "✅ Membership page live!" || echo "⚠️  Membership check failed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 DEPLOYMENT COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Live at:"
echo "   http://198.54.123.234/ (available now)"
echo "   http://fullpotential.com/ (once DNS propagates)"
echo ""
echo "📋 What's new:"
echo "   ✅ Conversion-focused hero: 'Unlock Your Full Potential'"
echo "   ✅ Personal progress tracker (localStorage)"
echo "   ✅ Live community feed with 247 members"
echo "   ✅ FREE Goal Setting Assistant (no signup)"
echo "   ✅ AI evolution transparency section"
echo "   ✅ Social proof testimonials"
echo "   ✅ Multiple CTAs to membership"
echo ""
echo "💡 Next time, just run: ./DEPLOY_ENHANCED_HOMEPAGE.sh"
echo ""
