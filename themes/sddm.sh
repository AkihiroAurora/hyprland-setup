#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_sddm_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_name="catppuccin-mocha-mauve"
    local repo="catppuccin/sddm"

    # ── Already installed? ────────────────────────────────────────────
    if [ -d "/usr/share/sddm/themes/$theme_name" ]; then
        print_success "SDDM theme is already installed"
        return 0
    fi

    print_info "Installing SDDM theme..."

    if ! mkdir -p "$temp_dir"; then
        print_error "Failed to create temp directory"
        return 1
    fi

    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    rm -rf "$theme_name" "$theme_name-sddm.zip"

    print_info "Installing SDDM dependencies..."
    if ! sudo pacman -S --needed --noconfirm qt6-svg qt6-declarative qt5-quickcontrols2; then
        print_error "Failed to install SDDM dependencies"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    print_info "Downloading SDDM theme..."
    if ! curl -fsSL -o "$theme_name-sddm.zip" \
        "https://github.com/$repo/releases/latest/download/$theme_name-sddm.zip"; then
        print_error "Failed to download SDDM theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -s "$theme_name-sddm.zip" ]; then
        print_error "SDDM theme zip file is empty or missing"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    print_info "Unzipping theme..."
    if ! unzip -q "$theme_name-sddm.zip"; then
        print_error "Failed to unzip SDDM theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -d "$theme_name" ]; then
        print_error "Expected theme directory '$theme_name' not found after unzip"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    print_info "Installing theme..."
    if ! sudo mkdir -p /usr/share/sddm/themes; then
        print_error "Failed to create /usr/share/sddm/themes"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! sudo mv "$theme_name" /usr/share/sddm/themes/; then
        print_error "Failed to move SDDM theme to themes directory"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    # ── Configure SDDM ────────────────────────────────────────────────
    print_info "Configuring SDDM..."
    local conf="/etc/sddm.conf"

    if [ ! -f "$conf" ]; then
        sudo touch "$conf"
        echo "[Theme]" | sudo tee -a "$conf" >/dev/null
        echo "Current=$theme_name" | sudo tee -a "$conf" >/dev/null
    else
        if grep -q "^Current=" "$conf"; then
            sudo sed -i "s|^Current=.*|Current=$theme_name|" "$conf"
        else
            if ! grep -q "^\[Theme\]" "$conf"; then
                echo "[Theme]" | sudo tee -a "$conf" >/dev/null
            fi
            echo "Current=$theme_name" | sudo tee -a "$conf" >/dev/null
        fi
    fi

    cd "$SCRIPT_DIR" || true
    print_success "SDDM theme installed successfully!"
}
