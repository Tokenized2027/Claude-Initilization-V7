# Mini PC Requirements

## Minimum Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 4 cores | 8 cores |
| **RAM** | 16 GB | 32 GB |
| **Storage** | 256 GB SSD | 512 GB NVMe |
| **Network** | Ethernet or WiFi | Ethernet (stable) |
| **OS** | Ubuntu 22.04 LTS | Ubuntu 24.04 LTS |

## Software Dependencies

| Software | Version | Purpose |
|----------|---------|---------|
| Node.js | 18+ (20 recommended) | MCP servers |
| Python | 3.10+ (3.12 recommended) | Orchestrator |
| Claude Code CLI | Latest | Agent execution |
| Git | 2.x | Version control |
| Tailscale | Latest (optional) | Remote access |

## Recommended Mini PC Models

**Budget ($150-300):**
- Beelink SER5 (Ryzen 5, 16GB, 500GB)
- Minisforum UM580 (Ryzen 7, 16GB, 512GB)

**Mid-range ($300-500):**
- Beelink SER7 (Ryzen 7, 32GB, 1TB)
- Intel NUC 12 Pro (i5, 16GB, 512GB)

**Performance ($500+):**
- Minisforum UM790 Pro (Ryzen 9, 32GB, 1TB)
- Intel NUC 13 Pro (i7, 32GB, 1TB)

## Network Requirements

- Stable internet (for Claude API calls)
- SSH access (for remote management)
- Port 8000 accessible (for orchestrator API, local or Tailscale)
- Outbound HTTPS (for api.anthropic.com)

## Power & Physical

- UPS recommended (prevents data corruption on power loss)
- Quiet operation (fanless or low-noise preferred for home/office)
- Low power consumption (15-45W typical for mini PCs)
- Can run 24/7 headless (no monitor needed after setup)

## Quick Setup After Unboxing

```bash
# 1. Install Ubuntu (if not pre-installed)
# 2. Connect to network
# 3. Enable SSH
sudo apt install openssh-server

# 4. Install Tailscale (optional, for remote access)
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# 5. Transfer source and run installer
scp -r multi-agent-system/ user@your-server:~/
ssh user@your-server "bash ~/multi-agent-system/deployment/install.sh"
# Installer copies system to ~/claude-multi-agent/

# 6. Done!
```

## Estimated Costs

| Item | Cost | Frequency |
|------|------|-----------|
| Mini PC | $200-500 | One-time |
| Electricity | $3-8/month | Monthly |
| Claude API | $30-100/month | Monthly |
| **Total Year 1** | **$600-1,800** | |
| **Monthly after** | **$33-108** | |
