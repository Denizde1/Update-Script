#!/bin/bash

echo "🌐 Detecting your Linux distribution..."

# Check for /etc/os-release
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "❌ Cannot detect the system. /etc/os-release is missing."
    exit 1
fi

echo "💻 Detected: $PRETTY_NAME"

# Confirm update
read -p "🔄 Do you want to update your system? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "❌ Update cancelled by user."
    exit 0
fi

# Request sudo upfront
if ! sudo -v; then
    echo "❌ Sudo authentication failed."
    exit 1
fi

# Update based on distro
case "$DISTRO" in
    ubuntu | debian)
        echo "🧼 Updating with apt..."
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
        ;;
    arch | manjaro)
        echo "🧼 Updating with pacman..."
        sudo pacman -Syu --noconfirm
        ;;
    fedora)
        echo "🧼 Updating with dnf..."
        sudo dnf upgrade --refresh -y
        ;;
    opensuse* | sles)
        echo "🧼 Updating with zypper..."
        sudo zypper refresh && sudo zypper update -y
        ;;
    *)
        echo "⚠️ Automatic updates not supported for this distribution."
        ;;
esac

# AUR helper update (yay or paru)
AUR_HELPERS=()
[[ $(command -v yay) ]] && AUR_HELPERS+=("yay")
[[ $(command -v paru) ]] && AUR_HELPERS+=("paru")

if [ ${#AUR_HELPERS[@]} -gt 0 ]; then
    echo "✨ Detected AUR helper(s): ${AUR_HELPERS[*]}"
    read -p "Do you want to update AUR packages? (y/n): " aur_ans
    if [[ "$aur_ans" == "y" ]]; then
        for helper in "${AUR_HELPERS[@]}"; do
            echo "🔄 Updating AUR packages with $helper..."
            $helper -Syu --noconfirm
        done
    fi
fi

# Flatpak update
if command -v flatpak &>/dev/null; then
    read -p "📦 Do you want to update Flatpak apps? (y/n): " flatpak_ans
    if [[ "$flatpak_ans" == "y" ]]; then
        flatpak update -y
    fi
fi

# Snap update
if command -v snap &>/dev/null; then
    read -p "📦 Do you want to update Snap packages? (y/n): " snap_ans
    if [[ "$snap_ans" == "y" ]]; then
        sudo snap refresh
    fi
fi

echo "✅ All selected updates completed!"
exit 0
