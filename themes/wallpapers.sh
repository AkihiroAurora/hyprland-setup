#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_wallpapers() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local main_script_dir="$(dirname $script_dir)"
    local wallpapers="$main_script_dir/dotfiles/wallpapers"

    # Check if already installed
    if [ -d "$HOME/Pictures/wallpapers" ]; then
        print_info "wallpapers are already installed"
        return 0
    fi

    # Create wallpapers directory
    mkdir -p $HOME/Pictures/

    print_info "Installing Catppuccin wallpapers..."

    # Move wallpapers
    mv -r $wallpapers $HOME/Pictures/

    print_success "Wallpapers installed successfully!"
}
