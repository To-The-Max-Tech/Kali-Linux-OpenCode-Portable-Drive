```text
══════════════════════════════════════════════════════════════════════
             KALI-LINUX-OPENCODE-PORTABLE-DRIVE
                 PORTABLE SECURITY ASSESSMENT
                       USB EDITION
══════════════════════════════════════════════════════════════════════


PROJECT OVERVIEW
══════════════════════════════════════════════════════════════════════

Kali-Linux-OpenCode-Portable-Drive is a portable security
assessment environment built around Kali Linux and OpenCode.

The project combines an organized security assessment workspace,
AI-assisted development, selected security tools, optional
integrations, local AI capabilities, and configuration backups.

PRIMARY COMPONENTS:

  1. Kali Linux
  2. OpenCode AI Coding Agent
  3. CLI Agent repository and optional integration
  4. Kali MCP repository and optional integration
  5. OpenCode Shannon Plugin
  6. Bun Runtime
  7. Optional Docker Integration
  8. Optional Ollama Local AI
  9. Portable Assessment Workspace
 10. Configuration Backup Utilities
 11. Authorized Endpoint Assessment Utilities


IMPORTANT PROJECT LIMITATIONS
══════════════════════════════════════════════════════════════════════

Not every component is installed or configured automatically.

The installation utility:

  - Installs OpenCode.
  - Installs Bun.
  - Clones or updates configured project repositories.
  - Prepares Python environments when supported by a repository.
  - Installs Shannon dependencies when package.json is available.
  - Checks for Docker and optionally builds the Shannon image.
  - Optionally installs Ollama.
  - Creates the OpenCode workspace.
  - Preserves existing OpenCode configuration.

Third-party MCP server commands, plugin registration, and
CLI Agent commands must be verified against the actual installed
repository versions.

The installer does not guarantee that every optional integration
is operational simply because its repository was downloaded.


══════════════════════════════════════════════════════════════════════
1. BOOT INSTRUCTIONS
══════════════════════════════════════════════════════════════════════

1. Insert the Kali Linux USB drive.

2. Boot your computer from the USB device.

3. Select the appropriate Kali Live Persistence boot option.

4. Allow Kali Linux to initialize.

5. Log in using your configured Kali account.

DEFAULT KALI LIVE CREDENTIALS:

  Username: kali
  Password: kali

These are commonly used default credentials. Your installation
may use different credentials if they were changed.

PERSISTENCE:

For changes to survive rebooting, select the Live Persistence
boot option.

For sensitive work, consider encrypted persistence.

IMPORTANT:

Persistence is not a substitute for backups. Protect the USB
drive and maintain separate backups of important information.


══════════════════════════════════════════════════════════════════════
2. FIRST-BOOT INSTALLATION
══════════════════════════════════════════════════════════════════════

After booting into Kali:

STEP 1 - Open a terminal.

STEP 2 - Navigate to the directory containing the installer.

Example:

  cd /path/to/project

STEP 3 - Make the installer executable.

  chmod +x opencode-setup.sh

STEP 4 - Run the installer as your normal user.

  ./opencode-setup.sh

DO NOT run the entire installer using sudo.

The installer uses sudo when administrator privileges are
needed for system package installation.

STEP 5 - Follow the installation prompts.

The installer prepares:

  - OpenCode
  - Bun
  - CLI Agent repository and Python environment, when supported
  - Kali MCP repository and Python environment, when supported
  - Shannon Plugin dependencies, when supported
  - Optional Docker image build
  - Optional Ollama installation

STEP 6 - Reload