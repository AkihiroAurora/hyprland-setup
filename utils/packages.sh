#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

# Function to check if a package is installed
is_installed() {
    pacman -Qi "$1" &>/dev/null
}

# Dedicated oh-my-posh setup — call this ONCE from setup.sh
setup_oh_my_posh() {
    if command -v oh-my-posh &>/dev/null; then
        print_info "oh-my-posh is already installed"
        return 0
    fi

    print_info "Installing oh-my-posh dependencies..."
    if ! sudo pacman -S --noconfirm --needed unzip; then
        print_error "Failed to install unzip"
        return 1
    fi

    print_info "Installing oh-my-posh via install script..."
    if curl -fsSL https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/bin/; then
        print_success "oh-my-posh installed successfully"
    else
        print_error "Failed to install oh-my-posh"
        return 1
    fi
}

# Generic package installer — no side effects beyond package installation
install_packages() {
    local packages=("$@")
    local to_install=()

    if [ ${#packages[@]} -eq 0 ]; then
        print_warning "install_packages called with no arguments"
        return 0
    fi

    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            print_info "Package '$pkg' is already installed"
        else
            to_install+=("$pkg")
        fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        print_info "All packages are already installed"
        return 0
    fi

    print_info "Installing: ${to_install[*]}"

    # Prefer paru (handles AUR), fall back to pacman
    if command -v paru &>/dev/null; then
        if ! paru -S --noconfirm --needed "${to_install[@]}"; then
            print_error "paru failed to install packages"
            return 1
        fi
    else
        if ! sudo pacman -S --noconfirm --needed "${to_install[@]}"; then
            print_error "pacman failed to install packages"
            return 1
        fi
    fi

    print_success "Packages installed successfully"
}

# Install every package category from packages.conf
install_all_packages() {
    local all_packages=(
        "${CORE_SYSTEM[@]}"
        "${HYPRLAND_DESKTOP[@]}"
        "${APPLICATIONS[@]}"
        "${DEVELOPMENT[@]}"
        "${INTERNET[@]}"
        "${APPEARANCE[@]}"
    )

    install_packages "${all_packages[@]}"
}
