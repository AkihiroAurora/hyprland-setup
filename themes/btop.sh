#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_btop_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/btop/themes"
    local theme_path="$theme_dir/catppuccin_mocha.theme"

    # Create theme directory if it doesn't exist
    mkdir -p "$theme_dir"

    # Check if already installed
    if [ -f "$theme_path" ]; then
        print_info "Btop theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha Btop theme..."

    # Create and use temp directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    # Clone and enter directory
    if ! git clone https://github.com/catppuccin/btop.git; then
        print_error "Failed to clone btop themes repository"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Copy theme
    if ! cp -r btop/themes/catppuccin_mocha.theme "$theme_dir"; then
        print_error "Failed to copy btop theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd "$SCRIPT_DIR"
    print_success "Btop theme installed successfully!"
}
