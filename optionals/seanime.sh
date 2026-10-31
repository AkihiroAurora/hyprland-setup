#!/bin/bash

# what changed: small tidy — same checks, but the parity check after install is the
# only source of truth for "it worked".

source "$SCRIPT_DIR/utils/display.sh"

install_seanime() {
    local pkg="seanime-denshi"

    if ! command -v paru &>/dev/null; then
        print_error "paru isn't installed — run setup.sh first"
        return 1
    fi

    if pacman -Qi "$pkg" &>/dev/null; then
        print_info "seanime already installed"
        return 0
    fi

    print_info "installing seanime from the AUR"
    if ! paru -S --noconfirm --needed "$pkg"; then
        print_error "paru couldn't install $pkg"
        return 1
    fi

    if ! pacman -Qi "$pkg" &>/dev/null; then
        print_error "paru said it worked but $pkg isn't installed"
        return 1
    fi
    print_success "seanime installed"
}
