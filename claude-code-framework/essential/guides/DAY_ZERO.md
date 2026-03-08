# Day Zero — Before You Touch Anything Else

> **Who this is for:** You just bought a mini PC. You've never SSH'd into anything. You don't know what a "container" is. This page gets you from zero to ready-to-paste-the-setup-prompt.
>
> **Time required:** 30-60 minutes of reading. You don't need to memorize any of this — it's a reference you come back to.

---

## What You Need Before Starting

### On Your Laptop/Main Computer

| Thing | Where to Get It | Why |
|-------|----------------|-----|
| A terminal app | **Mac:** Terminal (built in) or iTerm2. **Windows:** Windows Terminal (free from Microsoft Store) | This is how you'll talk to the mini PC remotely |
| Claude Pro or Teams subscription | claude.ai | For the 5 agent Claude Projects (planning, not coding) |
| Anthropic API key | console.anthropic.com → API Keys | For Claude Code CLI on the mini PC (actual coding) |
| A text editor | VS Code (free), Cursor, or even Notepad | For viewing/editing files on your laptop when needed |

### On the Mini PC

| Thing | Details |
|-------|---------|
| Ubuntu installed | 24.04 LTS recommended. Some mini PCs ship with it pre-installed |
| Ethernet cable connected | Plugged into your router. WiFi works but ethernet is more reliable for a server |
| Monitor + keyboard | Only needed for initial setup. After Tailscale is configured, you go "headless" (no monitor) |
| Your WiFi/network password | In case you need to configure networking |

---

## Concepts in Plain English

### The Terminal

The terminal is a text-based way to control a computer. Instead of clicking icons, you type commands. It looks like this:

```
user@your-server:~$ _
```

That's the **prompt** — it's waiting for you to type something. The `~` means you're in your home directory. The `$` means you're a regular user (not admin).

When this guide or Claude Code tells you to "run a command," it means: type it into the terminal and press Enter.

### SSH (Secure Shell)

SSH is how you control your mini PC from your laptop without plugging in a monitor. Think of it as a remote terminal window.

**How it works:**
1. Your mini PC is running and connected to your network
2. From your laptop's terminal, you type: `ssh youruser@192.168.1.XX` (the mini PC's local IP address)
3. You enter your password
4. Now your terminal **is** the mini PC — every command runs there, not on your laptop
5. Type `exit` to disconnect

**Later**, we set up Tailscale so you can do this from anywhere in the world (coffee shop, phone, etc.), not just your home network.

**SSH keys** are like a digital badge that lets you connect without typing a password every time. The setup prompt walks you through creating one — it's just two commands.

### Docker

Docker is like a shipping container for software. Instead of installing PostgreSQL, Redis, Gitea, etc. directly on your machine (which creates version conflicts and is messy to manage), each service runs in its own isolated box called a **container**.

**Key concepts:**

| Term | What It Means |
|------|--------------|
| **Container** | A running instance of a service (like one PostgreSQL server) |
| **Image** | The blueprint for a container (downloaded from the internet) |
| **Volume** | Persistent storage that survives when containers restart. Your database data lives here |
| **docker-compose.yml** | A recipe file that says "run these containers with these settings" |
| **Network** | Containers on the same Docker network can talk to each other |

**Why Docker matters for you:** If something breaks, you delete the container and recreate it from the image. Your data is safe in the volume. No need to debug installation issues — just rebuild.

### Git

Git tracks every change you make to your code. Think of it as **unlimited undo + a changelog**.

| Term | What It Means |
|------|--------------|
| **Repository (repo)** | A project folder tracked by git |
| **Commit** | A saved snapshot with a description ("added login page") |
| **Branch** | A parallel version of your code. You work on `develop` and merge to `main` when ready |
| **Push** | Upload your commits to a remote server (like Gitea on your mini PC) |
| **Pull** | Download commits from the remote server |

**You never need to understand git deeply.** Claude Code handles all the complexity. Your job is to run the commands it gives you and verify the results.

### Environment Variables (.env files)

Some values (passwords, API keys, URLs) shouldn't be written directly into code because:
1. They're **secret** (you don't want API keys in git history)
2. They **change between environments** (your local machine vs. production)

Instead, they go in a `.env` file:

```
DATABASE_PASSWORD=mySecretPassword123
LLM_API_KEY=sk_abc123def456
REDIS_PASSWORD=anotherSecretHere
```

Your code reads these values at runtime. The `.env` file is listed in `.gitignore` so it's **never committed to git**. You also keep a `.env.example` file (with blank values) so you remember what variables are needed.

### Ports

Every service on your computer listens on a **port** — a numbered address. Think of your mini PC as an apartment building:

- PostgreSQL lives in apartment 5432
- Redis lives in apartment 6379
- Your web app lives in apartment 3000
- Gitea lives in apartment 3001

When you access a service, you use `IP:port` — like `192.168.1.50:3000` in your browser.

The setup prompt binds all ports to `127.0.0.1` (localhost only) so they're not exposed to your entire network. You access them through Tailscale instead.

---

## The 20 Terminal Commands You Actually Need

Everything else, Claude Code will give you. These are just for navigating and checking things yourself.

### Navigation

```bash
pwd                     # "Where am I?" — prints current directory path
ls                      # "What's here?" — lists files and folders
ls -la                  # "What's here, including hidden files?" — shows everything with details
cd ~/projects           # Go to a specific folder (~ means your home directory)
cd ..                   # Go up one folder
cd ~                    # Go home
```

### Looking at Files

```bash
cat filename            # Print the entire contents of a file
head -20 filename       # Print just the first 20 lines
tail -20 filename       # Print just the last 20 lines
nano filename           # Edit a file (Ctrl+O to save, Ctrl+X to exit)
```

### File Operations

```bash
cp file1 file2          # Copy a file
mv file1 file2          # Move or rename a file
mkdir foldername        # Create a new folder
rm filename             # Delete a file (no undo!)
```

### System

```bash
sudo [command]          # Run the next command as admin (asks for password)
htop                    # See what's using CPU/RAM (press Q to quit)
df -h                   # Check disk space on all drives
free -h                 # Check RAM usage
```

### Docker (After It's Installed)

```bash
docker ps               # What containers are running right now?
docker compose up -d    # Start all containers defined in docker-compose.yml
docker compose down     # Stop all containers
docker compose logs -f  # Watch live logs from all containers (Ctrl+C to stop)
```

---

## How the Pieces Fit Together

```
┌─────────────────────────────────────────────────┐
│                  YOUR LAPTOP                     │
│                                                  │
│  Terminal ──SSH/Tailscale──→ Mini PC             │
│  Browser  ──Tailscale────→ Mini PC web UIs      │
│  Claude.ai ─────────────→ Agent Projects        │
│                             (planning/design)    │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                  MINI PC (Ubuntu)                 │
│                                                  │
│  Claude Code CLI ← Your AI coding partner        │
│       │                                          │
│       ▼                                          │
│  ┌─────────── Docker ──────────────┐             │
│  │  PostgreSQL  (database)         │             │
│  │  Redis       (cache)           │             │
│  │  Gitea       (your own GitHub) │             │
│  │  Portainer   (container UI)    │             │
│  │  Uptime Kuma (health checks)   │             │
│  │  Dozzle      (log viewer)      │             │
│  │  Your Apps   (dashboards etc.) │             │
│  └─────────────────────────────────┘             │
│                                                  │
│  ~/projects/                                     │
│    ├── infrastructure/  (the Docker setup)       │
│    ├── my-app/        (your main project)          │
│    ├── my-dashboard/  (example second project)      │
│    └── experiments/     (quick tests)            │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│              EXTERNAL SERVICES                    │
│                                                  │
│  LLM API        ← Your LLM provider for AI features │
│  Tailscale      ← Secure remote access           │
│  Telegram       ← Alerts when things break       │
└─────────────────────────────────────────────────┘
```

### The Mental Model

```
You (describe what you want in plain English)
  → Claude Code (writes code, runs commands, debugs)
    → Mini PC (executes everything 24/7)
      → Docker (isolates and manages your services)
        → Your apps work ✨

Your job:  Describe. Review. Approve. Verify.
Claude's job: Write. Execute. Debug. Iterate.
```

---

## Your First Hour With the Mini PC

This is the exact sequence you'll follow. Don't skip ahead.

### Step 1: Power On & Log In (5 min)

1. Plug in monitor, keyboard, ethernet, and power
2. Boot the mini PC
3. Log in with the credentials you set during Ubuntu installation
4. Open a terminal (press `Ctrl+Alt+T` or search "Terminal" in the app launcher)

### Step 2: Find Your IP Address (2 min)

Run this command:
```bash
ip addr | grep "inet " | grep -v 127.0.0.1
```

You'll see something like `inet 192.168.1.50/24`. The number before `/24` is your mini PC's local IP address. **Write it down** — you'll need it to SSH in from your laptop.

### Step 3: Make Sure SSH Is Running (2 min)

```bash
sudo systemctl status sshd
```

If it says "active (running)" — you're good. If it says anything else:
```bash
sudo apt install openssh-server -y
sudo systemctl enable --now sshd
```

### Step 4: Connect From Your Laptop (5 min)

On your **laptop** (not the mini PC), open a terminal and type:
```bash
ssh yourusername@192.168.1.50
```
(Replace with your actual username and IP)

Type "yes" when asked about the fingerprint. Enter your password. If you see the mini PC's prompt — you're in. **You can now unplug the monitor from the mini PC.**

### Step 5: Install Node.js & Claude Code (10 min)

Still connected via SSH, run these commands one at a time:

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node -v
npm -v

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Verify
claude --version
```

### Step 6: Start Claude Code & Paste the Setup Prompt (5 min)

```bash
mkdir -p ~/projects/infrastructure
cd ~/projects/infrastructure
claude
```

Claude Code will ask for your Anthropic API key on first run. Paste it in.

Then paste the entire contents of `infrastructure/MINI_PC_SETUP_PROMPT.md` (everything between the ``` markers).

**From here, Claude Code takes the wheel.** Follow its instructions one phase at a time. Don't skip the verification steps.

---

## Common "Day One" Gotchas

| Problem | Solution |
|---------|----------|
| "Connection refused" when SSH'ing | SSH isn't installed or running. Plug monitor back in and run `sudo apt install openssh-server -y` |
| "Permission denied (publickey)" | Password auth might be disabled. Plug monitor in and check `/etc/ssh/sshd_config` |
| Can't find the IP address | Make sure the ethernet cable is plugged in and run `ip addr` |
| Terminal shows weird characters | Run `export LANG=en_US.UTF-8` and add it to `~/.bashrc` |
| `npm: command not found` after installing Node | Close the terminal and open a new one, or run `source ~/.bashrc` |
| Claude Code asks for API key but you don't have one | Go to console.anthropic.com → API Keys → Create Key |
| Mini PC seems frozen/slow | Run `htop` to check — if RAM is maxed, you may need to close something or add swap |

---

## What Happens After Day Zero

Once the infrastructure setup prompt finishes (all 5 phases), you'll have:

- A fully configured dev server running 24/7
- All services accessible from anywhere via Tailscale
- Automated backups, monitoring, and alerts
- Project directories ready for development

Then you move on to the **AI Agent Team setup** (`essential/agents/README.md`) and start building with the framework described in the rest of this repo.

**Next step:** Read `infrastructure/MINI_PC_SETUP_PROMPT.md` and have it ready to paste when you reach Step 6 above.
