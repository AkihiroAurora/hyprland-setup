#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_yazi_theme() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local main_script_dir="$(dirname $script_dir)"
    local theme_dir="$main_script_dir/dotfiles/.config/yazi"
    local theme_name="catppuccin-mocha-mauve"

    mkdir -p "$theme_dir"

    # Check if already installed
    if [ -d "$theme_dir/theme.toml" ]; then
        print_info "Yazi theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha Yazi theme..."

    # Clone and enter directory
    git clone https://github.com/catppuccin/yazi.git
    cd yazi

    # Copy theme
    cp -r "themes/mocha/$theme_name.toml" "$theme_dir/theme.toml"

    # Cleanup
    cd ..
    rm -rf yazi

    print_success "Yazi theme installed successfully!"
}
