#!/bin/bash

# what changed: verify the theme source before touching system paths, create the
# system theme dir explicitly (it isn't always there), and keep the timed backup
# so a failed grub-mkconfig can tell the user where their old config went.

source "$SCRIPT_DIR/utils/display.sh"

install_grub_theme() {
    local temp_dir="$SCRIPT_DIR/temp"
    local theme_src="grub/src/catppuccin-mocha-grub-theme"
    local theme_dest="/usr/share/grub/themes/catppuccin-mocha-grub-theme"
    local grub_default="/etc/default/grub"

    if [ -d "$theme_dest" ]; then
        print_info "grub theme already installed"
        return 0
    fi

    if ! command -v grub-mkconfig &>/dev/null; then
        print_error "grub-mkconfig not found — is grub actually installed?"
        return 1
    fi
    if [ ! -f "$grub_default" ]; then
        print_error "no $grub_default — skipping the grub theme"
        return 1
    fi

    print_info "installing the catppuccin grub theme"

    mkdir -p "$temp_dir" || { print_error "couldn't create $temp_dir"; return 1; }
    if ! sudo mkdir -p /usr/share/grub/themes; then
        print_error "couldn't create /usr/share/grub/themes"
        return 1
    fi

    cd "$temp_dir" || { print_error "couldn't enter $temp_dir"; return 1; }

    rm -rf grub
    if ! git clone --depth 1 https://github.com/catppuccin/grub.git; then
        print_error "couldn't clone the grub themes repo"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [ ! -f "$theme_src/theme.txt" ]; then
        print_error "theme.txt missing from $theme_src — upstream layout moved?"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! sudo cp -r "$theme_src" /usr/share/grub/themes/; then
        print_error "couldn't copy the theme into /usr/share/grub/themes"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    local backup="/etc/default/grub.bak.$(date +%Y%m%d-%H%M%S)"
    if ! sudo cp "$grub_default" "$backup"; then
        print_error "couldn't back up $grub_default — leaving it untouched"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    local theme_line="GRUB_THEME=\"$theme_dest/theme.txt\""
    if grep -q '^GRUB_THEME=' "$grub_default"; then
        sudo sed -i "s|^GRUB_THEME=.*|$theme_line|" "$grub_default"
    elif grep -q '^#.*GRUB_THEME=' "$grub_default"; then
        sudo sed -i "s|^#.*GRUB_THEME=.*|$theme_line|" "$grub_default"
    else
        printf '%s\n' "$theme_line" | sudo tee -a "$grub_default" >/dev/null
    fi

    if ! grep -q '^GRUB_THEME=' "$grub_default"; then
        print_error "GRUB_THEME didn't stick — restoring the backup"
        sudo cp "$backup" "$grub_default"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    print_info "regenerating grub.cfg"
    if ! sudo grub-mkconfig -o /boot/grub/grub.cfg; then
        print_error "grub-mkconfig failed — your original is at $backup"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    rm -rf grub
    cd "$SCRIPT_DIR" || true
    print_success "grub theme installed"
}
