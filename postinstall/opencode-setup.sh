```bash
#!/usr/bin/env bash
################################################################################
# Kali-Linux-OpenCode-Portable-Drive
# Main Installation and Initialization Utility
#
# Installs or prepares:
#   1. OpenCode
#   2. Bun runtime
#   3. CLI Agent repository and Python environment (when supported)
#   4. Kali MCP repository and Python environment (when supported)
#   5. OpenCode Shannon Plugin repository and dependencies
#   6. Optional Shannon Docker image build
#   7. Optional Ollama local AI runtime
#
# Initializes:
#   ~/.opencode/workspace/
#   ~/.config/opencode/
#   ~/cli-agent/
#   ~/kali-mcp/
#   ~/opencode-shannon-plugin/
#
# Usage:
#   chmod +x opencode-setup.sh
#   ./opencode-setup.sh
#
# Optional:
#   INSTALL_OLLAMA=1 ./opencode-setup.sh
#   PULL_OLLAMA_MODELS=1 ./opencode-setup.sh
#   BUILD_SHANNON_DOCKER=1 ./opencode-setup.sh
#
# Run as a normal desktop user, NOT as root.
################################################################################

set -Eeuo pipefail
umask 077

# ==============================================================================
# PROJECT CONFIGURATION
# ==============================================================================

PROJECT_NAME="Kali-Linux-OpenCode-Portable-Drive"

USER_HOME="${HOME:?HOME is not set}"

OPENCODE_HOME="${OPENCODE_HOME:-$USER_HOME/.opencode}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$USER_HOME/.config}/opencode"

CLI_AGENT_HOME="$USER_HOME/cli-agent"
KALI_MCP_HOME="$USER_HOME/kali-mcp"
SHANNON_HOME="$USER_HOME/opencode-shannon-plugin"

WORKSPACE="$OPENCODE_HOME/workspace"

INSTALL_OLLAMA="${INSTALL_OLLAMA:-0}"
PULL_OLLAMA_MODELS="${PULL_OLLAMA_MODELS:-0}"
BUILD_SHANNON_DOCKER="${BUILD_SHANNON_DOCKER:-0}"

CLI_AGENT_REPO="${CLI_AGENT_REPO:-https://github.com/amranu/cli-agent.git}"
KALI_MCP_REPO="${KALI_MCP_REPO:-https://github.com/k3nn3dy-ai/kali-mcp.git}"
SHANNON_REPO="${SHANNON_REPO:-https://github.com/vichhka-git/opencode-shannon-plugin.git}"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="$WORKSPACE/logs"
LOG_FILE="$LOG_DIR/setup-$TIMESTAMP.log"

# ==============================================================================
# COLORS AND LOGGING
# ==============================================================================

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    CYAN='\033[1;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    BLUE=''
    YELLOW=''
    CYAN=''
    NC=''
fi

info() {
    printf '%b[INFO]%b %s\n' "$BLUE" "$NC" "$1"
}

success() {
    printf '%b[OK]%b