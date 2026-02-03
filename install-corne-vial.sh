#!/usr/bin/env bash
# Vial Corne Setup Script
# This version uses the user's own group to avoid permission issues.
# Based on: https://get.vial.today/manual/linux-udev.html

set -e # Exit on any error

echo "🛠️  Vial setup for Corne v4.1..."

########################################
# 1. Create a single, correct udev rule for the current user
########################################

export USER_GID="$(id -g)"
export USER_NAME="$(whoami)"

echo "Setting up udev rule for user '$USER_NAME' (group ID: $USER_GID)..."

# This command creates a rule file that gives your user group access to the keyboard.
# The `tee` command allows us to write the file with `sudo`.
sudo tee /etc/udev/rules.d/59-vial.rules >/dev/null <<EOF
# For Vial-enabled keyboards, like the Corne v4.1
# This rule grants access to the user group of the person who ran the script.
KERNEL=="hidraw*", ATTRS{idVendor}=="4653", ATTRS{idProduct}=="0004", MODE="0660", GROUP="$USER_GID", TAG+="uaccess"
EOF

echo "✅ Vial udev rule created (/etc/udev/rules.d/59-vial.rules)"

# Clean up the old, conflicting rule file just in case it's still there
if [ -f /etc/udev/rules.d/60-vial-corne.rules ]; then
    echo "Removing old conflicting rule file (60-vial-corne.rules)..."
    sudo rm /etc/udev/rules.d/60-vial-corne.rules
    echo "✅ Old rule removed."
fi

# Reload udev rules to apply the new rule
echo "Reloading system rules..."
sudo udevadm control --reload-rules && sudo udevadm trigger
echo "✅ System rules reloaded."

########################################
# 2. Download latest Vial AppImage
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
# 3. Verify setup and apply temporary fix if needed
########################################

echo "🔍 Verifying setup..."
echo "Please unplug and replug your keyboard now to apply the new rules."
sleep 5 # Give udev time to apply the rules

# Check if the permissions are correct for any hidraw device
PERMISSIONS_OK=false
for dev in /dev/hidraw*; do
    if [ -e "$dev" ]; then
        if [ "$(stat -c '%g' "$dev")" == "$USER_GID" ]; then
            PERMISSIONS_OK=true
            break
        fi
    fi
done

if [ "$PERMISSIONS_OK" = true ]; then
    echo "✅ Permissions seem to be correct for at least one hidraw device."
else
    echo "⚠️  Permissions are not yet correct. Applying temporary fix..."
    sudo chmod a+rw /dev/hidraw*
    echo "✅ Temporary permissions applied to all hidraw devices."
    echo "ℹ️  A reboot is recommended for a permanent fix."
fi


echo ""
echo "🚀 READY TO CONNECT:"
echo "1. Run the Vial app: $APPIMAGE"
echo "2. In Vial: Click 'Refresh'. Your Corne keyboard should appear."
echo "3. Connect and use the unlock combination if prompted."
echo ""
echo "💾 BACKUP: Remember to save your layout once connected: File → Save current layout"
echo ""
echo "🐛 For debugging, run: $APPIMAGE 2>&1 | tee vial.log"