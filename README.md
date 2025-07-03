# Pi-Backup-Installer

**A simple SD Card backup utility with integrated menu UI for BigTreeTech CB1 and similar devices.**

---

## Features

- Shared installation under `/opt/Pi-Backup-Installer` for all users.
- Backup status shown at SSH login via a clean menu interface.
- Automatically detects and shows backup info: last backup date, total backups, disk usage, and next scheduled auto-backup.
- Option to launch the SD Card Backup Utility or (if installed) run Kiauh (Klipper Installation And Update Helper).
- Per-user prompt on first SSH login to optionally install Kiauh under their home directory (`~/kiauh`).
- Clean exit back to terminal with MOTD re-run on menu quit.

---

## Installation

Run the following commands **as root** to install or update Pi-Backup-Installer:

```bash
# Clone or update repository in /opt
if [ ! -d /opt/Pi-Backup-Installer ]; then
  git clone https://github.com/hendr13x/Pi-Backup-Installer.git /opt/Pi-Backup-Installer
else
  cd /opt/Pi-Backup-Installer
  git fetch origin
  git reset --hard origin/main
fi

# Make scripts executable
chmod +x /opt/Pi-Backup-Installer/installer.sh
chmod +x /opt/Pi-Backup-Installer/main.sh

# Run the installer script
/opt/Pi-Backup-Installer/installer.sh

## This will:

Install/update the backup utility to /opt/Pi-Backup-Installer

Set up the login UI for all users in /etc/profile.d/backup-ui.sh

Create backup directories and config files

Enable per-user Kiauh install prompt on first login

## Using the Backup UI
SSH into your device with any user.

On login, you will see the backup UI menu showing your current backup status.

If Kiauh is not installed in your home directory (~/kiauh), you will be prompted whether to install it.

Choose the menu option by entering the corresponding number or press q to exit back to the terminal.

Kiauh installation is per-user and optional.

## Additional Notes
Kiauh repository: https://github.com/dw-0/kiauh

Backup Installer repo: https://github.com/hendr13x/Pi-Backup-Installer

The UI menu only triggers on SSH login sessions.

To skip the backup UI on login, set environment variable SKIP_BACKUP_UI=1.

## License
MIT License