#!/bin/bash

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils/aur.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils/packages.sh"

# Source theming functions
source "$(dirname "${BASH_SOURCE[0]}")/themes/grub.sh"
source "$(dirname "${BASH_SOURCE[0]}")/themes/sddm.sh"
source "$(dirname "${BASH_SOURCE[0]}")/themes/gtk.sh"
source "$(dirname "${BASH_SOURCE[0]}")/themes/swaync.sh"
source "$(dirname "${BASH_SOURCE[0]}")/themes/yazi.sh"
source "$(dirname "${BASH_SOURCE[0]}")/themes/btop.sh"
source "$(dirname "${BASH_SOURCE[0]}")/themes/wallpapers.sh"
source "$(dirname "${BASH_SOURCE[0]}")/themes/dotfiles.sh"

# Exit on any error
set -e

main() {
    # Clear screen and show logo
    clear
    print_logo

    # Check if packages.conf exists
    if [ ! -f "packages.conf" ]; then
        echo "Error: packages.conf not found!"
        exit 1
    fi

    source packages.conf

    # Update system first
    print_info "Updating system..."
    sudo pacman -Syu --noconfirm

    # Install AUR helper if not present
    setup_aur_helper

    # Install packages by category
    install_all_packages

    # Install themes
    install_grub_theme
    install_sddm_theme
    setup_gtk_theme
    isntall_swaync_theme
    install_yazi_theme
    install_btop_theme
    install_wallpapers
    install_dotfiles

    print_success "Setup complete! You may want to reboot your system."
}

main "$@"
