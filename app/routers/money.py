"""
Money/Treasury Dashboard Router
Real-time financial tracking for Full Potential AI
"""
from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
from datetime import datetime
import json

router = APIRouter()

# Treasury data file
TREASURY_FILE = Path("/Users/jamessunheart/Development/docs/coordination/treasury.json")

# Templates
templates_path = Path(__file__).parent.parent / "templates"
templates = Jinja2Templates(directory=str(templates_path))


class TreasuryTracker:
    def __init__(self):
        self.load_data()

    def load_data(self):
        """Load or initialize treasury data"""
        if TREASURY_FILE.exists():
            with open(TREASURY_FILE) as f:
                self.data = json.load(f)
        else:
            self.data = {
                "initialized": datetime.now().isoformat(),
                "treasury_balance": 0,
                "costs": {
                    "claude_api": {
                        "total": 0,
                        "this_month": 0,
                        "per_session": 0.02,  # Estimated per session
                        "sessions_run": 37
                    },
                    "server": {
                        "total": 60,  # $5/month for VPS
                        "monthly": 5
                    },
                    "domains": {
                        "total": 12,
                        "annual": 12
                    }
                },
                "revenue": {
                    "church_guidance": {
                        "total": 0,
                        "potential_monthly": 500,  # Estimated
                        "clients": 0
                    },
                    "i_match": {
                        "total": 0,
                        "potential_monthly": 1000,  # Marketplace fees
                        "transactions": 0
                    },
                    "white_rock": {
                        "total": 0,
                        "potential_monthly": 300,
                        "clients": 0
                    }
                },
                "investments": {
                    "ai_development": 0,
                    "infrastructure": 72,  # Server + domains
                    "marketing": 0
                },
                "projections": {
                    "monthly_burn": 5,  # Server cost
                    "projected_revenue_m1": 100,
                    "projected_revenue_m3": 500,
                    "projected_revenue_m6": 2000
                }
            }
            self.save_data()

    def save_data(self):
        """Save treasury data"""
        TREASURY_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(TREASURY_FILE, 'w') as f:
            json.dump(self.data, f, indent=2)

    def calculate_metrics(self):
        """Calculate financial metrics"""
        # Total costs
        total_costs = sum(
            cost.get('total', 0)
            for cost in self.data['costs'].values()
        )

        # Total revenue
        total_revenue = sum(
            rev.get('total', 0)
            for rev in self.data['revenue'].values()
        )

        # Potential monthly revenue
        potential_monthly = sum(
            rev.get('potential_monthly', 0)
            for rev in self.data['revenue'].values()
        )

        # Current burn rate
        monthly_burn = self.data['projections']['monthly_burn']

        # Runway (if we had funding)
        treasury = self.data.get('treasury_balance', 0)
        runway_months = treasury / monthly_burn if monthly_burn > 0 else float('inf')

        # ROI calculation
        total_investment = sum(self.data['investments'].values())
        roi = ((total_revenue - total_costs) / total_investment * 100) if total_investment > 0 else 0

        # Claude API costs
        claude_sessions = self.data['costs']['claude_api']['sessions_run']
        claude_cost = claude_sessions * self.data['costs']['claude_api']['per_session']

        return {
            'total_costs': total_costs + claude_cost,
            'total_revenue': total_revenue,
            'net_position': total_revenue - total_costs - claude_cost,
            'potential_monthly': potential_monthly,
            'monthly_burn': monthly_burn,
            'runway_months': runway_months,
            'roi': roi,
            'claude_cost': claude_cost,
            'breakeven_clients': monthly_burn / (potential_monthly / 10) if potential_monthly > 0 else 0
        }


tracker = TreasuryTracker()


@router.get("/dashboard/money", response_class=HTMLResponse)
async def money_dashboard(request: Request):
    """Treasury dashboard page"""
    return templates.TemplateResponse("money.html", {
        "request": request,
        "title": "Treasury Dashboard - Full Potential AI"
    })


@router.get("/api/treasury")
async def get_treasury():
    """Get treasury data API"""
    metrics = tracker.calculate_metrics()

    return JSONResponse({
        'costs': tracker.data['costs'],
        'revenue': tracker.data['revenue'],
        'investments': tracker.data['investments'],
        'projections': tracker.data['projections'],
        'metrics': metrics,
        'timestamp': datetime.now().isoformat()
    })
