#!/bin/bash

# what changed: verify the download is a real, non-empty zip before unzipping, and
# keep both "already installed" checks up top.

source "$SCRIPT_DIR/utils/display.sh"

install_prismlauncher() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_dir="$HOME/.local/share/PrismLauncher/themes"
    local zip="Catppuccin-Mocha-theme.zip"

    if ! command -v prismlauncher &>/dev/null; then
        print_info "installing prismlauncher"
        if ! paru -S --noconfirm prismlauncher; then
            print_error "paru couldn't install prismlauncher"
            return 1
        fi
    else
        print_info "prismlauncher already installed"
    fi

    if [ -d "$theme_dir/Catppuccin-Mocha" ]; then
        print_info "prismlauncher theme already installed"
        return 0
    fi

    print_info "installing the prismlauncher theme"

    mkdir -p "$theme_dir" "$temp_dir" || { print_error "couldn't create theme/temp dirs"; return 1; }
    cd "$temp_dir" || { print_error "couldn't enter $temp_dir"; return 1; }

    rm -rf themes "$zip"

    if ! wget -q -O "$zip" "https://github.com/prismlauncher/themes/releases/latest/download/$zip"; then
        print_error "couldn't download the prismlauncher theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if [ ! -s "$zip" ]; then
        print_error "prismlauncher theme zip is empty"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! unzip -q "$zip"; then
        print_error "couldn't unzip the prismlauncher theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if [ ! -d "themes/Catppuccin-Mocha" ]; then
        print_error "themes/Catppuccin-Mocha missing from the archive"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! cp -r "themes/Catppuccin-Mocha" "$theme_dir/"; then
        print_error "couldn't copy the theme into $theme_dir"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd "$SCRIPT_DIR" || true
    print_success "prismlauncher theme installed"
}
