#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_grub_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dest="/usr/share/grub/themes/catppuccin-mocha-grub-theme"

    if [ -d "$theme_dest" ]; then
        print_info "GRUB theme is already installed"
        return 0
    fi

    if ! command -v grub-mkconfig &>/dev/null; then
        print_error "grub-mkconfig not found — is GRUB installed?"
        return 1
    fi

    print_info "Installing Catppuccin Mocha GRUB theme..."

    if ! mkdir -p "$temp_dir" "$(dirname "$theme_dest")"; then
        print_error "Failed to create theme/temp directories"
        return 1
    fi

    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    rm -rf grub
    print_info "Cloning GRUB themes repository (shallow)..."
    if ! git clone --depth 1 https://github.com/catppuccin/grub.git; then
        print_error "Failed to clone GRUB themes repository"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -d "grub/src/catppuccin-mocha-grub-theme" ]; then
        print_error "Theme source not found: grub/src/catppuccin-mocha-grub-theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -f "grub/src/catppuccin-mocha-grub-theme/theme.txt" ]; then
        print_error "Theme is incomplete — theme.txt missing from source"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! sudo cp -r "grub/src/catppuccin-mocha-grub-theme" /usr/share/grub/themes/; then
        print_error "Failed to copy GRUB theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    local grub_default="/etc/default/grub"
    local grub_backup="/etc/default/grub.bak.$(date +%Y%m%d-%H%M%S)"

    if [ ! -f "$grub_default" ]; then
        print_error "GRUB config not found: $grub_default"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! sudo cp "$grub_default" "$grub_backup"; then
        print_error "Failed to back up $grub_default"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    print_info "Backed up GRUB config to $grub_backup"

    local theme_line="GRUB_THEME=\"$theme_dest/theme.txt\""

    if grep -q '^GRUB_THEME=' "$grub_default"; then
        sudo sed -i "s|^GRUB_THEME=.*|$theme_line|" "$grub_default"
    elif grep -q '^#.*GRUB_THEME=' "$grub_default"; then
        sudo sed -i "s|^#.*GRUB_THEME=.*|$theme_line|" "$grub_default"
    else
        echo "$theme_line" | sudo tee -a "$grub_default" >/dev/null
    fi

    if ! grep -q "^GRUB_THEME=" "$grub_default"; then
        print_error "Failed to set GRUB_THEME — restoring backup"
        sudo cp "$grub_backup" "$grub_default"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    print_info "Regenerating GRUB configuration..."
    if ! sudo grub-mkconfig -o /boot/grub/grub.cfg; then
        print_error "Failed to update GRUB configuration"
        print_info "Your backup at $grub_backup is untouched"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    rm -rf grub

    cd "$SCRIPT_DIR" || true
    print_success "GRUB theme installed successfully!"
}
