```bash
#!/usr/bin/env bash
################################################################################
# Kali-Linux-OpenCode-Portable-Drive
# Authorized Endpoint Assessment Package Generator
#
# Generates a portable assessment package for Linux and Windows systems.
#
# The generated utilities:
#   - Collect basic local system information.
#   - Collect local network configuration.
#   - List listening network services.
#   - Identify selected security tools installed on Linux.
#   - Save assessment reports locally.
#
# This script does NOT:
#   - Connect to or execute commands on the supplied gateway.
#   - Remotely deploy software.
#   - Install remote-access tools or background services.
#   - Create persistence mechanisms.
#   - Automatically transmit collected information.
#
# Usage:
#   ./deploy-node.sh <gateway-ip> [display-name]
#
# Example:
#   ./deploy-node.sh 192.168.1.100 Lab-Endpoint-01
#
################################################################################

set -Eeuo pipefail
umask 077

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------

GATEWAY_IP="${1:-}"
DISPLAY_NAME="${2:-USB-Endpoint}"

PROJECT_NAME="Kali-Linux-OpenCode-Portable-Drive"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DEPLOY_DIR="./node-deploy-${TIMESTAMP}"

# ------------------------------------------------------------------------------
# COLORS
# ------------------------------------------------------------------------------

if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
else
    GREEN=''
    BLUE=''
    YELLOW=''
    RED=''
    NC=''
fi

# ------------------------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------------------------

info() {
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

usage() {
    cat <<EOF
Usage:
  $0 <gateway-ip> [display-name]

Example:
  $0 192.168.1.100 Lab-Endpoint-01

The gateway address is recorded in deployment.conf and the
deployment README. It is not contacted by this generator.
EOF
}

# ------------------------------------------------------------------------------
# DEPENDENCY CHECKS
# ------------------------------------------------------------------------------

for command_name in date mkdir chmod find sort sha256sum xargs; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "Required command not found: $command_name"
        exit 1
    fi
done

# ------------------------------------------------------------------------------
# ARGUMENT VALIDATION
# ------------------------------------------------------------------------------

if [[ -z "$GATEWAY_IP" ]]; then
    error "Gateway IPv4 address is required."
    usage
    exit 1
fi

if [[ ! "$GATEWAY_IP" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
    error "Invalid IPv4 address format."
    usage
    exit 1
fi

IFS='.' read -r -a OCTETS <<< "$GATEWAY_IP"

for OCTET in "${OCTETS[@]}"; do
    if (( 10#$OCTET > 255 )); then
        error "Invalid IPv4 address: $GATEWAY_IP"
        exit 1
    fi
done

if [[ ! "$DISPLAY_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    error "Display name may contain only letters, numbers, dots, underscores, and hyphens."
    exit 1
fi

if [[ "$DISPLAY_NAME" == "." || "$DISPLAY_NAME" == ".." ]]; then
    error "Display name cannot be '.' or '..'."
    exit 1
fi

# ------------------------------------------------------------------------------
# CREATE PACKAGE DIRECTORY
# ------------------------------------------------------------------------------

if [[ -e "$DEPLOY_DIR" ]]; then
    error "Deployment directory already exists: $DEPLOY_DIR"
    exit 1
fi

mkdir -p "$DEPLOY_DIR"
chmod 700 "$DEPLOY_DIR"

echo ""
echo "=============================================================="
echo " $PROJECT_NAME"
echo " AUTHORIZED ENDPOINT ASSESSMENT PACKAGE"
echo "=============================================================="
echo ""

info "Creating package: $DEPLOY_DIR"

# ------------------------------------------------------------------------------
# 1. LINUX ENDPOINT ASSESSMENT UTILITY
# ------------------------------------------------------------------------------

info "Generating Linux assessment utility..."

cat > "$DEPLOY_DIR/run-node.sh" <<'LINUX'
#!/usr/bin/env bash
################################################################################
# Linux Local Endpoint Assessment
#
# Run locally on a system you own or are explicitly authorized to assess.
#
# This utility collects local system and network configuration information.
# It does not connect to remote hosts, install services, or transmit reports.
################################################################################

set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
OUTPUT_DIR="$SCRIPT_DIR/results"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
REPORT="$OUTPUT_DIR/linux-assessment-$TIMESTAMP.txt"

mkdir -p "$OUTPUT_DIR"

section() {
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

{
    echo "KALI-LINUX-OPENCODE-PORTABLE-DRIVE"
    echo "LINUX LOCAL ENDPOINT ASSESSMENT"
    echo "================================="
    echo
    echo "Timestamp: $(date -Is)"
    echo "Hostname: $(hostname)"
    echo "Username: $(id -un)"
    echo "Operating system: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"

    section "OPERATING SYSTEM"

    if [[ -r /etc/os-release ]]; then
        cat /etc/os-release
    else
        echo "Operating system release information unavailable."
    fi

    section "CPU INFORMATION"

    if command -v lscpu >/dev/null 2>&1; then
        lscpu
    else
        echo "lscpu is not installed."
    fi

    section "MEMORY INFORMATION"

    if command -v free >/dev/null 2>&1; then
        free -h
    else
        echo "free is not installed."
    fi

    section "DISK INFORMATION"

    df -h

    section "NETWORK INTERFACES"

    if command -v ip >/dev/null 2>&1; then
        ip -brief address
    else
        echo "The ip command is not installed."
    fi

    section "ROUTING INFORMATION"

    if command -v ip >/dev/null 2>&1; then
        ip route
    else
        echo "The ip command is not installed."
    fi

    section "DNS CONFIGURATION"

    if [[ -r /etc/resolv.conf ]]; then
        cat /etc/resolv.conf
    else
        echo "DNS configuration is not readable."
    fi

    section "LISTENING TCP SERVICES"

    if command -v ss >/dev/null 2>&1; then
        ss -lnt
    else
        echo "The ss command is not installed."
    fi

    section "SELECTED SECURITY AND DEVELOPMENT TOOLS"

    for TOOL in nmap rustscan nuclei nikto curl git python3; do
        if command -v "$TOOL" >/dev/null 2>&1; then
            printf '%-15s %s\n' "$TOOL" "Installed"
        else
            printf '%-15s %s\n' "$TOOL" "Not installed"
        fi
    done

    section "ASSESSMENT SUMMARY"

    echo "Local information collection completed."
    echo "No remote systems were contacted."
    echo "No services or remote-access tools were installed."
    echo "No report data was transmitted."

} 2>&1 | tee "$REPORT"

echo
echo "Assessment completed."
echo "Report: $REPORT"
LINUX

chmod 700 "$DEPLOY_DIR/run-node.sh"
success "Linux assessment utility created."

# ------------------------------------------------------------------------------
# 2. WINDOWS ENDPOINT ASSESSMENT UTILITY
# ------------------------------------------------------------------------------

info "Generating Windows assessment utility..."

cat > "$DEPLOY_DIR/run-node.ps1" <<'WINDOWS'
################################################################################
# Windows Local Endpoint Assessment
#
# Run locally on a system you own or are explicitly authorized to assess.
#
# Collects local system and network configuration information.
# Does not connect to remote hosts or transmit reports.
################################################################################

$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputDir = Join-Path $ScriptDir "results"

New-Item -ItemType Directory -Force -Path $OutputDir |
    Out-Null

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$Report = Join-Path $OutputDir "windows-assessment-$Timestamp.txt"

Start-Transcript -Path $Report -Force

try {
    Write-Host ""
    Write-Host "================================================"
    Write-Host "KALI-LINUX-OPENCODE-PORTABLE-DRIVE"
    Write-Host "WINDOWS LOCAL ENDPOINT ASSESSMENT"
    Write-Host "================================================"

    Write-Host "`nTIMESTAMP"
    Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Write-Host "`nSYSTEM INFORMATION"
    Get-ComputerInfo |
        Select-Object WindowsProductName,
                      WindowsVersion,
                      OsArchitecture,
                      CsName,
                      CsTotalPhysicalMemory

    Write-Host "`nCURRENT USER"
    whoami

    Write-Host "`nCPU INFORMATION"
    Get-CimInstance Win32_Processor |
        Select-Object Name,
                      NumberOfCores,
                      NumberOfLogicalProcessors

    Write-Host "`nMEMORY INFORMATION"
    Get-CimInstance Win32_OperatingSystem |
        Select-Object TotalVisibleMemorySize,
                      FreePhysicalMemory

    Write-Host "`nDISK INFORMATION"
    Get-Volume |
        Select-Object DriveLetter,
                      FileSystem,
                      Size,
                      SizeRemaining

    Write-Host "`nNETWORK INTERFACES"
    Get-NetIPConfiguration

    Write-Host "`nIPv4 ROUTING INFORMATION"
    Get-NetRoute -AddressFamily IPv4 |
        Select-Object DestinationPrefix,
                      NextHop,
                      InterfaceAlias

    Write-Host "`nDNS CONFIGURATION"
    Get-DnsClientServerAddress -AddressFamily IPv4

    Write-Host "`nLISTENING TCP PORTS"
    Get-NetTCPConnection -State Listen |
        Select-Object LocalAddress, LocalPort

    Write-Host "`nASSESSMENT SUMMARY"
    Write-Host "Local information collection completed."
    Write-Host "No remote systems were contacted."
    Write-Host "No services or remote-access tools were installed."
    Write-Host "No report data was transmitted."
}
finally {
    Stop-Transcript
}

Write-Host "`nReport saved to: $Report"
WINDOWS

success "Windows assessment utility created."

# ------------------------------------------------------------------------------
# 3. DEPLOYMENT DOCUMENTATION
# ------------------------------------------------------------------------------

info "Generating deployment documentation..."

cat > "$DEPLOY_DIR/DEPLOY-README.txt" <<EOF
==============================================================
KALI-LINUX-OPENCODE-PORTABLE-DRIVE
AUTHORIZED ENDPOINT ASSESSMENT PACKAGE
==============================================================

PROJECT:
$PROJECT_NAME

ENDPOINT DISPLAY NAME:
$DISPLAY_NAME

GATEWAY ADDRESS (METADATA ONLY):
$GATEWAY_IP

PACKAGE CREATED:
$TIMESTAMP

==============================================================
PACKAGE CONTENTS
==============================================================

run-node.sh
    Linux local endpoint assessment utility.

run-node.ps1
    Windows local endpoint assessment utility.

deployment.conf
    Package metadata, including the supplied gateway address.

SHA256SUMS
    SHA-256 checksums for the generated top-level package files.

results/
    Created automatically when an assessment utility is run.
    Contains locally generated reports.

==============================================================
AUTHORIZATION AND SCOPE
==============================================================

Use this package only on systems you own or are explicitly
authorized to assess.

The supplied gateway address is recorded as metadata only.
This package does not contact that address.

Both assessment utilities run locally on the endpoint.
They collect basic system and network configuration details.

They do not:
    - Execute commands on remote systems.
    - Install remote-access software.
    - Create background services or scheduled tasks.
    - Establish reverse connections.
    - Install persistence mechanisms.
    - Conceal their execution.
    - Automatically transmit collected information.

==============================================================
LINUX INSTRUCTIONS
==============================================================

1. Transfer the package to the authorized Linux endpoint.
2. Open a terminal in the package directory.
3. Run:

    chmod +x run-node.sh
    ./run-node.sh

The utility creates a results/ directory and saves a
timestamped assessment report there.

Some system details may be unavailable without elevated
permissions. Run with administrator privileges only when
necessary and explicitly approved.

==============================================================
WINDOWS INSTRUCTIONS
==============================================================

1. Transfer the package to the authorized Windows endpoint.
2. Open PowerShell in the package directory.
3. Run:

    powershell.exe -NoProfile -File .\run-node.ps1

If local PowerShell policy prevents execution, follow your
organization's approved script-execution procedure. Do not
weaken system-wide security settings just to run this tool.

The utility creates a results/ directory and saves a
timestamped assessment report there.

==============================================================
KALI + OPENCODE WORKFLOW
==============================================================

After collecting reports, transfer them back to your Kali
portable drive using an approved method.

Suggested workspace organization:

    ~/.opencode/workspace/
    |
    +-- engagements/
    |   |
    |   +-- endpoint-assessments/
    |       |
    |       +-- $DISPLAY_NAME/
    |           |
    |           +-- results/
    |
    +-- reports/
    +-- findings/
    +-- evidence/

Review the reports and document findings before taking
further action. Do not treat inventory output as proof that
a vulnerability exists.

==============================================================
INTEGRITY VERIFICATION
==============================================================

From this package directory, run:

    sha256sum -c SHA256SUMS

A successful check indicates that the listed files match
the checksums generated when this package was created.

SHA256SUMS is not a digital signature. It does not prove
who created the package or protect against an attacker
who can replace both a file and its checksum.

==============================================================
PRIVACY
==============================================================

Assessment reports can contain sensitive information,
including hostnames, usernames, IP addresses, DNS settings,
network routes, and listening ports.

Protect the reports appropriately. Review them before
sharing, and remove information that is not needed.

==============================================================
EOF

success "Deployment documentation created."

# ------------------------------------------------------------------------------
# 4. DEPLOYMENT CONFIGURATION
# ------------------------------------------------------------------------------

cat > "$DEPLOY_DIR/deployment.conf" <<EOF
PROJECT_NAME="$PROJECT_NAME"
DISPLAY_NAME="$DISPLAY_NAME"
GATEWAY_IP="$GATEWAY_IP"
CREATED="$TIMESTAMP"
PLATFORM="linux,windows"
DEPLOYMENT_TYPE="authorized-local-endpoint-assessment"
EOF

chmod 600 "$DEPLOY_DIR/deployment.conf"
success "Deployment configuration created."

# ------------------------------------------------------------------------------
# 5. SHA256 INTEGRITY MANIFEST
# ------------------------------------------------------------------------------

info "Generating SHA256 checksums..."

(
    cd "$DEPLOY_DIR"

    find . -maxdepth 1 -type f \
        ! -name SHA256SUMS \
        -print0 |
        sort -z |
        xargs -0 -r sha256sum > SHA256SUMS
)

chmod 600 "$DEPLOY_DIR/SHA256SUMS"
success "SHA256 manifest created."

# ------------------------------------------------------------------------------
# 6. FINAL SUMMARY
# ------------------------------------------------------------------------------

echo
echo "=============================================================="
echo " ENDPOINT ASSESSMENT PACKAGE CREATED"
echo "=============================================================="
echo

printf 'Project:       %s\n' "$PROJECT_NAME"
printf 'Endpoint:      %s\n' "$DISPLAY_NAME"
printf 'Gateway:       %s (metadata only)\n' "$GATEWAY_IP"
printf 'Package:       %s\n' "$DEPLOY_DIR"
echo
echo "PACKAGE CONTENTS:"
ls -lah "$DEPLOY_DIR"

echo
echo "NEXT STEPS:"
echo "1. Review DEPLOY-README.txt."
echo "2. Verify the package with: (cd \"$DEPLOY_DIR\" && sha256sum -c SHA256SUMS)"
echo "3. Transfer it to an authorized endpoint."
echo "4. Run the appropriate local assessment utility."
echo "5. Review and protect the resulting reports."
echo

success "Package generation completed."
exit 0
```