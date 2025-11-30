#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
source "$SCRIPT_DIR/utils/display.sh"
source "$SCRIPT_DIR/utils/aur.sh"
source "$SCRIPT_DIR/utils/packages.sh"

# Source
source "$SCRIPT_DIR/themes/grub.sh"
source "$SCRIPT_DIR/themes/sddm.sh"
source "$SCRIPT_DIR/themes/gtk.sh"
source "$SCRIPT_DIR/themes/swaync.sh"
source "$SCRIPT_DIR/themes/yazi.sh"
source "$SCRIPT_DIR/themes/btop.sh"
source "$SCRIPT_DIR/themes/wallpapers.sh"
source "$SCRIPT_DIR/themes/dotfiles.sh"
source "$SCRIPT_DIR/themes/zsh.sh"

# Exit on any error
set -e

main() {
    # Clear screen and show logo
    clear
    print_logo

    # Check if packages.conf exists
    if [ ! -f "$SCRIPT_DIR/packages.conf" ]; then
        print_error "Error: packages.conf not found!"
        exit 1
    fi

    source "$SCRIPT_DIR/packages.conf"

    # Update system first
    print_info "Updating system..."
    sudo pacman -Syu --noconfirm

    # Install AUR helper if not present
    setup_aur_helper

    # Install Chaotic AUR if not present
    setup_chaotic_aur

    # Improve Mirrorlist
    setup_mirror_list

    # Install packages by category
    install_all_packages

    # Install themes
    rm -rf "$HOME/.config"
    install_grub_theme
    install_sddm_theme
    setup_gtk_theme
    install_swaync_theme
    install_yazi_theme
    install_btop_theme
    install_wallpapers
    install_dotfiles
    setup_zsh_shell

    # Cleanup temp directory
    print_info "Cleaning up temporary files..."
    rm -rf "$SCRIPT_DIR/temp"

    print_success "Setup complete! You may want to reboot your system."
}

main "$@"
