# QUICK START — Read This First

Everything you need to go from unboxing to a working AI dev server.

---

## What You're Building

An always-on mini PC that you control three ways:

- **Telegram** (phone) — voice/text commands, push notifications
- **Claude Code CLI** (terminal) — heavy AI coding, autonomous builds
- **Cursor IDE** (laptop) — visual code browsing, small AI-assisted tweaks

---

## Step 1: Install Ubuntu on the Mini PC

**You need:** A USB drive (8GB+), your mini PC, a monitor + keyboard (temporary — just for install).

### Create the USB installer (on your laptop)

1. Download Ubuntu Server 24.04 LTS: https://ubuntu.com/download/server
2. Use balenaEtcher (https://etcher.balena.io) or `dd` to flash the ISO to your USB drive
3. Select the Ubuntu ISO, select your USB drive, and flash it
4. Wait ~5 minutes for it to finish

### Install Ubuntu

1. Plug the USB into the mini PC, connect monitor + keyboard
2. Power on -> press `F7` or `Del` or `F2` to enter boot menu (check your mini PC's manual)
3. Select the USB drive to boot from
4. Follow the Ubuntu installer:
   - Language: English
   - Keyboard: pick yours (US or Hebrew layout — you can have both)
   - Installation type: **Use entire disk** (this wipes the existing OS — that's what we want)
   - Your name: `[your name]`
   - Server name: `your-server` (or whatever you like)
   - Username: `[your username]`
   - Password: pick something strong
   - **Install OpenSSH server: YES** ← important!
   - Featured snaps: skip, don't select anything
5. Wait for install to finish (~10 minutes), then "Reboot Now"
6. Remove the USB when prompted

### First boot

1. Log in with your username/password on the monitor
2. Find your IP address:
   ```
   ip addr show | grep "inet " | grep -v 127.0.0.1
   ```
   Note the IP (something like `192.168.1.XX`)
3. **You can now disconnect the monitor and keyboard.** Everything from here is remote.

---

## Step 2: SSH In From Your Laptop

Open Terminal on your Mac:

```
ssh user@192.168.1.XX
```

Type `yes` to accept the fingerprint, enter your password. You're in.

---

## Step 3: Install Claude Code CLI

Run these on the mini PC (via SSH):

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g @anthropic-ai/claude-code
```

Test it:
```bash
claude --version
```

---

## Step 4: Run the Setup Prompt

This is where the magic happens. Claude Code becomes your sysadmin.

```bash
cd ~
claude
```

Now paste the entire contents of:
**`claude-code-framework/advanced/infrastructure/MINI_PC_SETUP_PROMPT.md`**

Claude Code will start with Phase 0 (inspecting your hardware) and walk you through:

- Phase 0: Pre-flight check
- Phase 1: Foundation (Docker, PostgreSQL, Redis, firewall, SSH keys)
- Phase 2: Services (Gitea, Nginx Proxy Manager, Portainer, API connectivity)
- Phase 3: Monitoring (Dozzle, Uptime Kuma, Telegram alerts)
- Phase 4: Automation (cron, backups, orchestrator deployment)
- Phase 4.5: Whisper service + Telegram command bot
- Phase 5: Recovery documentation

**Your job:** read what Claude Code proposes, confirm each phase, and fill in decisions when asked (passwords, API keys, etc.).

It stops between phases and waits for your "proceed" — you're always in control.

---

## Step 5: Pre-Setup Prep (Do These Before Step 4)

You'll need these values during setup. Prepare them now:

### Anthropic API Key
- Go to https://console.anthropic.com → API Keys → Create Key
- Save it somewhere safe — you'll paste it during Phase 1

### Telegram Bot
- Open Telegram, find `@BotFather`
- Send `/newbot`, follow the prompts, save the bot token
- Find `@userinfobot` to get your chat ID

### Telegram Bot Password
- Transfer `telegram-bot/generate-password-hash.py` to the mini PC
- Run: `python3 generate-password-hash.py`
- Pick a password, save the hash — you'll paste it during Phase 4.5

### Tailscale (Remote Access)
- Sign up at https://tailscale.com (free for personal use)
- You'll install it on both the mini PC and your laptop during Phase 1

---

## Step 6: Install Cursor on Your Laptop

After the mini PC setup is done:

1. Download Cursor: https://cursor.com
2. Install it, sign up for Pro ($20/month)
3. Open Cursor -> `Cmd+Shift+P` -> "Remote-SSH: Connect to Host"
4. Enter: `user@<mini-pc-ip>` (use the Tailscale IP for remote access)
5. Once connected: File -> Open Folder -> `~/Claude/` or `~/projects/`

Now you can see the files Claude Code created, browse the project structure, and make small AI-assisted edits with `Cmd+K`.

**Pro tip:** Open a terminal inside Cursor (`` Ctrl+` ``) and run `claude` there -- you get the visual editor AND Claude Code CLI side by side.

---

## After Setup: Your Daily Workflow

### From your phone (Telegram)
- Send a voice message: "how's the system doing?"
- Type: "submit a task to build the analytics dashboard"
- Get push notifications when agents finish or fail

### From your laptop (Cursor + Claude Code)
- Open Cursor, connect to mini PC
- Open terminal, run `claude`
- Tell it: "build me an analytics dashboard for my-app"
- Watch the files appear in Cursor as Claude Code creates them

### Quick checks (Telegram slash commands — free, no AI cost)
- `/health` — orchestrator status
- `/system` — CPU, RAM, disk
- `/spend` — budget tracking
- `/tasks` — what's running

---

## File Map (What's in This Zip)

```
YOU READ THESE:
  QUICK_START.md                    ← You are here
  START_HERE.md                     ← Overview of everything in the zip

CLAUDE CODE READS THESE (you paste into Claude Code):
  claude-code-framework/advanced/infrastructure/MINI_PC_SETUP_PROMPT.md
                                    ← THE setup guide. Paste into Claude Code.

DEPLOYED TO MINI PC (by Claude Code during setup):
  multi-agent-system/               ← Orchestrator + 14 AI agents
  telegram-bot/                     ← Telegram command bot
  whisper-service/                  ← Speech-to-text Docker container

REFERENCE (you don't need to read):
  project-contexts/                 <- Project context files
  templates/                        ← Code templates
  Everything else                   ← Architecture docs, changelogs, etc.
```

---

## Troubleshooting

**Can't SSH in:** Make sure you're on the same network, and that you selected "Install OpenSSH server" during Ubuntu install. If you forgot, plug the monitor back in and run `sudo apt install openssh-server`.

**Claude Code not installing:** Make sure Node.js installed correctly: `node --version` should show v18+. If not, retry the NodeSource install command.

**Setup prompt too long to paste:** Copy it to a file on the mini PC first (`nano ~/setup.md`, paste, save), then tell Claude Code to read it: "Read ~/setup.md and execute it phase by phase."

**Mini PC IP changed:** This is why we install Tailscale — it gives a stable IP that works from anywhere, even outside your home network.

**Something broke during setup:** Tell Claude Code what happened. It can diagnose and fix most issues. If truly stuck, re-run the current phase from scratch.
