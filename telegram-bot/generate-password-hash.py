#!/usr/bin/env python3
"""
Generate a password hash for the Telegram bot.
Run this on any machine, then paste the hash into your .env file.

Usage:
  python3 generate-password-hash.py
"""

import hashlib
import getpass

print("=" * 50)
print("Telegram Bot Password Hash Generator")
print("=" * 50)
print()
password = getpass.getpass("Enter your chosen password: ")
confirm = getpass.getpass("Confirm password: ")

if password != confirm:
    print("❌ Passwords don't match. Try again.")
    exit(1)

if len(password) < 6:
    print("⚠️  Warning: Password is short. Consider using 8+ characters.")

password_hash = hashlib.sha256(password.strip().encode()).hexdigest()

print()
print("✅ Your password hash:")
print()
print(f"  TELEGRAM_SESSION_PASSWORD_HASH={password_hash}")
print()
print("Add this line to your .env file at:")
print("  ~/claude-multi-agent/telegram-bot/.env")
print()
print("⚠️  Do NOT share this hash. Do NOT commit it to git.")
