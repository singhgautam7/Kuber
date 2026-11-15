#!/usr/bin/env python3
"""Runs a command under one repo-wide lock so parallel agents never run
build_runner / gen-l10n / ARB edits at the same time.
Usage: python3 tool/agent_lock.py <cmd> [args...]"""
import fcntl, os, subprocess, sys
os.makedirs('.dart_tool', exist_ok=True)
with open('.dart_tool/agent.lock', 'w') as f:
    fcntl.flock(f, fcntl.LOCK_EX)
    sys.exit(subprocess.call(sys.argv[1:]))
