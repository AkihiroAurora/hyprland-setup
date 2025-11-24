#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_sddm_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_name="catppuccin-mocha-mauve"
    local repo="catppuccin/sddm"

    # Check if theme is already installed
    if [ -d "/usr/share/sddm/themes/$theme_name" ]; then
        print_success "SDDM theme is already installed"
        return 0
    fi

    print_info "Installing SDDM theme..."

    # Create and use temp directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    print_info "Installing SDDM dependencies..."
    if ! sudo pacman -S --needed qt6-svg qt6-declarative qt5-quickcontrols2 --noconfirm; then
        print_error "Failed to install SDDM dependencies"
        cd "$SCRIPT_DIR"
        return 1
    fi

    print_info "Downloading SDDM theme..."
    if ! wget "https://github.com/$repo/releases/latest/download/$theme_name-sddm.zip"; then
        print_error "Failed to download SDDM theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    if [ ! -f "$theme_name-sddm.zip" ]; then
        print_error "SDDM theme zip file not found"
        cd "$SCRIPT_DIR"
        return 1
    fi

    print_info "Unzipping theme..."
    if ! unzip "${theme_name}-sddm.zip"; then
        print_error "Failed to unzip SDDM theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    print_info "Installing theme..."
    sudo mkdir -p /usr/share/sddm/themes
    if ! sudo mv -v "$theme_name" /usr/share/sddm/themes/; then
        print_error "Failed to move SDDM theme to themes directory"
        cd "$SCRIPT_DIR"
        return 1
    fi

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

    cd "$SCRIPT_DIR"
    print_success "SDDM theme installed successfully!"
}
