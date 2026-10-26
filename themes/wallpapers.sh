#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_wallpapers() {
    local wallpapers="$SCRIPT_DIR/dotfiles/Pictures/wallpapers"
    local dest="$HOME/Pictures/wallpapers"

    if [ -d "$dest" ]; then
        print_info "Wallpapers are already installed"
        return 0
    fi

    if [ ! -d "$wallpapers" ]; then
        print_error "Wallpaper source not found: $wallpapers"
        return 1
    fi

    if [ -z "$(ls -A "$wallpapers" 2>/dev/null)" ]; then
        print_warning "Wallpaper source directory is empty — skipping"
        return 0
    fi

    print_info "Installing Catppuccin wallpapers..."

    if ! mkdir -p "$HOME/Pictures"; then
        print_error "Failed to create $HOME/Pictures"
        return 1
    fi

    if ! mv "$wallpapers" "$dest"; then
        print_error "Failed to move wallpapers to $dest"
        return 1
    fi

    print_success "Wallpapers installed successfully!"
}
