#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_swaync_theme() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local main_script_dir="$(dirname $script_dir)"
    local theme_dir="$main_script_dir/dotfiles/.config/swaync"
    local theme_name="catppuccin-mocha"
    local repo="catppuccin/swaync"

    # Create theme directory if it doesn't exist
    mkdir -p "$theme_dir"

    # Check if theme is already installed
    if [ -f "$theme_dir/style.css" ]; then
        print_info "Swaync theme is already installed"
        return 0
    fi

    print_info "Downloading latest Swaync theme..."
    # Download latest release using generic URL pattern
    wget "https://github.com/$repo/releases/latest/download/$theme_name.css"

    if [ ! -f "$theme_name.css" ]; then
        print_error "Failed to download Swaync theme"
        return 1
    fi

    print_info "Installing theme..."
    sed -i "s/font-family:.*Ubuntu Nerd Font.*/font-family: 'JetBrainsMono Nerd Font'/g" "$theme_name.css"
    mv -v "$theme_name.css" "$theme_dir/style.css"

    print_success "Swaync theme installed successfully!"
}
