#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_wallpapers() {
    local wallpapers="$SCRIPT_DIR/dotfiles/Pictures/wallpapers"

    if [ -d "$HOME/Pictures/wallpapers" ]; then
        print_info "wallpapers are already installed"
        return 0
    fi

    print_info "Installing Catppuccin wallpapers..."

    mkdir -p "$HOME/Pictures"
    mv "$wallpapers" "$HOME/Pictures/"

    print_success "Wallpapers installed successfully!"
}
