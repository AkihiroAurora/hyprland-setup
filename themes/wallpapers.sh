#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_wallpapers() {
    local src="$SCRIPT_DIR/dotfiles/Pictures/wallpapers"
    local dest="$HOME/Pictures/wallpapers"

    if [ ! -d "$src" ]; then
        print_error "no wallpaper source at $src"
        return 1
    fi

    if [ -z "$(ls -A "$src" 2>/dev/null)" ]; then
        print_warning "wallpaper source is empty — skipping"
        return 0
    fi

    if [ -n "$(ls -A "$dest" 2>/dev/null)" ]; then
        print_info "wallpapers already in $dest"
        return 0
    fi

    print_info "moving wallpapers to $dest"

    mkdir -p "$dest" || {
        print_error "couldn't create $dest"
        return 1
    }
    if ! mv "$src/." "$dest/"; then
        print_error "couldn't move the wallpapers"
        return 1
    fi

    print_success "wallpapers in place"
}
