![](https://raw.githubusercontent.com/To-The-Max-Tech/Kali-Linux-OpenCode-Portable-Drive/refs/heads/main/docs/kali_linux_opencode_portable_pentest_drive_1280x640.png)

# 🖥️ Kali-Linux-OpenCode-Portable-Drive

**Your portable AI-assisted security assessment environment. Boot from USB or external SSD. Work anywhere. Keep your tools and configurations with you.**

Kali-Linux-OpenCode-Portable-Drive is a portable security assessment platform that combines **Kali Linux Live**, **OpenCode**, MCP integrations, optional local AI capabilities, and persistent storage on a USB drive or external SSD.

The project is designed to help security professionals organize authorized penetration tests, streamline assessment workflows, integrate AI-assisted tooling, and carry their configurations and documentation between compatible systems.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Features](#-features)
- [Repository Structure](#-repository-structure)
- [AI Tool Suite](#-ai-tool-suite)
- [Hardware Requirements](#-hardware-requirements)
- [Quick Start](#-quick-start)
- [USB Persistence](#-usb-persistence)
- [OpenCode MCP Configuration](#-opencode-mcp-configuration)
- [Security Assessment Categories](#-security-assessment-categories)
- [Architecture](#-architecture)
- [USB vs. Portable SSD](#-usb-vs-portable-ssd)
- [Security Best Practices](#-security-best-practices)
- [Documentation](#-documentation)
- [Credits](#-credits)
- [Project Roadmap](#-project-roadmap)
- [Contact and Community](#-contact-and-community)
- [Disclaimer](#-disclaimer)

---

## 📝 Project Overview

Traditional penetration-testing environments can require extensive configuration, multiple machines, and repeated setup.

Kali-Linux-OpenCode-Portable-Drive aims to simplify that process by providing a portable Linux environment with persistent storage and an extensible AI tooling ecosystem.

| Challenge                       | Project Solution                         |
| ------------------------------- | ---------------------------------------- |
| Tools scattered across machines | Portable, centralized environment        |
| Repetitive reconnaissance       | AI-assisted workflow integration         |
| Manual documentation            | Reusable engagement documentation        |
| Configuration loss              | Persistent storage                       |
| Dependence on cloud AI          | Optional local AI support through Ollama |
| Complex tool integration        | Model Context Protocol (MCP) integration |
| Multiple testing environments   | Bootable USB and portable SSD support    |

### Project Components

The platform brings together:

- Kali Linux Live
- OpenCode
- CLI Agent
- Kali MCP
- OpenCode Shannon Plugin
- Ollama (optional local AI runtime)
- Persistent storage
- Security assessment scripts and workflows
- Engagement documentation and configuration backups

Designed for security researchers, penetration testers, red teams, and cybersecurity professionals conducting authorized security assessments.

---

## 📦 Features

### 🐉 Kali Linux

The foundation of the portable environment.

- Kali Linux Live environment.
- Access to Kali security assessment tools.
- Network and service discovery.
- Web application security testing.
- Wireless security assessment.
- Password auditing tools.
- Linux command-line utilities.

Available tools depend on the Kali image and installed packages.

### 🧠 OpenCode

OpenCode provides the primary AI-assisted development and automation interface.

- AI-powered command-line interface.
- Terminal-based interaction.
- Web interface support.
- MCP server integration.
- Plugin support.
- Configurable AI providers and models.
- Agent-assisted workflows.

### 🤖 CLI Agent

An additional AI assistant integration intended to support:

- Alternative AI interaction workflows.
- Local model integrations.
- Ollama connectivity.
- MCP-compatible workflows, where supported by the installed version.

### 🔌 Kali MCP

MCP-based integration for supported security assessment tools.

Potential capabilities include:

- Network reconnaissance.
- DNS enumeration.
- Web application analysis.
- Vulnerability assessment.
- Session management.
- Assessment documentation.

Actual tools and operations depend on the installed Kali MCP version and its configuration.

### 🛡️ Shannon Plugin

An additional OpenCode security automation integration.

Depending on the installed plugin version and configuration, capabilities may include:

- AI-assisted security assessment workflows.
- Reconnaissance assistance.
- Browser-based testing.
- Vulnerability discovery support.
- Security reporting assistance.

### 💾 Persistent Storage

The portable environment is designed to retain:

- User configurations.
- OpenCode settings.
- MCP configurations.
- Custom scripts.
- Engagement documentation.
- Project files.
- Optional AI models, subject to available storage.

**Important:** Persistence is not the same as encryption. The ext4 persistence partition is not encrypted by default.

### 💽 Portable Storage Support

Designed for:

- USB flash drives.
- USB 3.0 and newer storage devices.
- External USB SSDs.
- Portable NVMe SSD enclosures.

An external SSD is recommended for larger installations, Docker workloads, and local AI models.

---

## 📁 Repository Structure

The following represents the intended project organization. Individual component directories and files may vary depending on which integrations have been installed or added.

```text
Kali-Linux-OpenCode-Portable-Drive/
│
├── docs/
│   ├── SECURITY.md
│   └── USAGE.md
│
├── kali-mcp/
│   ├── kali-mcp-server/
│   ├── sessions/
│   ├── tests/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── install_check.py
│
├── opencode-shannon-plugin/
│   └── plugin files and configuration
│
├── postinstall/
│   ├── opencode-setup.sh
│   └── README-OPENCODE.txt
│
├── scripts/
│   ├── backup-config.sh
│   └── deploy-node.sh
│
├── build-kali-portable.sh
├── LICENSE
└── README.md
```

Additional directories may be created for local AI models, engagement data, CLI Agent files, and other integrations.

---

## 🤖 AI Tool Suite

### 1. OpenCode

OpenCode is the primary AI-assisted interface.

Start the terminal interface:

```bash
opencode
```

Start the web interface:

```bash
opencode web
```

The available commands and features depend on the installed OpenCode version and configured providers.

Official website: [https://opencode.ai/](https://opencode.ai/)

### 2. CLI Agent

CLI Agent is an additional AI integration.

Its commands depend on the particular CLI Agent version installed. Consult that component's documentation for supported commands, model selection, and MCP configuration.

### 3. Kali MCP

Kali MCP provides an integration layer between supported security tools and MCP-compatible clients.

Example assessment activities include:

- Authorized host discovery.
- Service enumeration.
- DNS information gathering.
- Web application assessment.
- Findings documentation.

The following are illustrative workflow descriptions, not guaranteed built-in slash commands:

```text
Identify services on an authorized test host.
Enumerate DNS records for an authorized test domain.
Discover active hosts within an approved assessment range.
Document findings from an authorized web application assessment.
```

Verify the actual tool names and parameters exposed by your installed MCP server before using them.

### 4. Shannon Plugin

The Shannon Plugin provides additional security assessment integration with OpenCode.

Potential workflows include:

- Reconnaissance assistance.
- Security testing support.
- Vulnerability analysis.
- Assessment documentation.

Plugin commands and capabilities depend on the installed version. Refer to the plugin's documentation for its actual command syntax.

### 5. Ollama (Optional)

Ollama provides local AI model execution.

This can reduce dependence on cloud AI providers, but local inference requires sufficient RAM, storage, and processing resources.

Official website: [https://ollama.com/](https://ollama.com/)

---

## 🖥️ Hardware Requirements

### Recommended Hardware

| Component | Minimum                   | Recommended             |
| --------- | ------------------------- | ----------------------- |
| Storage   | 64 GB                     | 256 GB–1 TB SSD         |
| RAM       | 8 GB                      | 16–32 GB                |
| Processor | x86-64 compatible         | Modern multi-core CPU   |
| USB       | USB 3.0                   | USB 3.2 or external SSD |
| Internet  | Initial setup and updates | Broadband connection    |

Local AI models may require considerably more memory and storage.

For larger models, consider a system with additional RAM and suitable GPU acceleration.

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/To-The-Max-Tech/Kali-OpenCode-Portable-Drive.git Kali-Linux-OpenCode-Portable-Drive

cd Kali-Linux-OpenCode-Portable-Drive
```

The local directory uses the updated project name. The GitHub repository URL above retains its existing repository slug.

### 2. Review the Builder

The project builder is:

```text
build-kali-portable.sh
```

Review its options before running it:

```bash
chmod +x build-kali-portable.sh

./build-kali-portable.sh --help
```

### ⚠️ Important: Disk Destruction Warning

The builder's default ISO-installation mode is intended to write Kali Linux to a selected storage device. This can erase existing partitions and data.

Before using that mode:

1. Identify the correct target device.
2. Confirm its capacity and model.
3. Back up important files.
4. Read the builder's prompts and options.
5. Never assume that `/dev/sdb` or `/dev/sdc` is your USB drive.

Identify connected storage devices:

```bash
lsblk -o NAME,SIZE,MODEL,TRAN,TYPE,FSTYPE,MOUNTPOINT
```

**Do not run the default installation mode against a drive containing data you want to preserve.**

### 3. Build the Portable Environment

For a new installation, follow the builder's instructions:

```bash
sudo ./build-kali-portable.sh
```

The builder's default installation mode is intended to prepare the selected device for Kali Live and persistent storage.

The exact available options are defined by the installed builder script. Use `--help` to review them.

### 4. Boot Kali Linux

1. Connect the USB drive or external SSD.
2. Open the computer's boot menu.
3. Select the external storage device.
4. Select the appropriate Kali Live persistence option, if available.
5. Complete the initial system setup.

Boot compatibility depends on the computer's firmware, boot configuration, and the Kali image.

### 5. Install or Configure Project Components

The post-installation script is located in the persistence partition:

```text
/postinstall/opencode-setup.sh
```

After booting the Kali environment with persistence enabled, run:

```bash
sudo bash /postinstall/opencode-setup.sh
```

The script is intended to configure the OpenCode environment and associated setup tasks.

Additional integrations such as CLI Agent, Kali MCP, Shannon Plugin, and Ollama may require separate installation or configuration, depending on the current script and component versions.

---

## 💾 USB Persistence

The project supports Kali Live persistence through a dedicated storage partition.

A typical layout looks like this:

| Partition               | Purpose                                |
| ----------------------- | -------------------------------------- |
| Kali Live ISO partition | Bootable Kali environment              |
| Boot support partition  | Boot-related files                     |
| Persistence partition   | Persistent user data and configuration |

The persistence partition uses an ext4 filesystem.

Its configuration file should contain:

```text
/ union
```

This tells Kali persistence to retain changes across sessions.

### Persistence-Only Recovery

If Kali Live is already installed and you need to prepare persistence without rewriting the ISO, the builder supports a persistence-only mode:

```bash
sudo ./build-kali-portable.sh --persistence-only
```

**Important:** This mode is intended to preserve the existing Kali ISO partitions and prepare persistence in available space. Carefully review the script's prompts and verify the target disk before proceeding.

Do not use the default ISO-installation mode as a substitute for persistence-only recovery.

### Verify Persistence

Check the partition layout:

```bash
lsblk -f
```

Check the persistence configuration:

```bash
cat /media/kali/persistence/persistence.conf
```

The mount path may differ on your system. Use `lsblk -f` to identify the actual persistence mount point.

---

## 🔧 OpenCode MCP Configuration

OpenCode supports MCP server configuration.

The following is an illustrative configuration template. It is not a guarantee that the example server paths or entry points exist in every installation.

Example:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "kali-mcp": {
      "type": "local",
      "command": [
        "/path/to/kali-mcp/.venv/bin/python",
        "-m",
        "kali_mcp_server"
      ],
      "enabled": true
    }
  }
}
```

Update the following to match your installation:

- Python executable path.
- MCP server entry point.
- Virtual environment location.
- Required environment variables.
- Server-specific arguments.

Do not copy example paths without verifying that the corresponding files exist.

For additional information, consult the official OpenCode documentation:

[https://opencode.ai/docs/](https://opencode.ai/docs/)

---

## 🛠️ Security Assessment Categories

The integrated environment is intended to support several authorized assessment categories.

| Category                 | Example Activities                             |
| ------------------------ | ---------------------------------------------- |
| Network Security         | Host discovery and service enumeration         |
| Web Security             | Application analysis and security testing      |
| DNS Security             | DNS and subdomain enumeration                  |
| Vulnerability Assessment | Identification and documentation of weaknesses |
| Wireless Security        | Authorized wireless assessments                |
| Password Auditing        | Password-strength and hash auditing            |
| Reporting                | Findings documentation and report generation   |

Tool availability depends on the Kali installation, installed dependencies, and configured MCP servers.

---

## 🏗️ Architecture

The platform is organized into four main layers.

```text
┌──────────────────────────────────────────────────┐
│              PORTABLE STORAGE DEVICE             │
│                                                  │
│          USB Flash Drive / External SSD          │
├──────────────────────────────────────────────────┤
│                                                  │
│              BOOT AND OPERATING SYSTEM           │
│                                                  │
│              Kali Linux Live                     │
│              Boot Support                        │
│              Persistent Storage                  │
│                                                  │
├──────────────────────────────────────────────────┤
│                  USER ENVIRONMENT                │
│                                                  │
│              ~/.config/opencode/                 │
│              ~/.opencode/                        │
│              ~/cli-agent/                        │
│              ~/kali-mcp/                         │
│              ~/opencode-shannon-plugin/          │
│              ~/engagements/                      │
│                                                  │
├──────────────────────────────────────────────────┤
│                 AI INTEGRATION                   │
│                                                  │
│                   OpenCode                       │
│                      │                           │
│          ┌───────────┼────────────┐               │
│          │           │            │               │
│       CLI Agent   Kali MCP   Shannon Plugin      │
│          │           │            │               │
│          └───────────┴────────────┘               │
│                      │                           │
│                    Ollama                        │
│                 (Optional)                       │
│                                                  │
├──────────────────────────────────────────────────┤
│             SECURITY ASSESSMENT WORKFLOWS        │
│                                                  │
│              Network Reconnaissance              │
│              Web Application Assessment         │
│              Vulnerability Analysis              │
│              Security Documentation              │
│              Assessment Reporting                │
│                                                  │
└──────────────────────────────────────────────────┘
```

This is a logical architecture diagram. Actual installation paths and component availability depend on the system configuration.

---

## 💾 USB vs. 🖴 Portable SSD

Both storage options are project targets.

| Feature                | USB Flash Drive            | Portable SSD        |
| ---------------------- | -------------------------- | ------------------- |
| Portability            | Excellent                  | Excellent           |
| Read/write performance | Varies                     | Generally faster    |
| Large AI models        | Less practical             | Better suited       |
| Docker workloads       | May be limited by speed    | Better performance  |
| Storage capacity       | Usually lower              | Usually higher      |
| Recommended use        | Basic portable environment | Full AI environment |

**Recommendation:** Use a 256 GB or larger external SSD for a more complete environment, particularly when storing local AI models and Docker images.

---

## 🔐 Security Best Practices

Security is a core consideration for a portable penetration-testing environment.

Recommended practices:

- Obtain written authorization before conducting assessments.
- Test only systems and networks within your approved scope.
- Encrypt sensitive persistent storage.
- Protect API keys and authentication tokens.
- Avoid storing client credentials in plaintext.
- Use authenticated and encrypted remote connections.
- Restrict access to exposed services and gateways.
- Keep Kali and project dependencies updated.
- Maintain secure backups.
- Document assessment activities.
- Review AI-generated commands before executing them.
- Avoid allowing automated tools to operate outside the authorized scope.

See [docs/SECURITY.md](docs/SECURITY.md) for additional information.

---

## 📖 Documentation

| Document                                               | Description                                |
| ------------------------------------------------------ | ------------------------------------------ |
| [USAGE.md](docs/USAGE.md)                              | Installation, commands, and workflows      |
| [SECURITY.md](docs/SECURITY.md)                        | Security considerations and best practices |
| [README-OPENCODE.txt](postinstall/README-OPENCODE.txt) | OpenCode setup information                 |
| [LICENSE](LICENSE)                                     | Project licensing                          |

---

## 🙏 Credits

This project builds upon the work of several open-source projects:

- [Kali Linux](https://www.kali.org/) — Security-focused Linux distribution.
- [OpenCode](https://opencode.ai/) — AI-powered coding agent.
- [CLI Agent](https://github.com/amranu/cli-agent) — Additional AI assistant integration.
- [Kali MCP](https://github.com/k3nn3dy-ai/kali-mcp) — MCP-based security tooling.
- [Shannon Plugin](https://github.com/vichhka-git/opencode-shannon-plugin) — OpenCode security automation integration.
- [Ollama](https://ollama.com/) — Local AI model runtime.

All third-party components remain subject to their respective licenses, terms, and installation requirements.

---

## 🛣️ Project Roadmap

The following roadmap separates the existing project foundation from planned improvements.

### Implemented Foundation

- [x] Kali Live USB installation workflow.
- [x] Persistent storage partition support.
- [x] Persistence configuration file setup.
- [x] Post-installation setup script.
- [x] Persistence-only recovery mode.
- [x] Initial project documentation.

### Planned Improvements

- [ ] Interactive Kali ISO download and checksum verification.
- [ ] Improved USB and external SSD detection.
- [ ] Enhanced persistence partition validation.
- [ ] Optional encrypted persistence.
- [ ] More comprehensive OpenCode installation automation.
- [ ] CLI Agent installation and verification.
- [ ] Automated Kali MCP configuration.
- [ ] Shannon Plugin integration and verification.
- [ ] Optional Ollama installation.
- [ ] Local AI model management.
- [ ] Automated configuration backups.
- [ ] Improved hardware compatibility.
- [ ] Installation verification and error recovery.
- [ ] Automated environment health checks.
- [ ] Expanded usage and troubleshooting documentation.

---

## 📬 Contact and Community

**GitHub Repository**

[https://github.com/To-The-Max-Tech/Kali-OpenCode-Portable-Drive](https://github.com/To-The-Max-Tech/Kali-OpenCode-Portable-Drive)

**Maintainer**

[@japost1985](https://github.com/japost1985)

**OpenCode Community**

[https://discord.gg/opencode](https://discord.gg/opencode)

---

## ⚖️ Disclaimer

Kali-Linux-OpenCode-Portable-Drive is intended for educational purposes, authorized penetration testing, cybersecurity research, and defensive security assessments.

Users are responsible for ensuring that their activities comply with applicable laws, regulations, authorization requirements, and engagement agreements.

The project maintainers are not responsible for misuse, unauthorized access, damage, data loss, or other consequences resulting from the use of this software.

Third-party tools and integrations are maintained by their respective developers and may have separate licenses and requirements.

**Use responsibly. Test ethically. Document everything.**
