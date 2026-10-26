#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_btop_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/btop/themes"
    local theme_path="$theme_dir/catppuccin_mocha.theme"

    if ! mkdir -p "$theme_dir" "$temp_dir"; then
        print_error "Failed to create btop theme/temp directories"
        return 1
    fi

    # ── Already installed? Verify it's a real file, not empty. ────────
    if [ -s "$theme_path" ]; then
        print_info "Btop theme is already installed"
        return 0
    fi

    print_info "Installing Catppuccin Mocha Btop theme..."

    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    rm -rf btop
    print_info "Cloning btop themes repository (shallow)..."
    if ! git clone --depth 1 https://github.com/catppuccin/btop.git; then
        print_error "Failed to clone btop themes repository"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -f "btop/themes/catppuccin_mocha.theme" ]; then
        print_error "Theme file not found in cloned repo: btop/themes/catppuccin_mocha.theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! cp "btop/themes/catppuccin_mocha.theme" "$theme_path"; then
        print_error "Failed to copy btop theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -s "$theme_path" ]; then
        print_error "Copied theme file is empty or missing"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    rm -rf btop

    cd "$SCRIPT_DIR" || true
    print_success "Btop theme installed successfully!"
}
