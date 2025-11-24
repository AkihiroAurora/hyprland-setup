#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_yazi_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/yazi"
    local theme_name="catppuccin-mocha-mauve"

    # Create theme directory if it doesn't exist
    mkdir -p "$theme_dir"

    # Check if already installed
    if [ -f "$theme_dir/theme.toml" ]; then
        print_success "Yazi theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha Yazi theme..."

    # Create and use temp directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    # Clone repository
    if ! git clone https://github.com/catppuccin/yazi.git; then
        print_error "Failed to clone yazi themes repository"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd yazi

    # Copy theme
    if [ ! -f "themes/mocha/$theme_name.toml" ]; then
        print_error "Theme file not found: themes/mocha/$theme_name.toml"
        cd "$SCRIPT_DIR"
        return 1
    fi

    if ! cp "themes/mocha/$theme_name.toml" "$theme_dir/theme.toml"; then
        print_error "Failed to copy yazi theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd "$SCRIPT_DIR"
    print_success "Yazi theme installed successfully!"
}
