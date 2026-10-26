#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_swaync_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/swaync"
    local theme_name="catppuccin-mocha"
    local repo="catppuccin/swaync"

    if ! mkdir -p "$theme_dir" "$temp_dir"; then
        print_error "Failed to create swaync theme/temp directories"
        return 1
    fi

    # ── Already installed? ────────────────────────────────────────────
    if [ -s "$theme_dir/style.css" ]; then
        print_success "Swaync theme is already installed"
        return 0
    fi

    print_info "Installing Swaync theme..."

    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    rm -f "$theme_name.css"

    print_info "Downloading Swaync theme..."
    if ! curl -fsSL -o "$theme_name.css" \
        "https://github.com/$repo/releases/latest/download/$theme_name.css"; then
        print_error "Failed to download Swaync theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -s "$theme_name.css" ]; then
        print_error "Swaync theme CSS file is empty or missing"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    # ── Font replacement — warn if the upstream pattern isn't found ──
    if grep -q "Ubuntu Nerd Font" "$theme_name.css"; then
        sed -i "s/font-family:.*Ubuntu Nerd Font.*/font-family: 'JetBrainsMono Nerd Font';/g" "$theme_name.css"
    else
        print_warning "Upstream CSS no longer contains 'Ubuntu Nerd Font' — font not modified"
        print_info "Check $theme_dir/style.css manually if text renders oddly"
    fi

    if ! mv "$theme_name.css" "$theme_dir/style.css"; then
        print_error "Failed to move Swaync theme to config directory"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd "$SCRIPT_DIR" || true
    print_success "Swaync theme installed successfully!"
}
