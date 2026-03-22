#!/bin/bash
# Daily greeting for claude-glm - delegates to greeting-runner.sh
exec "$(dirname "$0")/greeting-runner.sh" claude-glm glm-greeting "claude-glm"
