#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/display.sh"

enable_ilovecandy() {
    # Enable ILoveCandy in pacman.conf if not already enabled
    if grep -q "^#\?ILoveCandy" /etc/pacman.conf; then
        # If exists (commented or uncommented), ensure it's enabled
        sudo sed -i 's/^#\?ILoveCandy.*$/ILoveCandy/' /etc/pacman.conf
        print_info "ILoveCandy enabled in pacman.conf"
    else
        # If not found at all, add it under #UseSyslog
        sudo sed -i '/^#UseSyslog/a ILoveCandy' /etc/pacman.conf
        print_info "ILoveCandy added and enabled in pacman.conf"
    fi
}

setup_aur_helper() {
    enable_ilovecandy

    # Check if paru is already installed
    if command -v paru &>/dev/null; then
        print_info "paru is already installed"
        return 0
    fi

    print_info "Installing paru AUR helper..."

    sudo pacman -S --needed git base-devel --noconfirm

    if [[ -d "paru" ]]; then
        print_warning "paru directory already exists, removing it..."
        rm -rf paru
    fi

    print_info "Cloning paru repository..."
    git clone https://aur.archlinux.org/paru.git
    cd paru

    print_info "Building paru..."
    makepkg -si --noconfirm

    cd ..
    rm -rf paru

    print_success "paru installed successfully"
}
