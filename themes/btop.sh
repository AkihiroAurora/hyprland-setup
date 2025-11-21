#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_btop_theme() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local main_script_dir="$(dirname $script_dir)"
    local theme_dir="$main_script_dir/dotfiles/.config/btop/themes"
    local theme_path="$theme_dir/catppuccin_mocha.theme"

    # Check if already installed
    if [ -f "$theme_path" ]; then
        print_info "Btop theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha Btop theme..."

    # Clone and enter directory
    git clone https://github.com/catppuccin/btop.git

    # Copy theme
    cp -r btop/themes/catppuccin_mocha.theme "$theme_dir"

    # Cleanup
    rm -rf btop

    print_success "Btop theme installed successfully!"
}
