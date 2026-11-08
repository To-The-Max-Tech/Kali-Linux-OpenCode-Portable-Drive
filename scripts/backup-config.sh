```bash
#!/usr/bin/env bash
################################################################################
# Kali-Linux-OpenCode-Portable-Drive
# Configuration and Workspace Backup Utility
#
# Backs up OpenCode configuration, workspace data, agents, and device settings.
#
# Backup sources:
#   ~/.opencode/
#   ~/.config/opencode/
#
# Features:
#   - Timestamped backups
#   - OpenCode configuration backup
#   - Workspace, findings, reports, and engagement backup
#   - Agent and session backup
#   - Device configuration backup
#   - Exclusion of selected large media files
#   - Optional SSH/rsync synchronization
#   - Automatic retention (last 10 successful local backups)
#   - Backup manifest and SHA-256 checksums
#   - Restricted backup permissions
#
# Usage:
#   ./backup-config.sh
#   ./backup-config.sh user@remote-host
#   ./backup-config.sh user@remote-host /remote/backup/path
#
# IMPORTANT:
#   Backups may contain API keys, tokens, credentials, and private
#   assessment data. Store and transfer them securely.
################################################################################

set -Eeuo pipefail
umask 077

# ------------------------------------------------------------------------------
# PROJECT CONFIGURATION
# ------------------------------------------------------------------------------

PROJECT_NAME="Kali-Linux-OpenCode-Portable-Drive"

HOME_DIR="${HOME:?HOME is not set}"

OPENCODE_HOME="${OPENCODE_HOME:-$HOME_DIR/.opencode}"
OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME_DIR/.config}/opencode"

BACKUP_BASE="$OPENCODE_HOME/workspace/backups"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_NAME="kali-linux-opencode-portable-drive-$TIMESTAMP"
BACKUP_DIR="$BACKUP_BASE/$BACKUP_NAME"

KEEP_BACKUPS=10

REMOTE="${1:-}"
REMOTE_DIR="${2:-backups/kali-linux-opencode-portable-drive}"

# ------------------------------------------------------------------------------
# COLORS
# ------------------------------------------------------------------------------

if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    GREEN=''
    BLUE=''
    YELLOW=''
    RED=''
    CYAN=''
    NC=''
fi

# ------------------------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------------------------

log() {
    printf '%b[INFO]%b %s\n' "$BLUE" "$NC" "$1"
}

success() {
    printf '%b[OK]%b %s\n' "$GREEN" "$NC" "$1"
}

warning() {
    printf '%b[WARNING]%b %s\n' "$YELLOW" "$NC" "$1"
}

error() {
    printf '%b[ERROR]%b %s\n' "$RED" "$NC" "$1" >&2
}

# ------------------------------------------------------------------------------
# ERROR HANDLING
# ------------------------------------------------------------------------------

BACKUP_COMPLETE=0

cleanup_on_error() {
    local exit_code=$?

    trap - ERR

    error "Backup failed with exit code $exit_code."

    if [[ -d "${BACKUP_DIR:-}" && "$BACKUP_COMPLETE" -ne 1 ]]; then
        warning "Incomplete backup retained for inspection:"
        warning "$BACKUP_DIR"
    fi

    exit "$exit_code"
}

trap cleanup_on_error ERR

# ------------------------------------------------------------------------------
# DEPENDENCY CHECKS
# ------------------------------------------------------------------------------

for command_name in date hostname whoami mkdir cp du find sort sha256sum; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "Required command not found: $command_name"
        exit 1
    fi
done

if [[ -n "$REMOTE" ]]; then
    for command_name in rsync ssh; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            error "Remote synchronization requires: $command_name"
            exit 1
        fi
    done
fi

# ------------------------------------------------------------------------------
# VALIDATE SOURCE DIRECTORIES
# ------------------------------------------------------------------------------

if [[ ! -d "$OPENCODE_HOME" ]]; then
    error "OpenCode data directory does not exist:"
    error "$OPENCODE_HOME"
    exit 1
fi

if [[ "$BACKUP_BASE" == "$OPENCODE_HOME" ]]; then
    error "Invalid backup destination."
    exit 1
fi

# ------------------------------------------------------------------------------
# BANNER
# ------------------------------------------------------------------------------

echo ""
printf '%b===========================================================%b\n' "$CYAN" "$NC"
printf '%b %s%b\n' "$CYAN" "$PROJECT_NAME" "$NC"
printf '%b CONFIGURATION AND WORKSPACE BACKUP%b\n' "$CYAN" "$NC"
printf '%b===========================================================%b\n' "$CYAN" "$NC"
echo ""

log "OpenCode data directory: $OPENCODE_HOME"
log "OpenCode configuration:  $OPENCODE_CONFIG"
log "Backup destination:      $BACKUP_DIR"

# ------------------------------------------------------------------------------
# CREATE BACKUP DIRECTORY
# ------------------------------------------------------------------------------

mkdir -p "$BACKUP_BASE"
chmod 700 "$BACKUP_BASE"

if [[ -e "$BACKUP_DIR" ]]; then
    error "Backup destination already exists: $BACKUP_DIR"
    exit 1
fi

mkdir -m 700 "$BACKUP_DIR"

# ------------------------------------------------------------------------------
# BACKUP OPENCode DATA
# ------------------------------------------------------------------------------

log "Backing up OpenCode data..."

for ITEM in \
    opencode.json \
    opencode.json.bak \
    agents \
    devices \
    sessions \
    logs \
    plugins
do
    SOURCE="$OPENCODE_HOME/$ITEM"

    if [[ -e "$SOURCE" ]]; then
        cp -a "$SOURCE" "$BACKUP_DIR/"
        success "Backed up: $ITEM"
    fi
done

# ------------------------------------------------------------------------------
# BACKUP OPENCode CONFIGURATION
# ------------------------------------------------------------------------------

if [[ -d "$OPENCODE_CONFIG" ]]; then
    log "Backing up OpenCode configuration..."

    mkdir -p "$BACKUP_DIR/config"

    cp -a "$OPENCODE_CONFIG/." "$BACKUP_DIR/config/"

    success "OpenCode configuration backed up."
else
    warning "OpenCode configuration directory not found:"
    warning "$OPENCODE_CONFIG"
fi

# ------------------------------------------------------------------------------
# BACKUP WORKSPACE
# ------------------------------------------------------------------------------

WORKSPACE="$OPENCODE_HOME/workspace"

if [[ -d "$WORKSPACE" ]]; then
    log "Backing up workspace..."

   