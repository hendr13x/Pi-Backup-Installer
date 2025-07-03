# SD Card Backup Utility & Kiauh Installer for SBCs

This project provides an easy-to-use terminal-based application for Single Board Computers (like the CB1 or Raspberry Pi) to:

- **Backup the full SD card** to a NAS share (QNAP or SMB-compatible) as a compressed `.img.gz` file with automatic rotation.
- **Install and run [Kiauh](https://github.com/dw-0/kiauh)** (Klipper UI Automated Installer/Manager).
- Provide a simple **SSH login menu interface** to choose between the Backup Utility, Kiauh, or exit to shell.

---

## Features

- **Automatic NAS mounting/unmounting** with secure credentials stored locally (`chmod 600` applied).
- Full **compressed disk image backups** with progress output and log files saved alongside backups.
- Configurable:
  - NAS IP, share, and username
  - Max number of backups to keep (with automatic pruning)
  - Automated backups via systemd timers (enable/disable & schedule)
- Runs backup utility **with sudo privileges automatically** (no password prompt).
- Simple **text-based menu UI on SSH login** for quick access.
- Optionally installs and launches Kiauh if selected during install.
- Architecture detection to ensure compatibility.

---

## Installation

Run the installer script on your SBC (e.g., CB1, Raspberry Pi) with:

```bash
git clone https://github.com/hendr13x/Pi-Backup-Installer
cd Pi-Backup-Installer
./installer.sh



##The installer will:

Detect your system architecture.

Install necessary dependencies (git, cifs-utils).

Set up config and credential files with secure permissions.

Add passwordless sudo for the backup utility.

Optionally clone and set up Kiauh.

Configure your SSH login to launch the UI menu automatically.

##Configuration
You can configure the backup utility anytime via the Backup Settings Menu:

NAS IP/Hostname

NAS SMB Share

NAS Username

Max backups to keep

Automatic backup toggle and schedule (daily or weekly)

Configuration file path:
~/backup-installer/config/settings.conf

NAS credentials stored securely at:
~/backup-installer/credentials/nas_creds (permissions 600)

##Usage
SSH into your SBC.

The terminal menu will show:

Run SD Card Backup Utility

Run Kiauh (only if installed)

Exit to shell

Follow prompts to perform backups or configure settings.

Backups will be saved to your NAS SMB share as compressed .img.gz files with timestamps.

##Backup Details
The backup utility creates a compressed image of the entire SD card.

Old backups are automatically deleted when exceeding the configured max.

Logs are saved alongside backups in the NAS folder.

NAS share is mounted/unmounted only during the backup process.

##Notes
Ensure your NAS SMB share is accessible and credentials are correct.

Automatic backups require enabling and scheduling from the config menu.

Kiauh is installed directly from its official GitHub repository.

##Troubleshooting
Backup fails to mount NAS:
Verify your NAS IP, share name, and credentials.

Permission denied errors:
Check that credentials/nas_creds has chmod 600 permissions and sudoers rule is installed.

Kiauh not appearing:
Confirm you selected to install Kiauh during setup.

##License
This project is open source under the MIT License.

##Contributing
Feel free to open issues or pull requests for improvements or bugs.


Happy backing up!