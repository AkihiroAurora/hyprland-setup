#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_grub_theme() {
    # Check if already installed
    if [ -d "/usr/share/grub/themes/catppuccin-mocha-grub-theme" ]; then
        print_info "GRUB theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha GRUB theme..."

    # Clone and enter directory
    git clone https://github.com/catppuccin/grub.git
    cd grub

    # Copy theme
    sudo cp -r src/catppuccin-mocha-grub-theme /usr/share/grub/themes/

    # Configure GRUB
    sudo sed -i 's|^#*GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt"|' /etc/default/grub

    # Update GRUB
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # Cleanup
    cd ..
    rm -rf grub

    print_success "GRUB theme installed successfully!"
}
