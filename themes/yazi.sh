#!/bin/bash

# what changed: don't create dirs before the already-installed check; otherwise same
# shallow clone + copy, just with tighter checks.

source "$SCRIPT_DIR/utils/display.sh"

install_yazi_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/yazi"
    local theme_name="catppuccin-mocha-mauve"

    if [ -s "$theme_dir/theme.toml" ]; then
        print_info "yazi theme already installed"
        return 0
    fi

    print_info "installing the catppuccin yazi theme"

    mkdir -p "$theme_dir" "$temp_dir" || { print_error "couldn't create the yazi dirs"; return 1; }
    cd "$temp_dir" || { print_error "couldn't enter $temp_dir"; return 1; }

    rm -rf yazi
    if ! git clone --depth 1 https://github.com/catppuccin/yazi.git; then
        print_error "couldn't clone the yazi themes repo"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -f "yazi/themes/mocha/$theme_name.toml" ]; then
        print_error "no yazi/themes/mocha/$theme_name.toml — upstream layout moved?"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! cp "yazi/themes/mocha/$theme_name.toml" "$theme_dir/theme.toml"; then
        print_error "couldn't copy the yazi theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if [ ! -s "$theme_dir/theme.toml" ]; then
        print_error "copied yazi theme is empty"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    rm -rf yazi
    cd "$SCRIPT_DIR" || true
    print_success "yazi theme installed"
}
