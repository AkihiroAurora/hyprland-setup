#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

enable_ilovecandy() {
    if grep -q "^ILoveCandy" /etc/pacman.conf; then
        return 0
    fi

    if grep -q "^#ILoveCandy" /etc/pacman.conf; then
        sudo sed -i 's/^#ILoveCandy/ILoveCandy/' /etc/pacman.conf || true
    else
        sudo sed -i '/^# Misc options$/a ILoveCandy' /etc/pacman.conf || true
    fi
}

enable_pacman_colors() {
    if grep -q "^Color" /etc/pacman.conf; then
        return 0
    fi

    if grep -q "^#Color" /etc/pacman.conf; then
        sudo sed -i 's/^#Color/Color/' /etc/pacman.conf || true
    else
        sudo sed -i '/^# Misc options$/a Color' /etc/pacman.conf || true
    fi
}

setup_aur_helper() {
    local temp_dir="$SCRIPT_DIR/temp"

    enable_ilovecandy
    enable_pacman_colors

    if command -v paru &>/dev/null; then
        print_info "paru is already installed"
        return 0
    fi

    print_info "Installing paru AUR helper..."

    if ! sudo pacman -S --needed --noconfirm git base-devel; then
        print_error "Failed to install paru build dependencies"
        return 1
    fi

    mkdir -p "$temp_dir"
    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    if [[ -d "paru" ]]; then
        print_warning "paru directory already exists, removing it..."
        rm -rf paru
    fi

    print_info "Cloning paru repository..."
    if ! git clone https://aur.archlinux.org/paru.git; then
        print_error "Failed to clone paru repository"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd paru || {
        print_error "Failed to cd into paru"
        cd "$SCRIPT_DIR" || true
        return 1
    }

    print_info "Building paru..."
    if ! makepkg -si --noconfirm; then
        print_error "Failed to build paru"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd "$SCRIPT_DIR" || true

    if command -v paru &>/dev/null; then
        print_success "paru installed successfully"
    else
        print_error "paru installation may have failed — command not found"
        return 1
    fi
}

setup_chaotic_aur() {
    print_info "Setting up Chaotic AUR..."

    if grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
        print_success "Chaotic AUR is already configured"
        return 0
    fi

    if ! sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com; then
        print_error "Failed to receive Chaotic AUR key"
        return 1
    fi

    if ! sudo pacman-key --lsign-key 3056513887B78AEB; then
        print_error "Failed to sign Chaotic AUR key"
        return 1
    fi

    if ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'; then
        print_error "Failed to install chaotic-keyring"
        return 1
    fi

    if ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then
        print_error "Failed to install chaotic-mirrorlist"
        return 1
    fi

    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null

    if ! sudo pacman -Syu --noconfirm; then
        print_error "Failed to sync after adding Chaotic AUR"
        return 1
    fi

    print_success "Chaotic AUR setup completed successfully"
}

setup_mirror_list() {
    print_info "Refreshing mirror list (best-effort)..."

    if ! command -v reflector &>/dev/null; then
        if ! paru -S --noconfirm --needed reflector; then
            print_warning "Could not install reflector — skipping mirror refresh"
            return 0
        fi
    fi

    local backup="/etc/pacman.d/mirrorlist.bak.$(date +%s)"
    local new="/etc/pacman.d/mirrorlist.new"

    sudo cp /etc/pacman.d/mirrorlist "$backup" 2>/dev/null || true

    if sudo reflector -l 10 --sort rate --save "$new" && [ -s "$new" ]; then
        if sudo mv "$new" /etc/pacman.d/mirrorlist; then
            print_success "Mirror list updated successfully"
        else
            print_warning "Failed to install new mirrorlist — keeping existing one"
            sudo rm -f "$new"
        fi
    else
        print_warning "reflector produced no useful output — keeping existing mirrorlist"
        sudo rm -f "$new"
    fi

    paru -Rs --noconfirm reflector 2>/dev/null || true
}
