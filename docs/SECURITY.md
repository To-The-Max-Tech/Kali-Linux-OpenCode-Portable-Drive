# 🔐 Security Considerations

## Kali-Linux-OpenCode-Portable-Drive

This document describes security requirements, operational security practices, storage encryption, network protections, credential management, data handling, and incident response recommendations for **Kali-Linux-OpenCode-Portable-Drive**.

The project combines Kali Linux, OpenCode, portable persistent storage, optional third-party integrations, local AI capabilities, and security assessment utilities.

These components introduce risks involving sensitive assessment data, credentials, software installation, system permissions, and third-party dependencies.

**Security is not optional. Protect your infrastructure, protect client information, and operate responsibly.**

---

# 1. Legal and Authorization Requirements

> **THIS PROJECT IS INTENDED FOR AUTHORIZED SECURITY TESTING AND DEFENSIVE SECURITY OPERATIONS ONLY.**

Unauthorized access to computer systems, networks, applications, and digital infrastructure may violate criminal and civil laws.

Examples of applicable legislation include:

- United States: Computer Fraud and Abuse Act (CFAA).
- United Kingdom: Computer Misuse Act 1990.
- Other jurisdictions: Applicable national cybersecurity, privacy, and computer misuse legislation.

Always obtain explicit authorization before assessing systems, networks, applications, or devices you do not own.

## 1.1 Before an Engagement

- [ ] Obtain written authorization.
- [ ] Identify the organization or system owner.
- [ ] Document authorized targets and IP ranges.
- [ ] Define assessment scope and exclusions.
- [ ] Review the Rules of Engagement (ROE).
- [ ] Identify emergency contacts.
- [ ] Establish approved testing schedules.
- [ ] Confirm permitted assessment techniques.
- [ ] Establish evidence-handling procedures.
- [ ] Document data retention and reporting requirements.

## 1.2 Authorization Documentation

Recommended storage location:

```text
~/.opencode/workspace/authorization/
```

Example structure:

```text
authorization/
└── client-name/
    ├── engagement-letter.pdf
    ├── scope.md
    ├── rules-of-engagement.md
    ├── emergency-contacts.md
    └── testing-approval.pdf
```

Treat authorization documents as confidential client information.

Restrict access to these files and use encrypted storage when appropriate.

---

# 2. Operational Security (OpSec)

Operational security protects the portable workstation, assessment information, credentials, and supporting infrastructure against unauthorized access.

## 2.1 Physical Security

| Risk | Recommended Mitigation |
|---|---|
| USB drive lost or stolen | Encrypt sensitive persistent storage |
| Portable SSD stolen | Use full-disk encryption where appropriate |
| Device left unattended | Lock the workstation and secure the storage device |
| Unauthorized account access | Use strong authentication |
| Host machine compromised | Avoid mounting host filesystems unnecessarily |
| Credentials exposed | Revoke and rotate affected credentials |
| Device seized | Follow organizational incident response and evidence-preservation procedures |

### Important Considerations

Booting Kali Linux from portable storage does not guarantee that the host computer retains no information about the session.

Potential traces include:

- Firmware boot information.
- Host operating system logs.
- Mounted host filesystems.
- Network infrastructure logs.
- DNS and connection records.
- Data retained in RAM.
- Hardware and firmware activity.

Do not assume portable storage makes an assessment anonymous or completely trace-free.

## 2.2 Account Security

Use a standard user account for everyday activity.

Recommended practices:

- Avoid running OpenCode as root.
- Use `sudo` only when administrator privileges are required.
- Protect the Kali account with a strong password.
- Lock the workstation when unattended.
- Avoid sharing user accounts.
- Review permissions on sensitive directories.
- Remove unnecessary administrative privileges.

Check the current user:

```bash
whoami
```

Check account identity and groups:

```bash
id
```

Review workspace permissions:

```bash
ls -ld ~/.opencode
ls -ld ~/.opencode/workspace
```

---

# 3. Storage Encryption

**Recommended: Encrypt sensitive persistent storage.**

Portable drives are particularly vulnerable to loss and theft.

Encryption can reduce the risk of unauthorized access to stored information, provided that encryption keys and recovery procedures are managed securely.

## 3.1 LUKS Encryption

LUKS (Linux Unified Key Setup) is a standard Linux disk-encryption format.

Before configuring encryption, identify the correct storage device:

```bash
lsblk -f
```

Inspect device details:

```bash
sudo fdisk -l
```

For a new, dedicated partition, an example LUKS initialization process is:

```bash
# WARNING: This destroys existing data on the selected partition.
sudo cryptsetup luksFormat /dev/sdX3
```

Open the encrypted partition:

```bash
sudo cryptsetup open /dev/sdX3 persistence
```

Create an ext4 filesystem inside the encrypted mapping:

```bash
sudo mkfs.ext4 -L persistence /dev/mapper/persistence
```

Close the encrypted mapping when it is not mounted:

```bash
sudo cryptsetup close persistence
```

Replace `/dev/sdX3` with the actual partition.

**Never copy these commands blindly. Verify the device name before executing destructive operations.**

### Important: Existing Kali Persistence

The standard portable-drive builder described by this project creates an ext4 persistence partition.

It does not automatically configure LUKS-encrypted persistence or the boot-time unlock process.

Running `cryptsetup luksFormat` on an existing persistence partition destroys its existing filesystem information and can make the current persistence installation unusable.

Do not encrypt the existing persistence partition unless you have a verified migration or rebuild procedure and a separate backup.

### Encrypted Persistence Requires Additional Configuration

Creating a LUKS container is only one part of encrypted persistence.

A working encrypted Kali Live Persistence configuration also requires appropriate:

- Boot parameters.
- Initramfs support.
- LUKS device discovery.
- Encryption unlock procedures.
- Persistence filesystem mounting.
- Persistence configuration.
- Recovery procedures.

Follow the official Kali documentation for the exact encrypted-persistence procedure supported by your Kali release.

## 3.2 Encryption Recommendations

- Use a strong, unique passphrase.
- Never store the passphrase in plaintext on the portable drive.
- Store recovery information separately.
- Protect encryption headers and recovery material.
- Maintain independent backups.
- Test recovery before using the device for an engagement.
- Protect any unencrypted partitions that contain sensitive information.

Encryption does not protect data while an encrypted filesystem is unlocked and mounted.

---

# 4. Emergency Data Protection

A destructive panic-wipe script is not included in this project.

Automatic deletion is not a reliable substitute for encryption, credential revocation, or incident response.

### Limitations of File Deletion

- `shred` cannot guarantee erasure on SSDs.
- SSD wear-leveling may retain inaccessible copies.
- TRIM behavior varies between devices.
- Filesystem snapshots may retain previous versions.
- Backups may contain copies of deleted files.
- Removing a file does not revoke exposed credentials.

## 4.1 Recommended Emergency Procedure

If the portable workstation is lost, stolen, or compromised:

1. Report the incident to the appropriate security contact.
2. Revoke exposed API keys and authentication tokens.
3. Change affected passwords.
4. Revoke compromised application credentials.
5. Disable affected remote access through the actual service controls.
6. Notify impacted organizations when required.
7. Preserve evidence when an investigation is necessary.
8. Follow approved storage sanitization procedures.

## 4.2 SSD Sanitization

For SSDs, use manufacturer-supported sanitization or cryptographic erase functionality where appropriate.

If a device uses full-disk encryption and the encryption keys are securely destroyed, encrypted data may become inaccessible.

This depends on the encryption implementation, key management, and whether plaintext copies exist elsewhere.

---

# 5. Network Security

The portable environment may use network connections for software installation, AI providers, updates, and authorized assessment activities.

Apply network restrictions appropriate to the engagement.

## 5.1 Network Exposure

Recommended practices:

- Do not expose administrative services unnecessarily.
- Restrict access to trusted networks.
- Use authenticated encrypted connections.
- Apply firewall restrictions.
- Avoid exposing local development services to the public internet.
- Review listening network services.
- Disable services that are not needed.
- Avoid using untrusted networks for sensitive administration.

Inspect listening TCP services:

```bash
sudo ss -tlnp
```

Inspect network interfaces:

```bash
ip address
```

Inspect routes:

```bash
ip route
```

Review firewall status if UFW is installed:

```bash
sudo ufw status verbose
```

### OpenCode Network Services

Do not assume that OpenCode is running a gateway or remote administration service.

The project scripts reviewed so far do not establish a gateway-management service or remote-node infrastructure.

If you independently configure a network-accessible OpenCode service or another administrative application:

1. Verify the service's actual network binding.
2. Identify the authentication mechanism.
3. Confirm whether TLS is supported.
4. Restrict access through firewall rules.
5. Avoid public exposure unless explicitly required.
6. Review the installed version's documentation.
7. Test access controls before using it.

Do not rely on undocumented configuration commands or guessed configuration keys.

## 5.2 Firewall Example

If a separately configured service must be accessible from a trusted IP address, an example UFW rule is:

```bash
sudo ufw allow from <TRUSTED_IP> to any port <SERVICE_PORT> proto tcp
```

Replace the placeholders with the actual trusted IP address and service port.

Check the resulting configuration:

```bash
sudo ufw status numbered
```

Do not open ports globally without a documented requirement.

## 5.3 Remote Administration

This project does not currently implement a remote-node gateway or an authenticated remote command execution service through `deploy-node.sh`.

The endpoint assessment package generated by that script runs locally on the endpoint.

It does not:

- Establish a persistent remote connection.
- Register a remote node.
- Connect to an OpenCode gateway.
- Install remote-access services.
- Execute commands remotely.
- Automatically transmit assessment results.

If a separate remote administration product is deployed, secure it independently.

Recommended controls include:

- Strong authentication.
- Encryption in transit.
- Least-privilege accounts.
- Restricted network access.
- Credential rotation.
- Administrative audit logging.
- Documented authorization.
- Incident response procedures.

---

# 6. Data Handling and Protection

Assessment data can contain confidential information, credentials, proprietary application details, and personally identifiable information (PII).

Protect all collected information according to the engagement agreement and applicable data protection requirements.

## 6.1 Sensitive Information

Treat the following as sensitive:

- Client credentials.
- API keys and access tokens.
- Password databases.
- Password hashes.
- Personally identifiable information.
- Proprietary application data.
- Confidential network diagrams.
- Internal infrastructure documentation.
- Sensitive assessment reports.
- Authentication and session records.
- Endpoint inventory information.

Avoid storing sensitive information in unencrypted locations.

## 6.2 Recommended Workspace Structure

```text
~/.opencode/workspace/
├── authorization/
├── engagements/
│   └── client-name/
├── memory/
├── templates/
├── findings/
├── reports/
├── evidence/
├── logs/
└── backups/
```

Use appropriate filesystem permissions.

For example:

```bash
chmod 700 ~/.opencode/workspace
```

For particularly sensitive directories:

```bash
chmod 700 ~/.opencode/workspace/authorization
chmod 700 ~/.opencode/workspace/evidence
```

Use encrypted storage for confidential engagement information.

## 6.3 Encrypted Data Containers

An encrypted file-backed volume can provide additional protection for selected sensitive information.

The following example creates a new encrypted container.

**WARNING:** The commands initialize a new container and create a filesystem. Use a new file path and do not overwrite existing data.

Create a container:

```bash
fallocate -l 5G sensitive-data.img
```

Initialize encryption:

```bash
sudo cryptsetup luksFormat sensitive-data.img
```

Open the container:

```bash
sudo cryptsetup open sensitive-data.img sensitive_data
```

Create a filesystem:

```bash
sudo mkfs.ext4 /dev/mapper/sensitive_data
```

Create a mount point:

```bash
sudo mkdir -p /mnt/sensitive
```

Mount the encrypted filesystem:

```bash
sudo mount /dev/mapper/sensitive_data /mnt/sensitive
```

Work with sensitive information inside:

```text
/mnt/sensitive/
```

When finished:

```bash
sudo umount /mnt/sensitive

sudo cryptsetup close sensitive_data
```

Store the encryption passphrase separately from the encrypted container.

Do not leave the container mounted when it is not needed.

## 6.4 Data Retention

Follow the retention requirements defined in the engagement agreement.

After an engagement:

1. Complete the assessment report.
2. Verify that required evidence has been backed up.
3. Transfer approved findings to secure storage.
4. Identify temporary and unnecessary data.
5. Remove information according to the retention policy.
6. Sanitize storage using an appropriate method when required.
7. Document the disposal process.

Identify files in an engagement directory:

```bash
find ~/.opencode/workspace/engagements/client-name \
  -type f -print
```

Review log files:

```bash
find ~/.opencode/workspace/engagements/client-name \
  -type f -name "*.log" -print
```

Review before deleting anything.

Do not automatically delete evidence that must be preserved for reporting, compliance, or forensic investigation.

---

# 7. Endpoint Assessment Security

The project includes `deploy-node.sh`, which generates portable Linux and Windows endpoint assessment utilities.

These utilities collect local system and network configuration information.

## 7.1 Collected Information

The Linux utility may collect:

- Operating system information.
- CPU and memory information.
- Disk information.
- Network interfaces.
- Network routes.
- DNS configuration.
- Listening TCP services.
- Availability of selected assessment tools.

The Windows utility may collect:

- Computer information.
- Current user.
- CPU and memory information.
- Storage volumes.
- IP configuration.
- IPv4 routes.
- DNS configuration.
- Listening TCP ports.

This information can be sensitive even though the utilities perform local collection.

## 7.2 Protect Assessment Reports

Assessment reports may reveal:

- Hostnames.
- Usernames.
- Internal IP addresses.
- Network topology.
- DNS configuration.
- Listening services.
- Installed software information.

Protect generated reports and transfer them only through approved channels.

## 7.3 Package Integrity

The generated package includes a `SHA256SUMS` file.

Verify its contents:

```bash
sha256sum -c SHA256SUMS
```

A matching checksum confirms that a file matches the checksum recorded in the manifest.

It does not establish the identity of the package creator or prove that the original package was trustworthy.

For stronger supply-chain assurance, distribute signed packages and verify signatures using a trusted public key.

---

# 8. Tool and Application Security

## 8.1 Command Execution

AI-generated commands must be reviewed before execution.

Recommended practices:

- Avoid unrestricted command execution.
- Review commands before running them.
- Verify executable paths.
- Avoid unnecessary root privileges.
- Require confirmation for destructive operations.
- Use separate accounts for administrative tasks.
- Review application permissions.
- Restrict access to sensitive files.

Do not assume that a command approval or allowlist feature exists in every installed OpenCode version.

Use only security controls documented by the installed application version.

## 8.2 Supply-Chain Security

Install software only from trusted sources.

### OpenCode

Official website and documentation:

https://opencode.ai/

https://opencode.ai/docs/

### Kali Linux

Official Kali website:

https://www.kali.org/

Official downloads:

https://www.kali.org/get-kali/

### Bun

Official website:

https://bun.sh/

### Ollama

Official website:

https://ollama.com/

### Third-Party Integrations

Review the source repositories before installing or updating:

- CLI Agent.
- Kali MCP.
- Shannon Plugin.

Verify repository ownership, release information, installation requirements, and requested permissions.

## 8.3 Remote Installation Scripts

The project setup script uses official installation scripts for some components.

Piping a remote script directly into a shell is convenient, but it executes downloaded code.

For sensitive environments:

1. Inspect the installation script.
2. Verify the download source.
3. Review the commands it executes.
4. Confirm the expected software destination.
5. Avoid running it as root unless necessary.
6. Record the installed version.

Do not execute untrusted installation scripts.

## 8.4 Kali ISO Verification

Always verify downloaded Kali ISO images against the official published SHA-256 checksum.

Calculate the local checksum:

```bash
sha256sum kali-linux-amd64.iso
```

Compare the result against the checksum published by Kali for the exact ISO image.

The project builder accepts a checksum supplied by the user and compares it with the downloaded or local ISO.

That comparison checks file integrity against the supplied value. It does not independently authenticate the checksum.

Obtain the expected checksum from a trusted official Kali source.

## 8.5 Software Updates

Keep Kali and installed applications updated.

Update package metadata:

```bash
sudo apt update
```

Review and apply available upgrades:

```bash
sudo apt full-upgrade
```

Review package changes before confirming.

Use the update mechanism documented for your installed OpenCode and Bun distributions.

Avoid blindly updating dependencies during an active engagement.

Test significant updates before using them in production assessment environments.

---

# 9. API Keys and AI Provider Security

OpenCode and optional integrations may use external AI providers.

API keys and authentication tokens must be treated as sensitive credentials.

## 9.1 Credential Recommendations

- Never commit API keys to Git repositories.
- Avoid embedding credentials in scripts.
- Do not share credentials between unrelated engagements.
- Use environment variables or a secrets manager.
- Rotate exposed credentials immediately.
- Restrict provider permissions where possible.
- Monitor provider usage and billing.
- Avoid sending confidential client information to external AI services without authorization.

## 9.2 Environment Variable Example

```bash
export OPENAI_API_KEY="YOUR_API_KEY"
```

Other providers may require different environment variable names.

For persistent use, prefer a secure credential manager rather than placing plaintext secrets directly in `.bashrc`.

If a protected environment file is necessary, restrict its permissions:

```bash
chmod 600 ~/.config/opencode/provider-secrets.env
```

Never commit such a file to a repository.

## 9.3 AI Data Handling

Before using a cloud AI provider with assessment data, determine:

- What information will be transmitted.
- Whether client authorization permits external processing.
- Which provider account is being used.
- Whether sensitive information must be redacted.
- Whether the provider retains submitted data.
- Whether the engagement agreement imposes data-location restrictions.

Do not submit passwords, private keys, authentication tokens, or unnecessary client data to AI services.

## 9.4 Local AI Security

Locally hosted models may reduce the need to transmit prompts and assessment information to external AI providers.

However, local inference does not eliminate security risks.

Protect:

- Model files.
- Local inference endpoints.
- Logs.
- Conversation histories.
- Cached prompts.
- Application configuration.
- Model management credentials.

Verify that local AI services are not unintentionally exposed to untrusted networks.

---

# 10. Backup Security

The project includes `backup-config.sh` for backing up OpenCode configuration and workspace information.

Backups may contain:

- OpenCode configuration.
- Session information.
- Agent data.
- Workspace files.
- Findings and reports.
- Engagement records.
- Credentials or other sensitive information, depending on what is stored in the source directories.

## 10.1 Protect Backup Directories

Restrict access:

```bash
chmod 700 ~/.opencode/workspace/backups
```

Review backup permissions:

```bash
ls -ld ~/.opencode/workspace/backups
```

## 10.2 Verify Backup Checksums

From a backup directory:

```bash
sha256sum -c SHA256SUMS
```

Checksums detect changes to files covered by the manifest.

They are not digital signatures and do not establish backup authenticity.

## 10.3 Remote Backup Security

If using the backup script's optional SSH/rsync functionality:

- Use a trusted remote server.
- Protect SSH credentials.
- Restrict access to the backup destination.
- Use encrypted transport.
- Review remote directory permissions.
- Protect backups against unauthorized modification.
- Maintain independent recovery copies.

Do not assume remote backups are automatically encrypted at rest.

## 10.4 Backup Limitations

Review the backup script's exclusions before relying on it for archival or disaster recovery.

The backup utility does not automatically guarantee:

- A complete image of the Kali USB.
- A complete backup of every third-party repository.
- A backup of all system packages.
- An automatic restore operation.
- Encryption of backup archives.
- Remote backup retention management.

Maintain separate backups of important project files and system configuration when required.

---

# 11. Engagement Security Checklist

## 11.1 Pre-Engagement

- [ ] Written authorization obtained.
- [ ] Scope documented.
- [ ] Out-of-scope targets identified.
- [ ] Emergency contacts documented.
- [ ] Persistence encryption enabled when appropriate.
- [ ] Portable storage physically secured.
- [ ] Configuration backup created.
- [ ] Software sources verified.
- [ ] Kali ISO checksum verified.
- [ ] API credentials protected.
- [ ] Assessment tools tested.
- [ ] Data retention requirements reviewed.
- [ ] External AI data-sharing restrictions reviewed.

## 11.2 During an Engagement

- [ ] Activities remain within authorized scope.
- [ ] Findings documented.
- [ ] Authorization documentation accessible.
- [ ] Sensitive data stored securely.
- [ ] Portable storage remains physically protected.
- [ ] Remote connections use approved security controls.
- [ ] Credentials protected.
- [ ] Backups performed when appropriate.
- [ ] Changes to scope approved and documented.
- [ ] AI-generated commands reviewed before execution.

## 11.3 Post-Engagement

- [ ] Findings documented.
- [ ] Final report completed.
- [ ] Evidence backed up securely.
- [ ] Sensitive information reviewed.
- [ ] Temporary files handled according to retention policy.
- [ ] Credentials and temporary access reviewed.
- [ ] API keys rotated when appropriate.
- [ ] Logs reviewed.
- [ ] Lessons learned documented.
- [ ] Storage sanitization completed when required.

---

# 12. Incident Response

This section describes recommended actions when the portable workstation, assessment data, or associated infrastructure is lost, stolen, or compromised.

## 12.1 USB or SSD Lost or Stolen

Immediately:

1. Report the incident to the appropriate security contact.
2. Revoke API keys stored on the device.
3. Rotate exposed passwords and authentication tokens.
4. Revoke affected application credentials.
5. Disable affected remote access through the relevant service controls.
6. Notify impacted clients when required.
7. Document the incident.
8. Assess potential data exposure.

Consider whether:

- The device was unlocked when lost.
- Encryption was enabled.
- Passphrases were stored elsewhere.
- Credentials were exposed through logs.
- Unencrypted partitions contained sensitive data.
- Backup copies exist on other systems.
- API tokens remain active.

Do not assume encryption eliminates all risk.

## 12.2 Workstation Compromised

If compromise is suspected:

1. Stop ongoing assessment activities.
2. Disconnect the workstation from untrusted networks.
3. Preserve relevant logs and evidence.
4. Document the incident timeline.
5. Identify potentially exposed credentials.
6. Revoke affected credentials.
7. Notify clients according to the engagement agreement.
8. Investigate the suspected compromise.
9. Rebuild the workstation from trusted installation media when appropriate.

Avoid immediately wiping the device if forensic evidence may be required.

## 12.3 Endpoint Assessment Data Exposed

If endpoint assessment reports are exposed:

1. Identify the affected reports.
2. Determine what information was collected.
3. Identify affected systems and organizations.
4. Notify the appropriate security contact.
5. Restrict access to remaining copies.
6. Follow the engagement's incident response requirements.
7. Document the exposure and remediation.

## 12.4 Backup Exposure

If a backup is exposed:

1. Identify the affected backup files.
2. Determine whether credentials or session data were included.
3. Revoke exposed credentials.
4. Restrict access to remaining copies.
5. Review remote backup permissions.
6. Restore from a trusted backup if necessary.
7. Document the incident.

---

# 13. Security Best Practices Summary

| Recommended | Avoid |
|---|---|
| Encrypt sensitive persistent storage | Store credentials in plaintext |
| Document authorization | Test unauthorized targets |
| Use strong passphrases | Reuse passwords |
| Maintain independent backups | Rely on one storage device |
| Use authenticated encrypted connections | Expose administrative services unnecessarily |
| Review commands before execution | Enable unrestricted command execution |
| Verify ISO checksums | Install unverified images |
| Use trusted software sources | Execute untrusted installation scripts |
| Keep software updated | Use outdated vulnerable packages |
| Protect API keys | Commit credentials to Git |
| Restrict access to reports | Share sensitive evidence publicly |
| Preserve required evidence | Destroy evidence prematurely |
| Follow approved sanitization procedures | Assume `shred` guarantees SSD erasure |
| Verify third-party integrations | Assume cloned repositories are fully configured |

---

# 14. Security Resources

### Kali Linux

Official documentation:

https://www.kali.org/docs/

Official downloads:

https://www.kali.org/get-kali/

### OpenCode

Official documentation:

https://opencode.ai/docs/

### MITRE ATT&CK

Adversary tactics and techniques:

https://attack.mitre.org/

### PTES

Penetration Testing Execution Standard:

http://www.pentest-standard.org/

### OWASP

Web application security guidance:

https://owasp.org/

### NIST

Cybersecurity frameworks and publications:

https://www.nist.gov/cyberframework

### Cryptsetup

Linux disk encryption project:

https://gitlab.com/cryptsetup/cryptsetup

---

# 15. Project Information

**Project:**

Kali-Linux-OpenCode-Portable-Drive

**Document:**

SECURITY.md

**Classification:**

Project Security Documentation

**Platform:**

Kali Linux

**Storage:**

USB Flash Drive / Portable SSD

**Encryption:**

LUKS Recommended for Sensitive Storage

**Primary Security Principle:**

Defense in Depth

**Repository:**

https://github.com/To-The-Max-Tech/Kali-OpenCode-Portable-Drive

**Maintainer:**

@japost1985

---

# Final Security Statement

Kali-Linux-OpenCode-Portable-Drive is intended for authorized security research, penetration testing, vulnerability assessment, development, and defensive security operations.

Its portability and assessment capabilities introduce responsibilities involving:

- Legal authorization.
- Information security.
- Credential management.
- Data confidentiality.
- Software integrity.
- Network protection.
- Evidence preservation.
- Incident response.

Every operator is responsible for protecting the systems and information they interact with.

Never assume portability automatically provides anonymity, encryption, or operational security.

**Secure the workstation. Protect the data. Verify authorization. Document everything.**

**Build responsibly. Test legally. Operate securely.**