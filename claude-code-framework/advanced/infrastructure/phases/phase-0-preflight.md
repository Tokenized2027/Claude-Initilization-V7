# Phase 0: Pre-Flight Assessment

> Before we touch anything, I need to know what we're working with.
> Show me the EXACT commands to run, then wait for my output before proceeding.

## About Me

<!-- CUSTOMIZE THIS SECTION — Replace with your own details -->
- Name: [YOUR NAME]
- Location: [YOUR COUNTRY] (timezone: [YOUR TIMEZONE, e.g., America/New_York])
- Technical background: [YOUR SKILLS — e.g., Next.js, React, Python, Docker]
- Current project: [YOUR PROJECT — brief description of what you're building]
- I am a vibe coder — I do NOT write or debug code myself. You write all code, I execute commands you give me.

## Collect System Info

Run these commands and show me the output:

1. `uname -a` — kernel version
2. `lsb_release -a` — Ubuntu version
3. `free -h` — RAM
4. `lsblk` — disk layout
5. `df -h` — disk usage
6. `ip addr` — network interfaces
7. `whoami && id` — current user and groups
8. `cat /etc/ssh/sshd_config | grep -iE "PasswordAuth|PubkeyAuth|PermitRoot"` — current SSH config
9. `timedatectl` — timezone and NTP status
10. `locale` — system locale
11. `docker --version 2>/dev/null || echo "Docker not installed"` — check if Docker is pre-installed

## Based on the Output, Tell Me

- Any concerns about disk space, RAM, or hardware
- Whether the Ubuntu version requires any command adjustments for later phases
- Whether Docker is already installed (and if so, what version)
- Whether swap is needed (if RAM ≤ 16GB, we'll configure a 4GB swap file)
- Whether timezone needs to be set (per the About Me section above)
- Whether locale needs to be set to en_US.UTF-8
- Recommended Docker data-root location if disk space is tight

## Then

Create the initial project structure:
```bash
mkdir -p ~/projects/infrastructure
cd ~/projects/infrastructure
git init
```

Create a STATUS.md:
```markdown
# Infrastructure Setup — Status

## Current Phase: Phase 0 — Pre-Flight
## Last Updated: [DATE]

## System Info
[Paste the collected system info here]

## Phases
- [ ] Phase 0: Pre-flight assessment
- [ ] Phase 1: Foundation (SSH, firewall, Tailscale, Docker, core services)
- [ ] Phase 2: Development environment
- [ ] Phase 3: Monitoring
- [ ] Phase 4: Automation
- [ ] Phase 5: Documentation & recovery
```

Git commit: `git add -A && git commit -m "phase 0: pre-flight assessment"`

**STOP HERE.** Tell me the assessment results and wait for my confirmation before Phase 1.
