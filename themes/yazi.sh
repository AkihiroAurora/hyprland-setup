#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_yazi_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/yazi"
    local theme_name="catppuccin-mocha-mauve"

    if ! mkdir -p "$theme_dir" "$temp_dir"; then
        print_error "Failed to create yazi theme/temp directories"
        return 1
    fi

    # ── Already installed? ────────────────────────────────────────────
    if [ -s "$theme_dir/theme.toml" ]; then
        print_success "Yazi theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha Yazi theme..."

    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    rm -rf yazi
    print_info "Cloning yazi themes repository (shallow)..."
    if ! git clone --depth 1 https://github.com/catppuccin/yazi.git; then
        print_error "Failed to clone yazi themes repository"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    # ── Verify the theme source file exists ───────────────────────────
    if [ ! -f "yazi/themes/mocha/$theme_name.toml" ]; then
        print_error "Theme file not found: yazi/themes/mocha/$theme_name.toml"
        print_info "Upstream layout may have changed — check github.com/catppuccin/yazi"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! cp "yazi/themes/mocha/$theme_name.toml" "$theme_dir/theme.toml"; then
        print_error "Failed to copy yazi theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -s "$theme_dir/theme.toml" ]; then
        print_error "Copied yazi theme is empty or missing"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    rm -rf yazi

    cd "$SCRIPT_DIR" || true
    print_success "Yazi theme installed successfully!"
}
