#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_seanime() {
    local pkg="seanime-denshi"

    print_info "Installing Seanime"

    if ! command -v paru &>/dev/null; then
        print_error "paru is not installed — run setup.sh first"
        return 1
    fi

    # Checks if seanime is already installed
    if pacman -Qi "$pkg" &>/dev/null; then
        print_success "Seanime is already installed"
        return 0
    fi

    # Install seanime with paru
    if ! paru -S --noconfirm --needed "$pkg"; then
        print_error "Failed to install $pkg from the AUR"
        return 1
    fi

    # Verify if seanime installed correctly
    if pacman -Qi "$pkg" &>/dev/null; then
        print_success "Seanime installed successfully via the AUR"
    else
        print_error "paru reported success but $pkg is not installed"
        return 1
    fi
}
