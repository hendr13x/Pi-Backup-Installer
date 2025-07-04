# Pi Backup Manager

**A streamlined SD card backup utility with an interactive SSH menu, built for BigTreeTech CB1 and other Armbian-compatible devices.**

---

## 🚀 Features

* One-time installation under `/opt/Pi-Backup-Installer` (shared across all users)
* Easy-to-use SSH menu: backup, configure, or launch Kiauh
* Auto NAS mounting and configurable backup destination
* Optional daily scheduled backups with retention control
* Supports custom backup filename prefix
* KIAUH integration: per-user install and launch support
* Clean return to terminal with MOTD shown again after menu exit

---

## 📦 Installation

Run the following as root or using `sudo` (recommended for multi-user install):

```bash
cd /opt
sudo git clone https://github.com/hendr13x/Pi-Backup-Installer.git
cd Pi-Backup-Installer
sudo bash installer.sh
```

This will:

* Install/replace the manager at `/opt/Pi-Backup-Installer`
* Set up the backup UI to auto-launch on SSH login (multi-user compatible)
* Configure shared settings and credential storage
* Enable NAS mount and cleanup logic

---

## 🧭 Using the Menu UI

Upon SSH login, users are greeted with:

```
Pi Backup Manager
-------------------
1) Launch SD Card Backup Utility
2) Install or Launch KIAUH
q) Exit to terminal
```

* Choosing **1** opens the SD card backup tool
* Choosing **2** will:

  * Clone and install KIAUH to `~/kiauh` if not present
  * Otherwise, launch it directly
* Pressing **q** exits to the normal terminal, showing the Armbian welcome info

---

## 🔧 Configuration

Settings are stored in:

* `/opt/Pi-Backup-Installer/config/settings.conf`
* Credentials in `/opt/Pi-Backup-Installer/credentials/nas_creds`

Configurable options:

* NAS IP, share name, user/pass
* Max number of backups to retain
* Automatic daily backup (via cron)
* Custom backup filename prefix

---

## 💡 Tips

* Want to skip the UI? Add this to your `.bashrc`:

  ```bash
  export SKIP_BACKUP_UI=1
  ```
* Backups are stored on your mounted NAS in compressed `.img.gz` format
* Check logs in `/opt/Pi-Backup-Installer/backups/*.log`

---

## 🔗 References

* KIAUH: [https://github.com/dw-0/kiauh](https://github.com/dw-0/kiauh)
* Pi Backup Installer: [https://github.com/hendr13x/Pi-Backup-Installer](https://github.com/hendr13x/Pi-Backup-Installer)

---

## 🪪 License

MIT License
