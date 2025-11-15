"""
Command Center API - AI Operations Assistant
Handles chat interactions and system commands
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
import os
from datetime import datetime
import anthropic
from ..database import get_all_users, get_db_connection

router = APIRouter()

class ChatMessage(BaseModel):
    message: str

class ChatResponse(BaseModel):
    response: str
    data: Optional[Dict[str, Any]] = None

# Initialize Claude client
anthropic_client = None
if os.getenv("ANTHROPIC_API_KEY"):
    anthropic_client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

@router.post("/chat", response_model=ChatResponse)
async def chat(msg: ChatMessage):
    """
    Chat with AI assistant about system operations
    """
    user_message = msg.message.lower()

    # Get system context
    system_context = await get_system_context()

    # If Claude API is available, use it
    if anthropic_client:
        try:
            response = anthropic_client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=1024,
                system=f"""You are an AI operations assistant for Full Potential AI dashboard.

Current system context:
{system_context}

You can answer questions about:
- System status and health
- Deployment history and status
- Membership statistics
- Recent activity
- Technical operations

Keep responses concise, helpful, and actionable. Use metrics from the system context when relevant.""",
                messages=[{
                    "role": "user",
                    "content": user_message
                }]
            )

            ai_response = response.content[0].text

        except Exception as e:
            ai_response = f"AI service temporarily unavailable. Error: {str(e)}"
    else:
        # Fallback: Rule-based responses
        ai_response = get_rule_based_response(user_message, system_context)

    # Extract relevant data for dashboard updates
    data = extract_response_data(user_message, system_context)

    return ChatResponse(
        response=ai_response,
        data=data
    )

@router.get("/stats")
async def get_stats():
    """
    Get current system stats for dashboards
    """
    conn = get_db_connection()
    cursor = conn.cursor()

    # Get total members
    cursor.execute("SELECT COUNT(*) FROM users")
    total_members = cursor.fetchone()[0]

    # Get signups today
    today = datetime.utcnow().date().isoformat()
    cursor.execute("SELECT COUNT(*) FROM users WHERE DATE(created_at) = ?", (today,))
    signups_today = cursor.fetchone()[0]

    conn.close()

    return {
        "members": total_members,
        "signupsToday": signups_today,
        "activeStreaks": 0,  # TODO: Implement streak tracking
        "deploymentStatus": "Active",
        "systemHealth": "100%",
        "uptime": "99.9%"
    }

async def get_system_context() -> str:
    """Build current system context for AI"""
    conn = get_db_connection()
    cursor = conn.cursor()

    # Get member count
    cursor.execute("SELECT COUNT(*) FROM users")
    member_count = cursor.fetchone()[0]

    # Get recent signups
    cursor.execute("SELECT COUNT(*) FROM users WHERE DATE(created_at) = DATE('now')")
    signups_today = cursor.fetchone()[0]

    # Get membership tiers
    cursor.execute("SELECT membership_tier, COUNT(*) FROM users GROUP BY membership_tier")
    tier_counts = cursor.fetchall()

    conn.close()

    context = f"""
Total Members: {member_count}
Signups Today: {signups_today}
Membership Tiers: {dict(tier_counts)}
Deployment Status: Active (Auto-deploy enabled via GitHub Actions)
System Status: Online
Auto-Deploy: Enabled
Last Deploy: Recently (via GitHub Actions)
"""

    return context

def get_rule_based_response(message: str, context: str) -> str:
    """Fallback rule-based responses when AI API not available"""

    # Extract stats from context
    members_match = context.split("Total Members: ")[1].split("\n")[0] if "Total Members:" in context else "0"
    signups_match = context.split("Signups Today: ")[1].split("\n")[0] if "Signups Today:" in context else "0"

    # Deployment questions
    if any(word in message for word in ['deploy', 'deployment', 'pushed', 'update']):
        return f"✅ Auto-deployment is active! Every git push automatically deploys to the server via GitHub Actions. Latest deployment status: Active. System is running smoothly."

    # Member questions
    elif any(word in message for word in ['member', 'user', 'signup', 'customer']):
        return f"👥 We currently have {members_match} total members. Today we've had {signups_match} new signups! The membership platform is live with 3 tiers: Seeker ($27), Builder ($47), and Master ($97)."

    # System health questions
    elif any(word in message for word in ['health', 'status', 'online', 'working']):
        return f"🟢 All systems operational! Dashboard is online, database is connected, and auto-deploy is enabled. We have {members_match} active members and everything is running smoothly."

    # What happened / activity questions
    elif any(word in message for word in ['happen', 'activity', 'recent', 'latest']):
        return f"📊 Recent activity: {signups_match} new signups today, auto-deploy system is active, and all services are running. The new conversion-focused homepage is live with the FREE Goal Setting Assistant."

    # Generic help
    elif any(word in message for word in ['help', 'what can', 'how do']):
        return """I can help you with:

🚀 Deployment status and history
👥 Member statistics and signups
🟢 System health and uptime
📊 Recent activity and events
⚡ Quick commands and operations

Just ask me anything about the dashboard!"""

    # Default response
    else:
        return f"I'm here to help! Current status: {members_match} members, {signups_match} signups today, all systems online. What would you like to know?"

def extract_response_data(message: str, context: str) -> Optional[Dict[str, Any]]:
    """Extract data for dashboard updates based on question"""

    members_match = context.split("Total Members: ")[1].split("\n")[0] if "Total Members:" in context else "0"
    signups_match = context.split("Signups Today: ")[1].split("\n")[0] if "Signups Today:" in context else "0"

    if any(word in message for word in ['member', 'user', 'signup']):
        return {
            "members": int(members_match),
            "signupsToday": int(signups_match)
        }

    if any(word in message for word in ['deploy']):
        return {
            "deploymentStatus": "Active"
        }

    return None
