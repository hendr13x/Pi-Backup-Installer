#!/bin/bash
set -e

REPO_URL="https://github.com/hendr13x/Pi-Backup-Installer.git"
INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_DIR="$INSTALL_DIR/config"
PROFILE_D="/etc/profile.d/backup-ui.sh"

echo "Installing Pi-Backup-Installer to $INSTALL_DIR..."

# Clone or update the repo
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "Updating existing installation..."
  git -C "$INSTALL_DIR" fetch origin
  git -C "$INSTALL_DIR" reset --hard origin/main
  git -C "$INSTALL_DIR" pull
else
  echo "Cloning repository..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Copy backup menu scripts
cp "$INSTALL_DIR/backup_menu.sh" "$INSTALL_DIR/configure_backup.sh" "$INSTALL_DIR/"

# Fix permissions for scripts
chown root:root "$INSTALL_DIR/backup_menu.sh" "$INSTALL_DIR/configure_backup.sh"
chmod +x "$INSTALL_DIR/backup_menu.sh" "$INSTALL_DIR/configure_backup.sh"

# If config file doesn't exist, copy default one
if [ ! -f "$CONFIG_DIR/settings.conf" ]; then
  echo "Copying default config..."
  cp "$INSTALL_DIR/config/settings.conf" "$CONFIG_DIR/"
fi

# Secure config permissions
chown root:root "$CONFIG_DIR/settings.conf"
chmod 600 "$CONFIG_DIR/settings.conf"

# Setup /etc/profile.d script to launch UI on SSH login
echo "Setting up login UI..."

cat > "$PROFILE_D" <<'EOF'
#!/bin/bash
# Launch backup UI on SSH login if SKIP_BACKUP_UI is not set
if [[ -n "$SSH_TTY" && -z "$SKIP_BACKUP_UI" ]]; then
  if [ -x "/opt/Pi-Backup-Installer/main.sh" ]; then
    /opt/Pi-Backup-Installer/main.sh
  else
    echo "⚠️ Backup UI script not found at /opt/Pi-Backup-Installer/main.sh"
  fi
fi
EOF

chmod 755 "$PROFILE_D"
chown root:root "$PROFILE_D"

# Kiauh install prompt setup for users on first login
echo "Setting up Kiauh install prompt for new users..."

# Script to run on user login to prompt Kiauh install if not present and not prompted before
KIAUH_PROMPT_SCRIPT="/opt/Pi-Backup-Installer/kiauh_prompt.sh"

cat > "$KIAUH_PROMPT_SCRIPT" <<'EOF'
#!/bin/bash

KIAUH_PATH="$HOME/kiauh"
PROMPT_FILE="$HOME/.kiauh_prompt_done"

if [ ! -d "$KIAUH_PATH" ] && [ ! -f "$PROMPT_FILE" ]; then
  echo ""
  echo "Would you like to install Kiauh (Klipper Installation And Update Helper)? (y/n): "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Installing Kiauh for user $(whoami)..."
    git clone https://github.com/dw-0/kiauh.git "$KIAUH_PATH"
    echo "Kiauh installed at $KIAUH_PATH. Run it with: $KIAUH_PATH/kiauh.sh"
  else
    echo "Kiauh installation skipped."
  fi
  touch "$PROMPT_FILE"
fi
EOF

chmod +x "$KIAUH_PROMPT_SCRIPT"
chown root:root "$KIAUH_PROMPT_SCRIPT"

# Append kiauh_prompt.sh to each user's ~/.bashrc if not already present
echo "Adding Kiauh prompt to users' ~/.bashrc..."

for userdir in /home/*; do
  if [ -d "$userdir" ]; then
    bashrc="$userdir/.bashrc"
    if ! grep -q "kiauh_prompt.sh" "$bashrc" 2>/dev/null; then
      echo "" >> "$bashrc"
      echo "# Kiauh install prompt" >> "$bashrc"
      echo "if [ -x /opt/Pi-Backup-Installer/kiauh_prompt.sh ]; then" >> "$bashrc"
      echo "  /opt/Pi-Backup-Installer/kiauh_prompt.sh" >> "$bashrc"
      echo "fi" >> "$bashrc"
    fi
  fi
done

echo "Installation complete."
echo "Reconnect via SSH to see the backup UI menu."

exit 0
