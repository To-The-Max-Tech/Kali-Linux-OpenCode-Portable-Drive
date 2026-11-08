#!/usr/bin/env bash
################################################################################
# Kali-Linux-OpenCode-Portable-Drive
#
# Kali Linux Live + Persistence Portable Drive Builder
#
# Supports USB flash drives and portable SSDs using common Linux device names:
#   /dev/sdX
#   /dev/nvme0n1
#   /dev/mmcblk0
#
# WARNING:
#   Default mode erases the selected target disk.
#
# Usage:
#   sudo ./build-kali-portable.sh [DEVICE]
#   sudo ./build-kali-portable.sh --persistence-only [DEVICE]
################################################################################

set -Eeuo pipefail
IFS=$'\n\t'

PROJECT_NAME="Kali-Linux-OpenCode-Portable-Drive"
SCRIPT_NAME="build-kali-portable.sh"

WORK_DIR=""
ISO_PATH=""
ISO_SOURCE=""
KALI_ISO_URL=""
EXPECTED_SHA256=""
TARGET_DEVICE=""
PERSISTENCE_PART=""
PERSISTENCE_MOUNT=""
ISO_DOWNLOADED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Logging
################################################################################

log_info() {
    printf '%b[INFO]%b %s\n' "$BLUE" "$NC" "$*"
}

log_success() {
    printf '%b[✓]%b %s\n' "$GREEN" "$NC" "$*"
}

log_warn() {
    printf '%b[!]%b %s\n' "$YELLOW" "$NC" "$*"
}

log_error() {
    printf '%b[✗]%b %s\n' "$RED" "$NC" "$*" >&2
}

die() {
    log_error "$*"
    exit 1
}

################################################################################
# Cleanup
################################################################################

cleanup() {
    local rc=$?

    if [[ -n "$PERSISTENCE_MOUNT" ]] &&
       mountpoint -q "$PERSISTENCE_MOUNT"; then

        log_warn "Unmounting persistence filesystem..."

        umount "$PERSISTENCE_MOUNT" ||
            log_error "Could not unmount $PERSISTENCE_MOUNT"
    fi

    if [[ -n "$PERSISTENCE_MOUNT" &&
          -d "$PERSISTENCE_MOUNT" ]]; then
        rmdir "$PERSISTENCE_MOUNT" 2>/dev/null || true
    fi

    if [[ "$ISO_DOWNLOADED" -eq 1 &&
          -n "$ISO_PATH" &&
          -f "$ISO_PATH" ]]; then
        rm -f "$ISO_PATH"
    fi

    if [[ -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
        rm -rf "$WORK_DIR"
    fi

    if [[ "$rc" -ne 0 ]]; then
        log_error "Builder stopped with exit code $rc."
    fi

    return "$rc"
}

trap cleanup EXIT

################################################################################
# Dependency Checks
################################################################################

check_root() {
    [[ "$EUID" -eq 0 ]] ||
        die "Run this builder with sudo/root."
}

check_dependencies() {
    local missing=()
    local cmd

    for cmd in \
        lsblk \
        blockdev \
        sha256sum \
        dd \
        parted \
        partprobe \
        udevadm \
        mkfs.ext4 \
        mount \
        umount \
        mountpoint \
        awk \
        grep \
        wget \
        curl \
        realpath \
        findmnt \
        swapon \
        readlink \
        sync \
        sleep \
        tar
    do
        command -v "$cmd" >/dev/null 2>&1 ||
            missing+=("$cmd")
    done

    if ((${#missing[@]} > 0)); then
        die "Missing required utilities: ${missing[*]}"
    fi
}

initialize_work_directory() {
    WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/kali-portable-builder.XXXXXX")" ||
        die "Could not create temporary working directory."
}

################################################################################
# Help
################################################################################

show_help() {
    cat <<HELP
$PROJECT_NAME

Kali Linux Live + Persistence Portable Drive Builder

Usage:

  sudo ./$SCRIPT_NAME [DEVICE]

  sudo ./$SCRIPT_NAME --persistence-only [DEVICE]

Modes:

  Default:
    Downloads or uses an existing Kali ISO.
    Verifies the ISO SHA-256 checksum.
    Writes the ISO to the selected disk.
    Creates and configures persistence.

    WARNING: Erases the selected target disk.

  --persistence-only:
    Preserves the existing ISO.
    Creates a persistence partition in unallocated space.
    Does not download or write an ISO.

Options:

  -h, --help
    Display this help message.

Examples:

  sudo ./$SCRIPT_NAME

  sudo ./$SCRIPT_NAME /dev/sdc

  sudo ./$SCRIPT_NAME --persistence-only

  sudo ./$SCRIPT_NAME --persistence-only /dev/sdc

Supported device naming examples:

  /dev/sdb
  /dev/sdc
  /dev/nvme0n1
  /dev/mmcblk0

Project:
  $PROJECT_NAME

HELP
}

################################################################################
# Argument Validation
################################################################################

parse_arguments() {
    MODE="full"
    DEVICE_ARGUMENT=""

    if (($# > 2)); then
        die "Too many arguments. Use --help for usage."
    fi

    case "${1:-}" in
        --help|-h)
            [[ $# -eq 1 ]] ||
                die "The help option cannot be combined with other arguments."

            show_help
            exit 0
            ;;

        --persistence-only)
            MODE="persistence"

            if (($# == 2)); then
                DEVICE_ARGUMENT="$2"
            fi
            ;;

        "")
            MODE="full"
            ;;

        -*)
            die "Unknown option: $1"
            ;;

        *)
            DEVICE_ARGUMENT="$1"
            ;;
    esac

    if [[ "$MODE" == "full" && $# -eq 2 ]]; then
        die "Unexpected second argument. Use --help for usage."
    fi
}

################################################################################
# Target Device Validation
################################################################################

device_is_root_backing_device() {
    local root_source
    local resolved_source
    local dependency

    root_source="$(findmnt -nro SOURCE / 2>/dev/null || true)"

    [[ -n "$root_source" ]] || return 1

    resolved_source="${root_source%%\[*}"

    [[ -b "$resolved_source" ]] || return 1

    while IFS= read -r dependency; do
        [[ -n "$dependency" ]] || continue

        dependency="$(readlink -f "$dependency")"

        if [[ "$dependency" == "$TARGET_DEVICE" ]]; then
            return 0
        fi
    done < <(lsblk -s -nrpo NAME "$resolved_source" 2>/dev/null || true)

    return 1
}

check_target_mounts() {
    local mountpoints

    mountpoints="$(lsblk -nrpo MOUNTPOINTS "$TARGET_DEVICE" 2>/dev/null || true)"

    if [[ -n "$mountpoints" ]] &&
       grep -q '[^[:space:]]' <<< "$mountpoints"; then

        lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$TARGET_DEVICE"

        die "A filesystem on the target disk is mounted. Unmount it first."
    fi
}

check_target_swap() {
    local partition
    local active_swap

    while IFS= read -r partition; do
        [[ -n "$partition" ]] || continue

        active_swap="$(
            swapon --noheadings --raw --show=NAME 2>/dev/null || true
        )"

        if grep -Fxq "$partition" <<< "$active_swap"; then
            die "Target partition $partition is active swap. Disable it first."
        fi

    done < <(
        lsblk -nrpo NAME,TYPE "$TARGET_DEVICE" |
        awk '$2 == "part" {print $1}'
    )
}

prompt_target_device() {
    local candidate="${1:-}"
    local mode="${2:-full}"
    local confirm

    if [[ -z "$candidate" ]]; then
        echo
        echo "Available whole-disk devices:"
        lsblk -d -o NAME,MODEL,SIZE,TRAN,TYPE |
            awk '$5 == "disk"'

        read -r -p "Target disk: " candidate
    fi

    [[ -n "$candidate" ]] ||
        die "No target disk specified."

    TARGET_DEVICE="$(readlink -f "$candidate")" ||
        die "Could not resolve target device."

    [[ -b "$TARGET_DEVICE" ]] ||
        die "$TARGET_DEVICE is not a block device."

    [[ "$(lsblk -dnro TYPE "$TARGET_DEVICE")" == "disk" ]] ||
        die "Select a whole disk, not a partition."

    if device_is_root_backing_device; then
        die "Target disk contains a device backing the running root filesystem."
    fi

    echo
    echo "========== TARGET DISK =========="

    lsblk -d -o NAME,MODEL,SERIAL,SIZE,TRAN,RO "$TARGET_DEVICE"

    check_target_mounts
    check_target_swap

    [[ "$(blockdev --getro "$TARGET_DEVICE")" == "0" ]] ||
        die "Target disk is read-only."

    echo

    if [[ "$mode" == "persistence" ]]; then
        log_warn "Persistence-only recovery mode."
        log_warn "The existing Kali ISO will not be rewritten."
        log_warn "Only a new persistence partition will be created."
    else
        log_warn "ALL DATA ON $TARGET_DEVICE WILL BE DESTROYED."
    fi

    echo

    read -r -p "Type the exact path '$TARGET_DEVICE' to confirm: " confirm

    [[ "$confirm" == "$TARGET_DEVICE" ]] ||
        die "Device confirmation failed. Cancelled."
}

################################################################################
# ISO Configuration
################################################################################

prompt_iso_configuration() {
    local input

    echo
    echo "========== KALI ISO CONFIGURATION =========="

    while true; do
        read -r -p "Kali ISO URL or existing ISO path: " input

        [[ -n "$input" ]] ||
            {
                log_warn "Enter a URL or file path."
                continue
            }

        if [[ -f "$input" ]]; then
            ISO_SOURCE="local"
            ISO_PATH="$(realpath "$input")"
            break

        elif [[ "$input" =~ ^https?:// ]]; then
            ISO_SOURCE="remote"
            KALI_ISO_URL="$input"
            ISO_PATH="$WORK_DIR/kali-live-amd64.iso"
            break

        else
            log_warn "Not an existing file or HTTP(S) URL."
        fi
    done

    echo
    echo "Enter the SHA-256 checksum published for this exact ISO."

    while true; do
        read -r -p "Expected SHA-256: " EXPECTED_SHA256

        EXPECTED_SHA256="${EXPECTED_SHA256//[[:space:]]/}"

        if [[ "$EXPECTED_SHA256" =~ ^[[:xdigit:]]{64}$ ]]; then
            EXPECTED_SHA256="${EXPECTED_SHA256,,}"
            break
        fi

        log_warn "SHA-256 must contain exactly 64 hexadecimal characters."
    done
}

################################################################################
# ISO Download and Verification
################################################################################

prepare_iso() {
    if [[ "$ISO_SOURCE" == "remote" ]]; then
        log_info "Downloading Kali ISO..."

        ISO_DOWNLOADED=1

        wget \
            --show-progress \
            --continue \
            --output-document="$ISO_PATH" \
            "$KALI_ISO_URL" ||
            die "ISO download failed."
    fi

    [[ -s "$ISO_PATH" ]] ||
        die "ISO file is missing or empty."

    log_info "Calculating ISO SHA-256 checksum..."

    local actual

    actual="$(sha256sum "$ISO_PATH" | awk '{print tolower($1)}')"

    if [[ "$actual" != "$EXPECTED_SHA256" ]]; then
        printf '\nExpected: %s\nActual:   %s\n' \
            "$EXPECTED_SHA256" "$actual" >&2

        die "Checksum mismatch. Refusing to write the drive."
    fi

    log_success "SHA-256 checksum verified."
}

################################################################################
# ISO Writing
################################################################################

write_iso() {
    log_warn "Writing ISO to $TARGET_DEVICE."
    log_warn "This operation destroys existing data on the target disk."

    dd \
        if="$ISO_PATH" \
        of="$TARGET_DEVICE" \
        bs=4M \
        status=progress \
        conv=fsync ||
        die "ISO writing failed."

    sync

    partprobe "$TARGET_DEVICE" ||
        log_warn "partprobe reported an issue."

    udevadm settle || true

    log_success "ISO written successfully."
}

################################################################################
# Partition Helpers
################################################################################

partition_path_for() {
    local disk="$1"
    local number="$2"

    if [[ "$disk" =~ [0-9]$ ]]; then
        printf '%sp%s\n' "$disk" "$number"
    else
        printf '%s%s\n' "$disk" "$number"
    fi
}

get_partition_table_type() {
    parted -m -s "$TARGET_DEVICE" unit s print |
        awk -F: '
            NR == 2 {
                print $6
                exit
            }
        '
}

partition_exists_in_table() {
    local number="$1"

    parted -m -s "$TARGET_DEVICE" unit s print |
        awk -F: -v number="$number" '
            $1 == number {
                found=1
            }
            END {
                exit !found
            }
        '
}

################################################################################
# Largest Free Region
################################################################################

largest_free_region() {
    parted -m -s "$TARGET_DEVICE" unit s print free 2>/dev/null |
        awk -F: '
            $5 ~ /^free/ {
                start=$2
                end=$3
                size=$4

                gsub(/s/, "", start)
                gsub(/s/, "", end)
                gsub(/s/, "", size)

                if ((size + 0) > max) {
                    max=size + 0
                    best_start=start + 0
                    best_end=end + 0
                }
            }

            END {
                if (max > 0) {
                    printf "%.0f %.0f %.0f\n",
                        best_start, best_end, max
                }
            }
        '
}

################################################################################
# Persistence Partition Creation
################################################################################

create_persistence_partition() {
    local free_info
    local start_sector
    local end_sector
    local free_sectors
    local min_sectors
    local partition_count
    local partition_table
    local confirm
    local attempt
    local parent

    min_sectors=$((2 * 1024 * 1024 * 1024 / 512))

    log_info "Checking existing partition layout..."

    partition_table="$(parted -m -s "$TARGET_DEVICE" unit s print)" ||
        die "Could not read partition table."

    [[ "$(get_partition_table_type)" == "msdos" ]] ||
        die "Expected an MBR/msdos partition table. Refusing to modify the disk."

    partition_exists_in_table 1 ||
        die "Existing ISO partition 1 was not found."

    partition_exists_in_table 2 ||
        die "Existing ISO partition 2 was not found."

    if partition_exists_in_table 3; then
        die "Partition 3 already exists. Refusing to overwrite it."
    fi

    partition_count="$(
        lsblk -nrpo PARTN "$TARGET_DEVICE" |
        awk 'NF {count++} END {print count+0}'
    )"

    (( partition_count < 4 )) ||
        die "No primary partition-table entry is available."

    log_info "Finding the largest unallocated extent..."

    free_info="$(largest_free_region)"

    [[ -n "$free_info" ]] ||
        die "Could not identify unallocated space."

    read -r start_sector end_sector free_sectors <<< "$free_info"

    [[ "$start_sector" =~ ^[0-9]+$ ]] ||
        die "Invalid free-space start sector."

    [[ "$end_sector" =~ ^[0-9]+$ ]] ||
        die "Invalid free-space end sector."

    [[ "$free_sectors" =~ ^[0-9]+$ ]] ||
        die "Invalid free-space size."

    (( end_sector >= start_sector )) ||
        die "Invalid free-space boundaries."

    (( free_sectors >= min_sectors )) ||
        die "Less than 2 GiB of unallocated space is available."

    echo
    log_info "Available free space:"
    printf '  Start sector: %s\n' "$start_sector"
    printf '  End sector:   %s\n' "$end_sector"
    printf '  Free sectors: %s\n' "$free_sectors"

    PERSISTENCE_PART="$(partition_path_for "$TARGET_DEVICE" 3)"

    [[ ! -b "$PERSISTENCE_PART" ]] ||
        die "$PERSISTENCE_PART already exists. Refusing to format it."

    echo
    log_warn "The following operation creates $PERSISTENCE_PART."
    log_warn "The new partition will be formatted as ext4."
    log_warn "Existing ISO partitions are not intentionally modified."

    read -r -p "Type CREATE-PERSISTENCE to continue: " confirm

    [[ "$confirm" == "CREATE-PERSISTENCE" ]] ||
        die "Persistence creation cancelled."

    log_info "Creating persistence partition..."

    parted -a optimal -s "$TARGET_DEVICE" \
        mkpart primary ext4 "${start_sector}s" "${end_sector}s" ||
        die "Could not create persistence partition."

    partprobe "$TARGET_DEVICE" ||
        log_warn "partprobe reported an issue."

    udevadm settle || true

    attempt=0

    while [[ ! -b "$PERSISTENCE_PART" ]] && (( attempt < 15 )); do
        sleep 1
        udevadm settle || true
        ((attempt += 1))
    done

    [[ -b "$PERSISTENCE_PART" ]] ||
        die "New partition $PERSISTENCE_PART was not detected."

    parent="$(lsblk -nro PKNAME "$PERSISTENCE_PART" | head -n1)"

    [[ "/dev/$parent" == "$TARGET_DEVICE" ]] ||
        die "Partition parent mismatch. Refusing to format."

    [[ -z "$(findmnt -rn -S "$PERSISTENCE_PART" -o TARGET)" ]] ||
        die "New partition is mounted. Refusing to format."

    log_info "Formatting $PERSISTENCE_PART as ext4..."

    mkfs.ext4 -F -L persistence "$PERSISTENCE_PART" ||
        die "Could not format persistence partition."

    log_success "Persistence partition created and formatted."

    lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTUUID "$TARGET_DEVICE"
}

################################################################################
# Persistence Configuration and Post-Install Files
################################################################################

write_persistence_files() {
    local workspace_root

    PERSISTENCE_MOUNT="$WORK_DIR/persistence-mount"

    mkdir -p "$PERSISTENCE_MOUNT"

    mount "$PERSISTENCE_PART" "$PERSISTENCE_MOUNT" ||
        die "Could not mount persistence partition."

    printf '/ union\n' > "$PERSISTENCE_MOUNT/persistence.conf"

    workspace_root="$PERSISTENCE_MOUNT/home/kali/.opencode/workspace"

    mkdir -p \
        "$PERSISTENCE_MOUNT/postinstall" \
        "$workspace_root/memory" \
        "$workspace_root/templates" \
        "$workspace_root/backups"

    ########################################################################
    # OpenCode Post-Install Script
    ########################################################################

    cat > "$PERSISTENCE_MOUNT/postinstall/opencode-setup.sh" <<'POSTINSTALL'
#!/usr/bin/env bash

################################################################################
# OpenCode Post-Install Setup
#
# Run after booting Kali Live Persistence.
# Run as the regular Kali user, NOT root.
################################################################################

set -Eeuo pipefail

if [[ "$EUID" -eq 0 ]]; then
    echo "Run this script as your regular Kali user, not root."
    exit 1
fi

command -v curl >/dev/null 2>&1 || {
    echo "curl is required."
    echo "Install it with:"
    echo "  sudo apt update"
    echo "  sudo apt install -y curl"
    exit 1
}

installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT

echo "[INFO] Downloading OpenCode installer..."

curl -fsSL \
    'https://opencode.ai/install.sh' \
    -o "$installer"

echo "[INFO] Running OpenCode installer..."

bash "$installer"

workspace="$HOME/.opencode/workspace"

mkdir -p "$workspace"/{memory,templates,backups}

cat > "$workspace/README.md" <<'EOF'
# Portable Security Workspace

Use only on systems covered by written authorization.

Record:
- Authorization and scope
- Exclusions
- Testing windows
- Evidence
- Findings
- Remediation notes

Keep engagement data backed up.
EOF

cat > "$workspace/templates/recon-network.md" <<'EOF'
# Authorized Network Assessment

- Authorization reference:
- Approved CIDR(s):
- Exclusions:
- Test window:

Run discovery only against the approved range:

    nmap -sn <AUTHORIZED_CIDR> -oA host-discovery

Record findings and evidence below.
EOF

cat > "$workspace/templates/recon-web.md" <<'EOF'
# Authorized Web Assessment

- Authorization reference:
- Approved hostnames:
- Excluded paths/functions:
- Test window:

| URL/component | Observation | Evidence | Impact | Remediation |
|---|---|---|---|---|
EOF

cat > "$workspace/backup-workspace.sh" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

base="$HOME/.opencode/workspace/backups"
stamp="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$base"

tar \
    --exclude='.opencode/workspace/backups' \
    -czf "$base/opencode-$stamp.tar.gz" \
    -C "$HOME" \
    .opencode

printf 'Backup saved: %s\n' "$base/opencode-$stamp.tar.gz"
EOF

chmod 0755 "$workspace/backup-workspace.sh"

echo
echo "[SUCCESS] OpenCode installation and workspace setup completed."
echo "Workspace: $workspace"
echo "Backup:    $workspace/backup-workspace.sh"

POSTINSTALL

    chmod 0755 "$PERSISTENCE_MOUNT/postinstall/opencode-setup.sh"

    ########################################################################
    # Portable Drive Instructions
    ########################################################################

    cat > "$PERSISTENCE_MOUNT/README-PORTABLE-KALI.txt" <<'README'
KALI-LINUX-OPENCODE-PORTABLE-DRIVE

1. Boot from this USB drive or portable SSD.
2. Select Kali Live Persistence in the boot menu.
3. Log in to Kali.
4. Run the OpenCode setup script as your regular user:

   bash /postinstall/opencode-setup.sh

Workspace:
   ~/.opencode/workspace/

Backup:
   ~/.opencode/workspace/backup-workspace.sh

IMPORTANT:

- Persistence is not encrypted by this builder.
- Keep the drive physically secure.
- Shut down cleanly before disconnecting.
- Back up important data to separate storage.
- Test only systems for which you have authorization.
README

    sync

    umount "$PERSISTENCE_MOUNT" ||
        die "Could not unmount persistence partition."

    rmdir "$PERSISTENCE_MOUNT" ||
        die "Could not remove temporary mount directory."

    PERSISTENCE_MOUNT=""

    log_success "Persistence configuration and setup files installed."
}

################################################################################
# Main
################################################################################

main() {
    parse_arguments "$@"

    check_root
    check_dependencies

    initialize_work_directory

    prompt_target_device "$DEVICE_ARGUMENT" "$MODE"

    if [[ "$MODE" == "persistence" ]]; then

        echo
        log_warn "Starting persistence-only recovery."
        log_warn "The existing ISO will not be rewritten."

        create_persistence_partition
        write_persistence_files

        echo
        log_success "Persistence-only recovery completed."

        printf 'Project:               %s\n' "$PROJECT_NAME"
        printf 'Target disk:           %s\n' "$TARGET_DEVICE"
        printf 'Persistence partition: %s\n' "$PERSISTENCE_PART"

        echo
        echo "Next steps:"
        echo "  1. Safely eject the drive."
        echo "  2. Boot Kali Live Persistence."
        echo "  3. Run:"
        echo "     bash /postinstall/opencode-setup.sh"

        return 0
    fi

    prompt_iso_configuration
    prepare_iso

    echo
    log_info "Project: $PROJECT_NAME"
    log_info "Target:  $TARGET_DEVICE"
    log_info "ISO:     $ISO_PATH"

    log_warn "The next operation erases the target disk."

    local final_confirm

    read -r -p "Type YES to write the ISO and create persistence: " final_confirm

    [[ "$final_confirm" == "YES" ]] ||
        die "Cancelled before disk write."

    write_iso
    create_persistence_partition
    write_persistence_files

    echo
    log_success "Kali Live portable drive build completed."

    printf 'Project:               %s\n' "$PROJECT_NAME"
    printf 'Target disk:           %s\n' "$TARGET_DEVICE"
    printf 'Persistence partition: %s\n' "$PERSISTENCE_PART"

    echo
    echo "Next steps:"
    echo "  1. Safely eject the drive."
    echo "  2. Boot using Kali Live Persistence."
    echo "  3. Run:"
    echo "     bash /postinstall/opencode-setup.sh"

    log_warn "Persistence is not encrypted."
}

main "$@"