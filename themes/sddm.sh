#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_sddm_theme() {
    local theme_name="catppuccin-mocha-mauve"
    local repo="catppuccin/sddm"

    # Check if theme is already installed
    if [ -d "/usr/share/sddm/themes/$theme_name" ]; then
        print_info "SDDM theme is already installed"
        return 0
    fi

    print_info "Installing SDDM dependencies..."
    sudo pacman -S --needed qt6-svg qt6-declarative qt5-quickcontrols2 --noconfirm

    print_info "Downloading latest SDDM theme..."
    # Download latest release using generic URL pattern
    wget "https://github.com/$repo/releases/latest/download/$theme_name-sddm.zip"

    if [ ! -f "$theme_name-sddm.zip" ]; then
        print_error "Failed to download SDDM theme"
        return 1
    fi

    print_info "Unzipping theme..."
    unzip "${theme_name}-sddm.zip"

    print_info "Installing theme..."
    sudo mkdir -p /usr/share/sddm/themes
    sudo mv -v "$theme_name" /usr/share/sddm/themes/

    print_info "Configuring SDDM..."
    if [ ! -f "/etc/sddm.conf" ]; then
        sudo touch /etc/sddm.conf
        echo "[Theme]" | sudo tee -a /etc/sddm.conf >/dev/null
        echo "Current=$theme_name" | sudo tee -a /etc/sddm.conf >/dev/null
    else
        if grep -q "^Current=" /etc/sddm.conf; then
            sudo sed -i "s|^Current=.*|Current=$theme_name|" /etc/sddm.conf
        else
            if ! grep -q "^\[Theme\]" /etc/sddm.conf; then
                echo "[Theme]" | sudo tee -a /etc/sddm.conf >/dev/null
            fi
            echo "Current=$theme_name" | sudo tee -a /etc/sddm.conf >/dev/null
        fi
    fi

    # Cleanup
    rm "${theme_name}-sddm.zip"

    print_success "SDDM theme installed successfully!"
}
