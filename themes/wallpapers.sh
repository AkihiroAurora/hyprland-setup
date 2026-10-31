#!/bin/bash

# what changed: copy the wallpapers instead of moving them out of the repo. the old
# mv gutted the source, so a second run (and the dotfiles step) found nothing there.

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

    print_info "copying wallpapers to $dest"

    mkdir -p "$dest" || { print_error "couldn't create $dest"; return 1; }
    if ! cp -r "$src/." "$dest/"; then
        print_error "couldn't copy the wallpapers"
        return 1
    fi

    print_success "wallpapers in place"
}
