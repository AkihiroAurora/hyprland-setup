#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

# Function to check if a package is installed
is_installed() {
    pacman -Qi "$1" &>/dev/null
}

# Function to install packages if not already installed
install_packages() {
    local packages=("$@")
    local to_install=()

    # Install oh-my-posh dependencies
    print_info "Installing oh-my-posh dependencies..."
    sudo pacman -S --noconfirm unzip

    # Install oh-my-posh
    if ! command -v oh-my-posh &>/dev/null; then
        print_info "Installing oh-my-posh via install script..."
        if curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/bin/; then
            print_success "oh-my-posh installed successfully"
        else
            print_error "Failed to install oh-my-posh"
            return 1
        fi
    else
        print_info "Package 'oh-my-posh' is already installed"
    fi

    for pkg in "${packages[@]}"; do
        if ! is_installed "$pkg"; then
            to_install+=("$pkg")
        else
            print_info "Package '$pkg' is already installed"
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        print_info "Installing: ${to_install[*]}"

        # Use available AUR helper or fallback to pacman
        if command -v paru &>/dev/null; then
            paru -S --noconfirm --needed "${to_install[@]}"
        else
            sudo pacman -S --noconfirm --needed "${to_install[@]}"
        fi

        print_success "Packages installed successfully"
    else
        print_info "All packages are already installed"
    fi
}

# install all packages
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
