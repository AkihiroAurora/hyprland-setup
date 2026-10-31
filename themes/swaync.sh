#!/bin/bash

# what changed: check "already installed" before creating directories, and keep the
# font swap guarded since upstream keeps dropping the Ubuntu Nerd Font line.

source "$SCRIPT_DIR/utils/display.sh"

install_swaync_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$SCRIPT_DIR/dotfiles/.config/swaync"
    local theme_name="catppuccin-mocha"

    if [ -s "$theme_dir/style.css" ]; then
        print_info "swaync theme already installed"
        return 0
    fi

    print_info "installing the swaync theme"

    mkdir -p "$theme_dir" "$temp_dir" || { print_error "couldn't create the swaync dirs"; return 1; }
    cd "$temp_dir" || { print_error "couldn't enter $temp_dir"; return 1; }

    rm -f "$theme_name.css"

    if ! curl -fsSL -o "$theme_name.css" \
        "https://github.com/catppuccin/swaync/releases/latest/download/$theme_name.css"; then
        print_error "couldn't download the swaync css"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if [ ! -s "$theme_name.css" ]; then
        print_error "swaync css came back empty"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if grep -q "Ubuntu Nerd Font" "$theme_name.css"; then
        sed -i "s/font-family:.*Ubuntu Nerd Font.*/font-family: 'JetBrainsMono Nerd Font';/g" "$theme_name.css"
    else
        print_warning "upstream css no longer mentions Ubuntu Nerd Font — left the font as-is"
    fi

    if ! mv "$theme_name.css" "$theme_dir/style.css"; then
        print_error "couldn't move the css into $theme_dir"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd "$SCRIPT_DIR" || true
    print_success "swaync theme installed"
}
