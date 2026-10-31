#!/bin/bash

# what changed: move the already-installed check ahead of the dir creation, and
# verify the copied file has content before declaring success.

source "$SCRIPT_DIR/utils/display.sh"

install_btop_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/btop/themes"
    local theme_path="$theme_dir/catppuccin_mocha.theme"

    if [ -s "$theme_path" ]; then
        print_info "btop theme already installed"
        return 0
    fi

    print_info "installing the catppuccin btop theme"

    mkdir -p "$theme_dir" "$temp_dir" || { print_error "couldn't create the btop dirs"; return 1; }
    cd "$temp_dir" || { print_error "couldn't enter $temp_dir"; return 1; }

    rm -rf btop
    if ! git clone --depth 1 https://github.com/catppuccin/btop.git; then
        print_error "couldn't clone the btop themes repo"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -f "btop/themes/catppuccin_mocha.theme" ]; then
        print_error "no btop/themes/catppuccin_mocha.theme in the clone"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! cp "btop/themes/catppuccin_mocha.theme" "$theme_path"; then
        print_error "couldn't copy the btop theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if [ ! -s "$theme_path" ]; then
        print_error "copied btop theme is empty"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    rm -rf btop
    cd "$SCRIPT_DIR" || true
    print_success "btop theme installed"
}
