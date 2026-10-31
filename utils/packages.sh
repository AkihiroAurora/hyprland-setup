#!/bin/bash

# what changed: declare the loop vars, and download the oh-my-posh installer to a
# file first — the old `curl | sudo bash` literally always "succeeded", even when
# the download 404'd, because the exit status came from bash reading empty stdin.

source "$SCRIPT_DIR/utils/display.sh"

is_installed() {
    pacman -Qi "$1" &>/dev/null
}

setup_oh_my_posh() {
    if command -v oh-my-posh &>/dev/null; then
        print_info "oh-my-posh already installed"
        return 0
    fi

    if ! sudo pacman -S --noconfirm --needed unzip; then
        print_error "couldn't install unzip"
        return 1
    fi

    local tmp
    tmp=$(mktemp) || { print_error "mktemp failed"; return 1; }

    if ! curl -fsSL https://ohmyposh.dev/install.sh -o "$tmp"; then
        print_error "couldn't download the oh-my-posh installer from ohmyposh.dev"
        rm -f "$tmp"
        return 1
    fi
    if [ ! -s "$tmp" ]; then
        print_error "oh-my-posh installer came back empty"
        rm -f "$tmp"
        return 1
    fi

    if ! sudo bash "$tmp" -d /usr/bin/; then
        print_error "the oh-my-posh installer failed"
        rm -f "$tmp"
        return 1
    fi
    rm -f "$tmp"

    if command -v oh-my-posh &>/dev/null; then
        print_success "oh-my-posh installed"
    else
        print_error "installer reported ok but oh-my-posh isn't on PATH"
        return 1
    fi
}

install_packages() {
    local packages=("$@")
    local to_install=()
    local pkg

    if [ ${#packages[@]} -eq 0 ]; then
        print_warning "install_packages called with no packages"
        return 0
    fi

    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            print_info "$pkg already present"
        else
            to_install+=("$pkg")
        fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        print_info "everything in this list is already installed"
        return 0
    fi

    print_info "installing: ${to_install[*]}"

    # paru handles AUR packages too, so prefer it when it's around
    if command -v paru &>/dev/null; then
        if ! paru -S --noconfirm --needed "${to_install[@]}"; then
            print_error "paru failed on: ${to_install[*]}"
            return 1
        fi
    else
        if ! sudo pacman -S --noconfirm --needed "${to_install[@]}"; then
            print_error "pacman failed on: ${to_install[*]}"
            return 1
        fi
    fi

    print_success "packages installed"
}

install_all_packages() {
    local all_packages=(
        "${CORE_SYSTEM[@]}"
        "${HYPRLAND_DESKTOP[@]}"
        "${APPLICATIONS[@]}"
        "${DEVELOPMENT[@]}"
        "${INTERNET[@]}"
        "${APPEARANCE[@]}"
    )

    install_packages "${all_packages[@]}"
}
