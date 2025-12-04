#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_prismlauncher() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$HOME/.local/share/PrismLauncher/themes"
    local theme_name="Catppuccin-Mocha-theme"
    local repo="prismlauncher/themes"

    # Create theme directory if it doesn't exist
    mkdir -p "$theme_dir"

    # Check if Prism Launcher is already installed
    if command -v prismlauncher &>/dev/null; then
        print_info "Prism Launcher is already installed"
        return 0
    fi

    print_info "Installing Prism Launcher..."
    paru -S --noconfirm prismlauncher

    # Create and use temp directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    if ! wget "https://github.com/$repo/releases/latest/download/$theme_name.zip"; then
        print_error "Failed to download Swaync theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Copy theme
    if ! sudo unzip "$theme_name.zip"; then
        print_error "Failed to unzip Prism Launcher theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Copy theme
    if ! sudo cp -r "themes/Catppuccin-Mocha" "$theme_dir"; then
        print_error "Failed to copy Prism Launcher theme"
        cd "$SCRIPT_DIR"
        return 1
    fi

    cd "$SCRIPT_DIR"
    print_success "Prism Launcher installed successfully!"
}
