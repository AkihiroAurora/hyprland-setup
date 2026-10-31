#!/bin/bash

# what changed: back up /etc/sddm.conf first, put Current= under the [Theme] block
# instead of blindly appending it, and treat qt5-quickcontrols2 as optional so a
# package that got dropped from the repos doesn't abort the whole install.

source "$SCRIPT_DIR/utils/display.sh"

install_sddm_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_name="catppuccin-mocha-mauve"
    local zip="$theme_name-sddm.zip"

    if [ -d "/usr/share/sddm/themes/$theme_name" ]; then
        print_info "sddm theme already installed"
        return 0
    fi

    print_info "installing the sddm theme"

    mkdir -p "$temp_dir" || { print_error "couldn't create $temp_dir"; return 1; }
    cd "$temp_dir" || { print_error "couldn't enter $temp_dir"; return 1; }

    rm -rf "$theme_name" "$zip"

    if ! sudo pacman -S --needed --noconfirm qt6-svg qt6-declarative; then
        print_error "couldn't install the qt deps the theme needs"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    # older sddm themes still ask for this; not a hard requirement anymore
    sudo pacman -S --needed --noconfirm qt5-quickcontrols2 ||
        print_warning "qt5-quickcontrols2 unavailable — a few widgets may look off"

    if ! curl -fsSL -o "$zip" \
        "https://github.com/catppuccin/sddm/releases/latest/download/$zip"; then
        print_error "couldn't download the sddm theme from github"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if [ ! -s "$zip" ]; then
        print_error "downloaded sddm theme is empty"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! unzip -q "$zip"; then
        print_error "couldn't unzip the sddm theme"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if [ ! -d "$theme_name" ]; then
        print_error "expected a $theme_name/ directory in the archive, didn't find one"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! sudo mkdir -p /usr/share/sddm/themes; then
        print_error "couldn't create /usr/share/sddm/themes"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    if ! sudo mv "$theme_name" /usr/share/sddm/themes/; then
        print_error "couldn't install the theme directory"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    local conf="/etc/sddm.conf"
    if [ -f "$conf" ] && [ ! -f "$conf.bak" ]; then
        sudo cp -a "$conf" "$conf.bak" || print_warning "couldn't back up $conf"
    fi

    if [ ! -f "$conf" ]; then
        printf '[Theme]\nCurrent=%s\n' "$theme_name" | sudo tee "$conf" >/dev/null
    elif grep -q '^\[Theme\]' "$conf"; then
        if grep -q '^Current=' "$conf"; then
            sudo sed -i "s|^Current=.*|Current=$theme_name|" "$conf"
        else
            sudo sed -i "/^\[Theme\]/a Current=$theme_name" "$conf"
        fi
    else
        printf '\n[Theme]\nCurrent=%s\n' "$theme_name" | sudo tee -a "$conf" >/dev/null
    fi

    cd "$SCRIPT_DIR" || true
    print_success "sddm theme installed"
}
