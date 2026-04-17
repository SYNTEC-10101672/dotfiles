#!/bin/bash
# Daily greeting for Claude Code - delegates to greeting-runner.sh
exec "$(dirname "$0")/greeting-runner.sh" claude greeting "Claude Code"
