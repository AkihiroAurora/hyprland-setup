#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_swaync_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/swaync"
    local theme_name="catppuccin-mocha"
    local repo="catppuccin/swaync"

    # Create theme directory if it doesn't exist
    mkdir -p "$theme_dir"

    # Check if theme is already installed
    if [ -f "$theme_dir/style.css" ]; then
        print_success "Swaync theme is already installed"
        return 0
    fi

    print_info "Installing Swaync theme..."

    # Create and use temp directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    print_info "Downloading Swaync theme..."
    if ! wget "https://github.com/$repo/releases/latest/download/$theme_name.css"; then
        print_error "Failed to download Swaync theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    if [ ! -f "$theme_name.css" ]; then
        print_error "Swaync theme CSS file not found"
        cd "$SCRIPT_DIR"
        return 1
    fi

    print_info "Installing theme..."
    if ! sed -i "s/font-family:.*Ubuntu Nerd Font.*/font-family: 'JetBrainsMono Nerd Font'/g" "$theme_name.css"; then
        print_error "Failed to modify font in Swaync theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    if ! mv -v "$theme_name.css" "$theme_dir/style.css"; then
        print_error "Failed to move Swaync theme to config directory"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd "$SCRIPT_DIR"
    print_success "Swaync theme installed successfully!"
}
