#!/bin/bash

# what changed: back up /etc/pacman.conf before editing it; only remove reflector if
# we were the one who installed it (it used to rip out a user's own install); use
# grep in `if` form rather than `cmd && return`, which trips set -e on no match.

source "$SCRIPT_DIR/utils/display.sh"

enable_ilovecandy() {
    [ -f /etc/pacman.conf ] || return 0
    if grep -q '^ILoveCandy' /etc/pacman.conf; then
        return 0
    fi

    if grep -q '^#ILoveCandy' /etc/pacman.conf; then
        sudo sed -i 's/^#ILoveCandy/ILoveCandy/' /etc/pacman.conf || true
    elif grep -q '^# Misc options' /etc/pacman.conf; then
        sudo sed -i '/^# Misc options$/a ILoveCandy' /etc/pacman.conf || true
    fi
}

enable_pacman_colors() {
    [ -f /etc/pacman.conf ] || return 0
    if grep -q '^Color' /etc/pacman.conf; then
        return 0
    fi

    if grep -q '^#Color' /etc/pacman.conf; then
        sudo sed -i 's/^#Color/Color/' /etc/pacman.conf || true
    elif grep -q '^# Misc options' /etc/pacman.conf; then
        sudo sed -i '/^# Misc options$/a Color' /etc/pacman.conf || true
    fi
}

setup_aur_helper() {
    local temp_dir="$SCRIPT_DIR/temp"

    backup_file /etc/pacman.conf
    enable_ilovecandy
    enable_pacman_colors

    if command -v paru &>/dev/null; then
        print_info "paru already installed"
        return 0
    fi

    print_info "building paru from the AUR (this takes a minute)"

    if ! sudo pacman -S --needed --noconfirm git base-devel; then
        print_error "couldn't install git/base-devel, needed to build paru"
        return 1
    fi

    mkdir -p "$temp_dir" || { print_error "couldn't create $temp_dir"; return 1; }
    cd "$temp_dir" || { print_error "couldn't enter $temp_dir"; return 1; }

    rm -rf paru
    if ! git clone --depth 1 https://aur.archlinux.org/paru.git; then
        print_error "couldn't clone paru from aur.archlinux.org"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd paru || { print_error "paru clone has no paru/ directory"; cd "$SCRIPT_DIR" || true; return 1; }

    if ! makepkg -si --noconfirm; then
        print_error "makepkg failed building paru"
        cd "$SCRIPT_DIR" || true
        return 1
    fi
    cd "$SCRIPT_DIR" || true

    if ! command -v paru &>/dev/null; then
        print_error "paru built but isn't on PATH — something's off"
        return 1
    fi
    print_success "paru installed"
}

setup_chaotic_aur() {
    if grep -q '^\[chaotic-aur\]' /etc/pacman.conf 2>/dev/null; then
        print_info "chaotic-aur already configured"
        return 0
    fi

    print_info "adding the chaotic-aur repo"

    backup_file /etc/pacman.conf

    if ! sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com; then
        print_error "couldn't fetch the chaotic-aur key (keyserver unreachable?)"
        return 1
    fi
    if ! sudo pacman-key --lsign-key 3056513887B78AEB; then
        print_error "couldn't sign the chaotic-aur key locally"
        return 1
    fi
    if ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'; then
        print_error "couldn't install chaotic-keyring"
        return 1
    fi
    if ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then
        print_error "couldn't install chaotic-mirrorlist"
        return 1
    fi

    printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' | sudo tee -a /etc/pacman.conf >/dev/null

    # -Sy, not -Syu: setup.sh already did a full upgrade and this is just a sync
    if ! sudo pacman -Sy --noconfirm; then
        print_error "pacman -Sy failed after adding chaotic-aur"
        return 1
    fi

    print_success "chaotic-aur ready"
}

setup_mirror_list() {
    print_info "refreshing mirrors with reflector (best effort)"

    local we_installed_reflector=0
    if ! command -v reflector &>/dev/null; then
        if paru -S --noconfirm --needed reflector 2>/dev/null; then
            we_installed_reflector=1
        else
            print_warning "reflector isn't available — leaving the mirrorlist alone"
            return 0
        fi
    fi

    backup_file /etc/pacman.d/mirrorlist

    local new="/etc/pacman.d/mirrorlist.new"
    if sudo reflector --latest 10 --sort rate --save "$new" && [ -s "$new" ]; then
        if sudo mv "$new" /etc/pacman.d/mirrorlist; then
            print_success "mirrorlist updated"
        else
            print_warning "couldn't swap in the new mirrorlist — keeping the old one"
            sudo rm -f "$new"
        fi
    else
        print_warning "reflector returned nothing usable — keeping the old mirrorlist"
        sudo rm -f "$new"
    fi

    if [ "$we_installed_reflector" -eq 1 ]; then
        paru -Rs --noconfirm reflector 2>/dev/null || true
    fi
}
