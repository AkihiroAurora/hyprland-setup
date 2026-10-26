#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_prismlauncher() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$HOME/.local/share/PrismLauncher/themes"
    local theme_name="Catppuccin-Mocha-theme"
    local repo="prismlauncher/themes"

    # Check if Prism Launcher is already installed
    if command -v prismlauncher &>/dev/null; then
        print_info "Prism Launcher is already installed"
    else
        print_info "Installing Prism Launcher..."
        if ! paru -S --noconfirm prismlauncher; then
            print_error "Failed to install Prism Launcher"
            return 1
        fi
    fi

    # Check if theme is already installed
    if [ -d "$theme_dir/Catppuccin-Mocha" ]; then
        print_success "Prism Launcher theme is already installed"
        return 0
    fi

    # Create theme directory if it doesn't exist
    if ! mkdir -p "$theme_dir" "$temp_dir"; then
        print_error "Failed to create theme/temp directories"
        return 1
    fi

    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    rm -rf themes "$theme_name.zip"

    # Download prismlauncher themes
    print_info "Downloading Prism Launcher theme..."
    if ! wget -q "https://github.com/$repo/releases/latest/download/$theme_name.zip"; then
        print_error "Failed to download Prism Launcher theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    # Check if download failed
    if [ ! -f "$theme_name.zip" ]; then
        print_error "Theme zip not found after download"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    # Unzip prismlauncher theme
    print_info "Unzipping theme..."
    if ! unzip -q "$theme_name.zip"; then
        print_error "Failed to unzip Prism Launcher theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    # Checks if the theme exist
    if [ ! -d "themes/Catppuccin-Mocha" ]; then
        print_error "Expected themes/Catppuccin-Mocha not found in archive"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    # Install prismlauncher theme
    if ! cp -r "themes/Catppuccin-Mocha" "$theme_dir/"; then
        print_error "Failed to copy theme into $theme_dir"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd "$SCRIPT_DIR" || true
    print_success "Prism Launcher theme installed successfully!"
}
