#!/usr/bin/env bash

# Official Vial Corne v4.1 Setup Script (VID:4653=0x123d PID:0004 serial:vial:f64c2b3c)
# Adapted from https://get.vial.today/manual/linux-udev.html for your exact device

set -e # Exit on any error

echo "🛠️  Official Vial setup for Corne v4.1 (VID:4653 PID:0004 serial:vial:f64c2b3c)..."

# 1. OFFICIAL Universal Vial rule (matches your serial:vial:f64c2b3c)
export USER_GID=$(id -g)
sudo --preserve-env=USER_GID sh -c '
echo "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{serial}==\"*vial:f64c2b3c*\", MODE=\"0660\", GROUP=\"$USER_GID\", TAG+=\"uaccess\", TAG+=\"udev-acl\"" > /etc/udev/rules.d/59-vial.rules &&
udevadm control --reload-rules &&
udevadm trigger
'

echo "✅ Official Vial udev rule added (59-vial.rules)"

# 2. YOUR Corne-specific rule (VID:4653=0x123d PID:0004)
sudo tee /etc/udev/rules.d/60-vial-corne.rules >/dev/null <<'EOF'
# Corne v4.1 (VID:4653=0x123d, PID:0004, serial:vial:f64c2b3c)
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", ATTRS{idVendor}=="123d", ATTRS{idProduct}=="0004", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger

echo "✅ Corne-specific rule added (60-vial-corne.rules)"

# 3. Download latest Vial AppImage
REPO="vial-kb/vial-gui"
ASSET_PATTERN="Vial-.*x86_64.AppImage"

if [ ! -f ~/Vial-x86_64.AppImage ]; then
	echo "📥 Downloading latest Vial AppImage..."
	VIAL_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" |
		grep 'browser_download_url' |
		grep "$ASSET_PATTERN" |
		head -1 |
		cut -d '"' -f 4)

	if [ -n "$VIAL_URL" ]; then
		wget -O ~/Vial-x86_64.AppImage "$VIAL_URL" || curl -L "$VIAL_URL" -o ~/Vial-x86_64.AppImage
	else
		echo "❌ Failed to find latest AppImage URL"
		exit 1
	fi
fi
chmod +x ~/Vial-x86_64.AppImage

echo "✅ Vial AppImage ready: ~/Vial-x86_64.AppImage"chmod +x ~/Vial-x86_64.AppImage

echo "✅ Vial AppImage ready: ~/Vial-x86_64.AppImage"

# 4. Fix current session permissions
sudo chmod 666 /dev/hidraw* 2>/dev/null || true

# 5. Verify setup
echo "🔍 Verifying setup..."
echo "Active Vial rules:"
ls -l /etc/udev/rules.d/59-vial.rules /etc/udev/rules.d/60-vial-corne.rules 2>/dev/null | cat
echo ""
echo "Current hidraw permissions:"
ls -l /dev/hidraw* 2>/dev/null | grep hidraw || echo "No hidraw devices (unplug/replug)"

echo ""
echo "🚀 READY TO CONNECT:"
echo "1. LOGOUT & LOGIN (or reboot) for group changes"
echo "2. Unplug LEFT HALF, wait 10s, replug"
echo "3. ~/Vial-x86_64.AppImage"
echo "4. REFRESH → Corne appears → CONNECT → Unlock combo"
echo ""
echo "💾 BACKUP: File → Save current layout → corne-backup.json"
echo ""
echo "🐛 Debug: ./Vial-x86_64.AppImage 2>&1 | tee vial.log"
