# Pi-Backup-Installer

A simple backup UI and utility installer for Armbian-based SBCs like BigTreeTech CB1.

---

## Features

- Installs the backup scripts and UI to a global shared location:  
  `/opt/Pi-Backup-Installer`  
  This allows all users on the system to use the backup utility without multiple installs.

- Sets up a login UI menu that launches automatically on SSH login for all users via `/etc/profile.d/backup-ui.sh`.

- Per-user detection of **Kiauh** (Klipper Installation And Update Helper):  
  - If `~/kiauh/kiauh.sh` exists and is executable, the UI menu shows the option to launch Kiauh.  
  - On first SSH login for each user, if Kiauh is not installed, they are prompted whether to install Kiauh into their home directory.

- Backup UI exits cleanly back to the standard terminal prompt and runs the usual MOTD (message of the day).

- Automatic installation of necessary dependencies (`git`, `cifs-utils`).

---

## Installation

Run the installer as root (or via sudo):

```bash
git clone https://github.com/hendr13x/Pi-Backup-Installer.git /opt/Pi-Backup-Installer
cd /opt/Pi-Backup-Installer
chmod +x installer.sh
./installer.sh
This will:

Install or update the backup scripts in /opt/Pi-Backup-Installer.

Configure /etc/profile.d/backup-ui.sh to launch the menu UI on SSH login for all users.

Setup permissions and sudoers rules for backup scripts.

Create default config and credential files if missing.

Enable auto backup timer if configured.

Add prompt for per-user Kiauh installation on their first login.

## Usage
When users SSH into the system, the backup UI menu will appear automatically.

Select options to run the SD Card Backup Utility or, if Kiauh is installed in the user’s home, launch Kiauh.

Pressing q exits the menu cleanly back to the normal shell prompt and displays the standard MOTD.

Kiauh installation is per-user and stored under each user’s ~/kiauh directory.

## Notes
The backup UI scripts are located in /opt/Pi-Backup-Installer.

Make sure /opt/Pi-Backup-Installer is readable and executable by all users.

Kiauh installation is user-specific because it configures Klipper firmware installs per user environment.