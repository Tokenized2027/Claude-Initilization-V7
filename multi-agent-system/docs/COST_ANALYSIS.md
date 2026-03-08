# Cost Analysis & Budget Recommendations

**Last Updated:** [Update after 1 month of operation]  
**Analysis Period:** [Date range]  
**Total Tasks Executed:** [Number]  
**Total Spend:** $[Amount]  

> **v3.2 Note:** The `/spend` endpoint now reports `actual_daily_spend` and
> `actual_vs_estimated_ratio` when token usage data is available from Claude CLI.
> Use these to fill in actual costs below instead of manual tracking.

---

## Executive Summary

Fill this out after 1 month of operation with actual data:

- **Average cost per task:** $[X]
- **Most expensive task type:** [Type] at $[X] average
- **Most efficient task type:** [Type] at $[X] average
- **Recommended monthly budget:** $[X] based on usage patterns

---

## Cost Per Task Type

Track actual costs for each task type. Update this table weekly.

| Task Type | Count | Total Cost | Avg Cost | Min | Max | Notes |
|-----------|-------|------------|----------|-----|-----|-------|
| Content - Tweet | 0 | $0.00 | $0.00 | - | - | Simple content generation |
| Content - Documentation | 0 | $0.00 | $0.00 | - | - | Technical writing |
| Content - Governance Proposal | 0 | $0.00 | $0.00 | - | - | Governance docs |
| Coding - Simple Component | 0 | $0.00 | $0.00 | - | - | Single React component |
| Coding - Dashboard | 0 | $0.00 | $0.00 | - | - | Full dashboard build |
| Coding - API Endpoint | 0 | $0.00 | $0.00 | - | - | Backend API work |
| Coding - Integration | 0 | $0.00 | $0.00 | - | - | Complex 3rd party integration |
| Coding - Bug Fix | 0 | $0.00 | $0.00 | - | - | Debugging existing code |
| Support - Technical | 0 | $0.00 | $0.00 | - | - | User support responses |
| Support - Documentation Lookup | 0 | $0.00 | $0.00 | - | - | FAQ/guide searches |

---

## Daily Spend Patterns

Track spend by day of week. Update after 1 month.

| Day | Avg Spend | Peak Spend | Tasks | Notes |
|-----|-----------|------------|-------|-------|
| Monday | $0.00 | $0.00 | 0 | |
| Tuesday | $0.00 | $0.00 | 0 | |
| Wednesday | $0.00 | $0.00 | 0 | |
| Thursday | $0.00 | $0.00 | 0 | |
| Friday | $0.00 | $0.00 | 0 | |
| Saturday | $0.00 | $0.00 | 0 | |
| Sunday | $0.00 | $0.00 | 0 | |

**Insights:**
- Which days are heaviest?
- Weekend vs weekday patterns?
- Should budget be higher certain days?

---

## Project-Level Analysis

Track spend per project over time.

| Project | Total Spend | Task Count | Avg per Task | Status | Budget Used % |
|---------|-------------|------------|--------------|--------|---------------|
| my-analytics | $0.00 | 0 | $0.00 | Active | 0% |
| test-project | $0.00 | 0 | $0.00 | Complete | 0% |

**Observations:**
- Which projects are most expensive?
- Are costs predictable per project type?
- Should project budgets vary by type?

---

## Agent Cost Analysis

Which agents are most/least expensive?

| Agent | Usage Count | Total Cost | Avg Cost | Notes |
|-------|-------------|------------|----------|-------|
| Frontend Developer | 0 | $0.00 | $0.00 | |
| Backend Developer | 0 | $0.00 | $0.00 | |
| System Architect | 0 | $0.00 | $0.00 | |
| Product Manager | 0 | $0.00 | $0.00 | |
| Content Creator | 0 | $0.00 | $0.00 | |
| Designer | 0 | $0.00 | $0.00 | |
| System Tester | 0 | $0.00 | $0.00 | |
| DevOps Engineer | 0 | $0.00 | $0.00 | |
| API Architect | 0 | $0.00 | $0.00 | |
| Security Auditor | 0 | $0.00 | $0.00 | |

**Insights:**
- Are some agents consistently more expensive?
- Should timeout settings vary by agent?
- Which agents need prompt optimization?

---

## Handoff Cost Analysis

Does auto-handoff increase costs significantly?

| Metric | Value | Notes |
|--------|-------|-------|
| Tasks with handoffs | 0 | |
| Average handoffs per task | 0.0 | |
| Tasks without handoffs | 0 | |
| Avg cost with handoffs | $0.00 | |
| Avg cost without handoffs | $0.00 | |
| Cost premium for handoffs | 0% | |

**Conclusion:**
- Is auto-handoff worth the extra cost?
- Should some workflows stay manual?

---

## Budget Recommendations

Based on actual usage, update budget settings:

### Current Settings
```bash
DAILY_BUDGET_USD=50.0
PROJECT_BUDGET_USD=25.0
ESTIMATED_COST_PER_AGENT_RUN=2.50
```

### Recommended Settings
```bash
DAILY_BUDGET_USD=[Update based on avg daily spend * 1.5]
PROJECT_BUDGET_USD=[Update based on avg project cost * 1.3]
ESTIMATED_COST_PER_AGENT_RUN=[Update based on actual avg]
```

**Reasoning:**
- Set daily budget at 1.5x average (buffer for peak days)
- Set project budget at 1.3x average project cost
- Use actual average for cost estimation (improves accuracy)

---

## Cost Optimization Opportunities

### High-Cost Tasks
Identify tasks that consistently exceed budget expectations:

1. **[Task Type]** - $[X] average
   - **Why expensive:** [Reason]
   - **Optimization:** [Strategy]
   - **Expected savings:** [Amount/percentage]

2. **[Task Type]** - $[X] average
   - **Why expensive:** [Reason]
   - **Optimization:** [Strategy]
   - **Expected savings:** [Amount/percentage]

### Agent Prompt Optimization
Which agents need prompt tuning to reduce token usage?

1. **[Agent Name]**
   - **Current avg cost:** $[X]
   - **Issue:** [Verbose output, unnecessary iterations, etc.]
   - **Fix:** [Prompt adjustment]
   - **Target cost:** $[X]

### Handoff Optimization
Can any handoff chains be shortened?

1. **[Workflow]**
   - **Current chain:** [A → B → C → D]
   - **Optimization:** [A → D directly, skip intermediaries]
   - **Expected savings:** [Amount]

---

## Monthly Cost Projections

Based on current usage patterns:

| Usage Level | Tasks/Day | Est. Monthly Cost | Confidence |
|-------------|-----------|-------------------|------------|
| Light (Current) | 5-10 | $[X] | [High/Med/Low] |
| Medium (Scaled) | 15-25 | $[X] | [High/Med/Low] |
| Heavy (Future) | 30-50 | $[X] | [High/Med/Low] |

**Assumptions:**
- [List key assumptions used in projections]

---

## Budget Alerts & Thresholds

Recommended alerting thresholds:

| Alert Level | Daily Spend | Action |
|-------------|-------------|--------|
| Info | 50% of budget | Log only |
| Warning | 75% of budget | Email notification |
| Critical | 90% of budget | Immediate review required |
| Emergency | 100% of budget | Auto-blocks new tasks |

**Current settings:**
- Budget enforcement: ✅ Enabled at 100%
- Monitoring: [Describe your monitoring setup]

---

## Actual vs Estimated Costs

How accurate are our estimates?

| Period | Estimated Cost | Actual Cost | Variance | Accuracy |
|--------|----------------|-------------|----------|----------|
| Week 1 | $[X] | $[X] | [+/-X%] | [X%] |
| Week 2 | $[X] | $[X] | [+/-X%] | [X%] |
| Week 3 | $[X] | $[X] | [+/-X%] | [X%] |
| Week 4 | $[X] | $[X] | [+/-X%] | [X%] |

**Trend:**
- Are estimates getting more accurate over time?
- Should ESTIMATED_COST_PER_AGENT_RUN be adjusted?

---

## Special Cases

### Unusually Expensive Tasks

Document tasks that cost significantly more than average:

1. **Task:** [Description]
   - **Date:** [Date]
   - **Cost:** $[X]
   - **Why expensive:** [Long handoff chain, complex integration, etc.]
   - **Was it worth it:** [Yes/No]
   - **Lessons learned:** [What to do differently]

### Budget Exceptions

Times when budget limits were manually overridden:

1. **Date:** [Date]
   - **Project:** [Name]
   - **Override reason:** [Urgent deadline, critical feature, etc.]
   - **Extra cost:** $[X]
   - **Outcome:** [Worth it? Avoidable in future?]

---

## Action Items

Based on this analysis:

**Immediate (This Week):**
- [ ] Adjust ESTIMATED_COST_PER_AGENT_RUN to $[X]
- [ ] Increase/decrease DAILY_BUDGET_USD to $[X]
- [ ] Optimize [Agent Name] prompt to reduce verbosity

**Short-term (This Month):**
- [ ] Implement cost alerts at 75% threshold
- [ ] Create task-specific cost estimates
- [ ] Document workflow optimization for [expensive task type]

**Long-term (Next Quarter):**
- [ ] Evaluate if auto-handoff ROI is positive
- [ ] Consider tiered budgets per project type
- [ ] Build cost prediction model based on task description

---

## Appendix: Data Collection

### How to Collect Cost Data

**Daily:**
```bash
# Export spend data
curl -H "X-API-Key: YOUR_KEY" http://your-server:8000/spend > spend-$(date +%Y%m%d).json
```

**Weekly:**
```bash
# Export all project data
curl http://your-server:8000/projects > projects-$(date +%Y%m%d).json
```

**Monthly:**
```bash
# Combine data for analysis
jq -s '.' spend-*.json > monthly-spend-analysis.json
```

### Useful Queries

**Average cost per task type:**
```bash
# From spend ledger and task logs
# Calculate: total_cost / task_count per type
```

**Most expensive day:**
```bash
jq -r '.daily | to_entries | max_by(.value) | .key' _spend_ledger.json
```

**Project with highest spend:**
```bash
jq -r '.projects | to_entries | max_by(.value) | .key' _spend_ledger.json
```

---

**Note:** This template should be filled out after 1 month of operation with real data. Update weekly for best insights.
