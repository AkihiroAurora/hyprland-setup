#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_grub_theme() {
    local temp_dir="$SCRIPT_DIR/temp"

    # Check if already installed
    if [ -d "/usr/share/grub/themes/catppuccin-mocha-grub-theme" ]; then
        print_info "GRUB theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha GRUB theme..."

    # Create and use temp directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    # Clone and enter directory
    if ! git clone https://github.com/catppuccin/grub.git; then
        print_error "Failed to clone GRUB themes repository"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd grub

    # Copy theme
    if ! sudo cp -r src/catppuccin-mocha-grub-theme /usr/share/grub/themes/; then
        print_error "Failed to copy GRUB theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Configure GRUB
    if ! sudo sed -i 's|^#*GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt"|' /etc/default/grub; then
        print_error "Failed to configure GRUB theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Update GRUB
    if ! sudo grub-mkconfig -o /boot/grub/grub.cfg; then
        print_error "Failed to update GRUB configuration"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd "$SCRIPT_DIR"
    print_success "GRUB theme installed successfully!"
}
