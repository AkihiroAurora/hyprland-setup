#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_wallpapers() {
    local wallpapers="$SCRIPT_DIR/dotfiles/Pictures/"

    # Check if already installed
    if [ -d "$HOME/Pictures/wallpapers" ]; then
        print_info "wallpapers are already installed"
        return 0
    fi

    print_info "Installing Catppuccin wallpapers..."

    # Move wallpapers
    mv -r $wallpapers $HOME

    print_success "Wallpapers installed successfully!"
}
