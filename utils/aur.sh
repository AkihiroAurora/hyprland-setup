#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

enable_ilovecandy() {
    # Check if ILoveCandy is already enabled (uncommented)
    if grep -q "^ILoveCandy" /etc/pacman.conf; then
        return 0
    fi

    # Check if ILoveCandy is commented out
    if grep -q "^#ILoveCandy" /etc/pacman.conf; then
        sudo sed -i 's/^#ILoveCandy/ILoveCandy/' /etc/pacman.conf
    else
        # Add it under the Misc options section if not found
        sudo sed -i '/^#Misc options$/a ILoveCandy' /etc/pacman.conf
    fi
}

enable_pacman_colors() {
    # Check if Color is already enabled (uncommented)
    if grep -q "^Color" /etc/pacman.conf; then
        return 0
    fi

    # Check if Color is commented out
    if grep -q "^#Color" /etc/pacman.conf; then
        sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    else
        # Add it under the Misc options section if not found
        sudo sed -i '/^#Misc options$/a Color' /etc/pacman.conf
    fi
}

setup_aur_helper() {
    local temp_dir="$SCRIPT_DIR/temp"

    enable_ilovecandy
    enable_pacman_colors

    # Check if paru is already installed
    if command -v paru &>/dev/null; then
        print_info "paru is already installed"
        return 0
    fi

    print_info "Installing paru AUR helper..."

    # Install dependencies
    sudo pacman -S --needed git base-devel --noconfirm

    # Create temporary directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    # Clean up any existing paru directory
    if [[ -d "paru" ]]; then
        print_warning "paru directory already exists, removing it..."
        rm -rf paru
    fi

    # Clone and build paru
    print_info "Cloning paru repository..."
    if ! git clone https://aur.archlinux.org/paru.git; then
        print_error "Failed to clone paru repository"
        return 1
    fi

    cd paru

    print_info "Building paru..."
    if ! makepkg -si --noconfirm; then
        print_error "Failed to build paru"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd "$SCRIPT_DIR"

    # Verify installation
    if command -v paru &>/dev/null; then
        print_success "paru installed successfully"
    else
        print_error "paru installation may have failed - command not found"
        return 1
    fi
}

setup_chaotic_aur() {
    print_info "Setting up Chaotic AUR..."

    # Check if Chaotic AUR is already configured
    if grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
        print_success "Chaotic AUR is already configured"
        return 0
    fi

    # Import and sign the key
    if ! sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com; then
        print_error "Failed to receive Chaotic AUR key"
        return 1
    fi

    if ! sudo pacman-key --lsign-key 3056513887B78AEB; then
        print_error "Failed to sign Chaotic AUR key"
        return 1
    fi

    # Install keyring and mirrorlist
    if ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'; then
        print_error "Failed to install chaotic-keyring"
        return 1
    fi

    if ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then
        print_error "Failed to install chaotic-mirrorlist"
        return 1
    fi

    # Append Chaotic AUR repository to pacman.conf
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null

    # Update system
    sudo pacman -Syu --noconfirm

    print_success "Chaotic AUR setup completed successfully"
}
