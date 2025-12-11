#!/usr/bin/env bash

# Official Vial Corne v4.1 Setup Script (VID:4653=0x123d PID:0004 serial:vial:f64c2b3c)
# Based on: https://get.vial.today/manual/linux-udev.html

set -e # Exit on any error

echo "🛠️  Official Vial setup for Corne v4.1 (VID:4653 PID:0004 serial:vial:f64c2b3c)..."

########################################
# 1. Official universal Vial rule
########################################

export USER_GID="$(id -g)"

sudo --preserve-env=USER_GID sh -c '
echo "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{serial}==\"*vial:f64c2b3c*\", MODE=\"0660\", GROUP=\"$USER_GID\", TAG+=\"uaccess\", TAG+=\"udev-acl\"" \
  > /etc/udev/rules.d/59-vial.rules &&
udevadm control --reload-rules &&
udevadm trigger
'

echo "✅ Official Vial udev rule added (59-vial.rules)"

########################################
# 2. Corne‑specific hidraw rule
########################################

sudo tee /etc/udev/rules.d/60-vial-corne.rules >/dev/null <<'EOF'
# Corne v4.1 (VID:4653=0x123d, PID:0004)
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="123d", ATTRS{idProduct}=="0004", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

# Specific serial variant (extra safety)
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", ATTRS{idVendor}=="123d", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger

echo "✅ Corne-specific rule added (60-vial-corne.rules)"

########################################
# 3. Download latest Vial AppImage
########################################

REPO="vial-kb/vial-gui"
ASSET_PATTERN="Vial-.*x86_64.AppImage"
APPIMAGE="$HOME/Vial-x86_64.AppImage"

if [ ! -f "$APPIMAGE" ]; then
	echo "📥 Downloading latest Vial AppImage..."
	VIAL_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" |
		grep 'browser_download_url' |
		grep "$ASSET_PATTERN" |
		head -1 |
		cut -d '"' -f 4)

	if [ -n "$VIAL_URL" ]; then
		wget -O "$APPIMAGE" "$VIAL_URL" || curl -L "$VIAL_URL" -o "$APPIMAGE"
	else
		echo "❌ Failed to find latest AppImage URL"
		exit 1
	fi
fi

chmod +x "$APPIMAGE"
echo "✅ Vial AppImage ready: $APPIMAGE"

########################################
# 4. (Optional) fix current session
########################################
# After the udev rules, you normally do NOT need chmod here.
# If you really need a one‑time fix without making it world‑writable:
#   sudo chmod 660 /dev/hidraw* 2>/dev/null || true
# Better: unplug and replug the keyboard so udev applies the new rules.

########################################
# 5. Verify setup
########################################

echo "🔍 Verifying setup..."
echo "Active Vial rules:"
ls -l /etc/udev/rules.d/59-vial.rules /etc/udev/rules.d/60-vial-corne.rules 2>/dev/null || true
echo ""
echo "Current hidraw permissions:"
ls -l /dev/hidraw* 2>/dev/null | grep hidraw || echo "No hidraw devices (unplug/replug)"

echo ""
echo "🚀 READY TO CONNECT:"
echo "1. LOG OUT & LOG IN (or reboot) so group changes take effect"
echo "2. Unplug LEFT HALF, wait 10s, plug it back in"
echo "3. Run: $APPIMAGE"
echo "4. In Vial: Refresh → Corne appears → Connect → Unlock combo"
echo ""
echo "💾 BACKUP: File → Save current layout → corne-backup.json"
echo ""
echo "🐛 Debug: $APPIMAGE 2>&1 | tee vial.log"
