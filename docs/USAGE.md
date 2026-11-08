# Kali-Linux-OpenCode-Portable-Drive
## Usage Guide

Welcome to **Kali-Linux-OpenCode-Portable-Drive**.

This project provides a portable Kali Linux security assessment environment with persistent storage, OpenCode, an organized assessment workspace, optional AI integrations, endpoint assessment utilities, and backup tools.

This guide covers:

1. First boot and installation
2. OpenCode usage
3. Authorized network reconnaissance
4. Web application assessment
5. Endpoint assessment packages
6. Workspace and engagement management
7. Memory and documentation
8. Backups and recovery
9. Optional AI integrations
10. Security practices and troubleshooting

> **Important:** This guide documents the functionality provided by the project scripts reviewed so far. Optional integrations and third-party commands must be verified against their installed versions. The project does not automatically provide a remote-node gateway or remote command execution service.

---

# 1. Quick Reference

### Boot and OpenCode

```bash
# Check OpenCode installation
opencode --version

# Start OpenCode
opencode

# Display OpenCode help
opencode --help
```

### Workspace Shortcuts

The setup script creates workspace-related shell aliases.

```bash
# Open the workspace
oc-workspace

# Open backups
oc-backups
```

Additional shortcuts may be available if configured in your shell.

Reload your shell configuration after installation:

```bash
source ~/.bashrc
```

### Workspace Location

```bash
~/.opencode/workspace/
```

### Important Project Scripts

```text
build-kali-portable.sh
opencode-setup.sh
deploy-node.sh
backup-config.sh
```

---

# 2. First Boot

Follow these instructions after building your portable Kali installation.

## Step 1 — Boot Kali

1. Connect your portable USB drive or SSD.
2. Restart the computer.
3. Enter the BIOS/UEFI boot menu.
4. Select your portable storage device.
5. Select the appropriate Kali Live Persistence option.

## Step 2 — Log In

Use the credentials configured for your Kali installation.

Common default Kali Live credentials are:

```text
Username: kali
Password: kali
```

Your installation may use different credentials if they have been changed.

## Step 3 — Locate the Post-Installation Script

The USB builder creates:

```text
/postinstall/opencode-setup.sh
```

Run the installer as your normal Kali user:

```bash
bash /postinstall/opencode-setup.sh
```

**Do not run the entire installer using sudo.**

The installer requests administrator privileges when required for system package installation.

If you copied the installer into your home directory instead:

```bash
bash ~/opencode-setup.sh
```

## Step 4 — Reload Your Shell

```bash
source ~/.bashrc
```

## Step 5 — Verify OpenCode

```bash
opencode --version
```

## Step 6 — Start OpenCode

```bash
opencode
```

The installer creates the workspace under:

```bash
~/.opencode/workspace/
```

Installation logs are stored in:

```bash
~/.opencode/workspace/logs/
```

---

# 3. OpenCode Basics

OpenCode is the primary AI-assisted development interface in this project.

## Start OpenCode

```bash
opencode
```

## Check the Installed Version

```bash
opencode --version
```

## Display Available Commands

```bash
opencode --help
```

For help with a particular command:

```bash
opencode <command> --help
```

## Open the Workspace

```bash
cd ~/.opencode/workspace/
```

## Recommended Workflow

1. Start OpenCode.
2. Open or select your assessment project.
3. Review the engagement scope.
4. Provide the relevant assessment documentation.
5. Ask OpenCode to help organize findings, explain results, or prepare reports.
6. Review AI-generated commands before executing them.

AI-generated recommendations should always be checked for accuracy, authorization, and operational impact.

---

# 4. Authorized Network Reconnaissance

Use these workflows only against systems and networks you own or have explicit permission to assess.

## 4.1 Prepare an Engagement

Create a dedicated engagement directory:

```bash
mkdir -p ~/.opencode/workspace/engagements/client-assessment-01
```

Create directories for the assessment:

```bash
cd ~/.opencode/workspace/engagements/client-assessment-01

mkdir -p scope reconnaissance enumeration findings evidence reports
```

Document the authorized target range before scanning.

## 4.2 Host Discovery

Example authorized network:

```bash
nmap -sn 192.168.1.0/24 -oN reconnaissance/live-hosts.txt
```

Replace the example network with the actual authorized CIDR.

## 4.3 Service Detection

For an explicitly authorized target:

```bash
nmap -sV -sC -oN enumeration/service-scan.txt <AUTHORIZED_TARGET>
```

## 4.4 Full TCP Port Scan

```bash
nmap -p- -T4 -oN enumeration/full-port-scan.txt <AUTHORIZED_TARGET>
```

A full port scan can generate substantial network traffic. Confirm that the engagement permits this scan type before running it.

## 4.5 Document Findings

Store findings in the engagement directory:

```text
engagements/
└── client-assessment-01/
    ├── scope/
    ├── reconnaissance/
    ├── enumeration/
    ├── findings/
    ├── evidence/
    └── reports/
```

Example findings file:

```bash
cat > findings/network-recon.md <<'EOF'
# Network Reconnaissance

## Engagement
Client Assessment 01

## Authorization
Document the authorization reference.

## Scope
Document the approved network range.

## Findings
Record discovered hosts and services.

## Evidence
Reference collected evidence.

## Next Steps
Document approved follow-up activities.
EOF
```

---

# 5. Web Application Security Assessment

Use this workflow for web applications within an approved assessment scope.

## 5.1 Prepare the Target

Document:

- Authorized application URL
- Approved testing window
- Permitted testing methods
- Authentication requirements
- Prohibited activities

## 5.2 Directory Enumeration

Example:

```bash
gobuster dir \
  -u https://authorized.example \
  -w /usr/share/wordlists/dirb/common.txt \
  -o gobuster-results.txt
```

Use only an authorized application URL.

## 5.3 Web Server Assessment

Example:

```bash
nikto \
  -h https://authorized.example \
  -output nikto-results.txt
```

Check the installed tool's help output if its options differ:

```bash
nikto -Help
```

## 5.4 Document Results

Save results under the engagement:

```text
engagements/client-assessment-01/
└── findings/
    ├── web-assessment.md
    ├── gobuster-results.txt
    └── nikto-results.txt
```

Review scanner results manually. Automated findings can contain false positives and should be verified before being reported.

---

# 6. Endpoint Assessment Packages

The project includes `deploy-node.sh`, which generates a portable endpoint assessment package.

**Important:** Despite the script's filename, this utility does not install a remote agent or establish a connection to a gateway. It generates local assessment utilities for Linux and Windows endpoints.

## 6.1 Generate a Package

From the directory containing `deploy-node.sh`:

```bash
chmod +x deploy-node.sh
```

Generate a package:

```bash
./deploy-node.sh 192.168.1.100 Lab-Endpoint-01
```

The supplied IP address is recorded as package metadata. The generator does not remotely contact that address.

The script creates a timestamped package directory.

## 6.2 Package Contents

```text
node-deploy-YYYYMMDD-HHMMSS/
├── run-node.sh
├── run-node.ps1
├── deployment.conf
├── DEPLOY-README.txt
└── SHA256SUMS
```

### Linux Utility

`run-node.sh` collects local endpoint information, including:

- Operating system information
- CPU and memory information
- Disk information
- Network interfaces
- Network routes
- DNS configuration
- Listening TCP services
- Availability of selected assessment tools

### Windows Utility

`run-node.ps1` collects local endpoint information, including:

- Computer information
- Current user
- CPU and memory information
- Storage volumes
- IP configuration
- IPv4 routes
- DNS configuration
- Listening TCP ports

## 6.3 Run on Linux

On an authorized Linux endpoint:

```bash
chmod +x run-node.sh

./run-node.sh
```

## 6.4 Run on Windows

On an authorized Windows endpoint:

```powershell
powershell.exe -NoProfile -File .\run-node.ps1
```

## 6.5 Verify Package Integrity

From the generated package directory:

```bash
sha256sum -c SHA256SUMS
```

The assessment utilities save their reports locally.

They do not automatically transmit the collected information to the Kali workstation.

Transfer reports through an approved channel and protect them as sensitive assessment data.

---

# 7. Workspace Management

The primary workspace is:

```bash
~/.opencode/workspace/
```

Recommended structure:

```text
workspace/
├── memory/
├── templates/
├── backups/
├── logs/
├── findings/
├── reports/
├── evidence/
├── engagements/
├── tools/
├── scripts/
├── config/
└── assessments/
```

## 7.1 Create an Engagement Directory

```bash
mkdir -p ~/.opencode/workspace/engagements/client-assessment-01
```

Create its subdirectories:

```bash
cd ~/.opencode/workspace/engagements/client-assessment-01

mkdir -p scope reconnaissance enumeration findings evidence reports
```

## 7.2 Copy an Assessment Template

The installer may create the following templates:

```text
templates/
├── recon-network.md
└── recon-web.md
```

Copy a template:

```bash
cp ~/.opencode/workspace/templates/recon-network.md \
  ~/.opencode/workspace/engagements/client-assessment-01/
```

Customize the copied template for the engagement.

Additional templates can be created for wireless assessments, configuration reviews, and other authorized assessment activities.

---

# 8. Memory and Documentation

Use Markdown files to organize assessment notes, operational documentation, and project progress.

Memory directory:

```bash
~/.opencode/workspace/memory/
```

## 8.1 Create Today's Memory File

```bash
mkdir -p ~/.opencode/workspace/memory

cat > ~/.opencode/workspace/memory/$(date +%Y-%m-%d).md <<EOF
# $(date +%Y-%m-%d)

## Engagement
Client Name

## Authorization
Reference to written authorization.

## Scope
Approved targets and testing restrictions.

## Findings
-

## Commands Executed
-

## Identified Issues
-

## Next Steps
-
EOF
```

## 8.2 Recommended Memory Organization

```text
workspace/
├── memory/
│   ├── 2026-11-08.md
│   └── 2026-11-09.md
│
├── templates/
│   ├── recon-network.md
│   └── recon-web.md
│
├── engagements/
│   └── client-assessment-01/
│
├── findings/
├── reports/
├── evidence/
├── logs/
└── backups/
```

Keep client-specific notes and evidence in the appropriate engagement directory.

Do not store API keys, passwords, or other secrets in ordinary Markdown notes.

---

# 9. Backup and Recovery

**Always back up important configuration and assessment data before removing or reformatting portable storage.**

## 9.1 Local Backup

The project includes:

```text
backup-config.sh
```

From the directory containing the script:

```bash
chmod +x backup-config.sh

./backup-config.sh
```

The script creates a timestamped backup under:

```bash
~/.opencode/workspace/backups/
```

The backup can include OpenCode configuration, workspace data, and selected OpenCode directories when present.

Review the script's exclusions to understand which files are omitted.

## 9.2 Optional Remote Backup

The backup script supports an optional SSH/rsync destination.

Example:

```bash
./backup-config.sh user@remote-host
```

A specific remote directory can also be supplied:

```bash
./backup-config.sh user@remote-host backups/my-opencode
```

The remote host must be accessible through SSH and support rsync.

## 9.3 Verify a Backup

List available backups:

```bash
ls -lah ~/.opencode/workspace/backups/
```

Enter the backup directory:

```bash
cd ~/.opencode/workspace/backups/<BACKUP_DIRECTORY>
```

Verify checksums:

```bash
sha256sum -c SHA256SUMS
```

## 9.4 Recovery

The backup utility creates backups; it does not provide an automatic restore operation.

For a manual recovery:

1. Identify the backup to restore.
2. Verify its checksum manifest.
3. Make a separate backup of the current data.
4. Close OpenCode and related processes.
5. Restore the required files to their original locations.
6. Preserve appropriate file permissions.
7. Review restored configuration.
8. Start OpenCode and verify the restored workspace.

**Security note:** Backups can contain credentials, API keys, session data, and client information. Restrict access and use encrypted storage when appropriate.

---

# 10. Optional CLI Agent Integration

The project setup script can clone the CLI Agent repository and prepare a Python environment when the repository supports installation through `pyproject.toml`.

Repository:

```bash
~/cli-agent/
```

Virtual environment:

```bash
~/cli-agent/.venv/
```

## 10.1 Activate the Environment

```bash
source ~/cli-agent/.venv/bin/activate
```

## 10.2 Inspect the Installation

```bash
python --version

python -m pip list
```

## 10.3 Check Available Commands

Consult the installed repository documentation and inspect its available entry points.

Do not assume commands such as `agent-chat`, `agent-ask`, or `agent chat` are available without verifying the installed version.

The CLI Agent's model-provider syntax also depends on its implementation and configuration.

---

# 11. Optional Kali MCP Integration

The setup script can clone the Kali MCP repository and prepare a Python environment when supported by the repository.

Repository:

```bash
~/kali-mcp/
```

Virtual environment:

```bash
~/kali-mcp/.venv/
```

Activate it:

```bash
source ~/kali-mcp/.venv/bin/activate
```

Inspect installed packages:

```bash
python -m pip list
```

Before configuring OpenCode:

1. Review the Kali MCP repository documentation.
2. Identify its actual server entry point.
3. Confirm the supported transport.
4. Review required permissions.
5. Configure the appropriate MCP entry in OpenCode.
6. Test the connection.

The project installer deliberately does not assume a particular Python module name or automatically register an unverified MCP command.

---

# 12. Shannon Plugin

The project setup script can prepare the Shannon plugin repository when its package configuration is available.

Repository:

```bash
~/opencode-shannon-plugin/
```

Install dependencies:

```bash
cd ~/opencode-shannon-plugin

bun install
```

Build:

```bash
bun run build
```

Optional Docker image build:

```bash
BUILD_SHANNON_DOCKER=1 ./opencode-setup.sh
```

Docker must already be installed for the optional image build.

Check Docker:

```bash
docker --version
```

Check Docker availability:

```bash
docker info
```

The setup script does not automatically register Shannon in OpenCode. Follow the plugin's current documentation for the correct configuration procedure.

Use testing features only within explicitly authorized scopes.

---

# 13. Ollama — Local AI Models

Ollama provides local model inference.

The project setup script supports optional Ollama installation.

## 13.1 Install Ollama

```bash
INSTALL_OLLAMA=1 ./opencode-setup.sh
```

## 13.2 Install and Download Default Models

```bash
INSTALL_OLLAMA=1 PULL_OLLAMA_MODELS=1 ./opencode-setup.sh
```

## 13.3 Download Additional Models

```bash
ollama pull llama3

ollama pull codellama

ollama pull mistral
```

## 13.4 List Models

```bash
ollama list
```

## 13.5 Run a Model

```bash
ollama run llama3
```

## 13.6 Check Version

```bash
ollama --version
```

Model downloads require internet access and can consume substantial storage space.

After downloading, local inference can generally operate without internet access, subject to hardware and model requirements.

Installing Ollama does not automatically configure OpenCode or CLI Agent to use a particular model. Configure each application according to its own documentation.

---

# 14. Security Best Practices

## Before an Engagement

- [ ] Verify written authorization.
- [ ] Confirm the authorized assessment scope.
- [ ] Document approved target addresses and domains.
- [ ] Confirm permitted assessment methods.
- [ ] Verify required tools are installed.
- [ ] Test the portable environment.
- [ ] Back up important configuration.
- [ ] Protect credentials and API keys.

## During an Engagement

- [ ] Restrict scans to approved targets.
- [ ] Document commands and assessment activities.
- [ ] Protect collected evidence.
- [ ] Use secure channels for transferring reports.
- [ ] Review AI-generated commands before execution.
- [ ] Avoid accessing unrelated systems or data.
- [ ] Respect operational restrictions and testing windows.

## After an Engagement

- [ ] Complete assessment documentation.
- [ ] Verify findings before reporting.
- [ ] Back up reports and evidence securely.
- [ ] Remove temporary files according to the retention policy.
- [ ] Review stored credentials and API keys.
- [ ] Safely shut down before disconnecting portable storage.

---

# 15. Troubleshooting

## 15.1 OpenCode Command Not Found

Check the installation:

```bash
command -v opencode

opencode --version
```

Reload the shell:

```bash
source ~/.bashrc
```

If OpenCode is still unavailable, review the installation output and confirm that its installation directory is included in PATH.

## 15.2 Bun Command Not Found

Check:

```bash
command -v bun

~/.bun/bin/bun --version
```

If necessary, add Bun to PATH:

```bash
export PATH="$HOME/.bun/bin:$PATH"
```

## 15.3 Python Environment Problems

Check the CLI Agent environment:

```bash
~/cli-agent/.venv/bin/python --version
```

Check the Kali MCP environment:

```bash
~/kali-mcp/.venv/bin/python --version
```

If installation fails, review the relevant repository's documentation and dependency requirements.

## 15.4 Docker Problems

Check the Docker executable:

```bash
docker --version
```

Check whether the Docker service is available:

```bash
docker info
```

Docker may require a running service and appropriate permissions.

## 15.5 Ollama Problems

Check:

```bash
ollama --version

ollama list
```

If a model cannot run, verify that it is installed and that the system has sufficient available memory and storage.

## 15.6 Persistence Is Not Saving

Check storage devices:

```bash
lsblk -f
```

Check mounted filesystems:

```bash
findmnt
```

Locate the mounted persistence partition and inspect its configuration file.

The expected contents of `persistence.conf` are:

```text
/ union
```

The persistence partition must also be selected through the appropriate Kali Live Persistence boot option.

Do not assume that the persistence partition is always mounted at `/persistence`. Its mount point can vary.

## 15.7 Installation Logs

Review the setup logs:

```bash
ls -lah ~/.opencode/workspace/logs/
```

Inspect a specific log:

```bash
less ~/.opencode/workspace/logs/<LOG_FILENAME>
```

---

# 16. Useful Shell Shortcuts

The installer creates workspace-related aliases in `~/.bashrc`.

Reload them:

```bash
source ~/.bashrc
```

Open the workspace:

```bash
oc-workspace
```

Open backups:

```bash
oc-backups
```

You can add additional personal aliases.

For example, add an authorized Nmap logging alias:

```bash
alias nmap-log='nmap -oN "$HOME/nmap-$(date +%Y%m%d-%H%M%S).txt"'
```

Reload:

```bash
source ~/.bashrc
```

Example:

```bash
nmap-log -sV <AUTHORIZED_TARGET>
```

---

# 17. Project Information

**Project Name:**

```text
Kali-Linux-OpenCode-Portable-Drive
```

**Platform:**

```text
Kali Linux
```

**Storage:**

```text
USB Flash Drive / Portable SSD
```

**Primary AI Interface:**

```text
OpenCode
```

**Optional Integrations:**

```text
CLI Agent
Kali MCP
Shannon Plugin
Ollama
Docker
```

**Workspace:**

```text
~/.opencode/workspace/
```

**Primary Purpose:**

```text
Portable, persistent, AI-assisted security assessment,
development, and documentation.
```

**Repository:**

https://github.com/To-The-Max-Tech/Kali-OpenCode-Portable-Drive

**Maintainer:**

@japost1985

---

# 18. Documentation and Community

OpenCode:

https://opencode.ai/

OpenCode Documentation:

https://opencode.ai/docs/

Kali Linux:

https://www.kali.org/

Ollama:

https://ollama.com/

OpenCode Community:

https://discord.gg/opencode

---

# Final Reminder

Kali-Linux-OpenCode-Portable-Drive is intended for authorized security research, penetration testing, vulnerability assessment, development, and defensive security operations.

Always obtain permission before testing systems, networks, or devices that you do not own.

**Build responsibly. Test legally. Document everything.**

Happy Hacking!