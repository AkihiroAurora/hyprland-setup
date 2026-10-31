#!/bin/bash

# what changed: refuse to run as root, warm up sudo once so it doesn't prompt in the
# middle of the paru build, coax temp cleanup via an EXIT trap, and don't move an
# already-stowed ~/.config out from under a re-run.

# absolute path to this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils/display.sh"
source "$SCRIPT_DIR/utils/aur.sh"
source "$SCRIPT_DIR/utils/packages.sh"

source "$SCRIPT_DIR/themes/grub.sh"
source "$SCRIPT_DIR/themes/sddm.sh"
source "$SCRIPT_DIR/themes/gtk.sh"
source "$SCRIPT_DIR/themes/swaync.sh"
source "$SCRIPT_DIR/themes/yazi.sh"
source "$SCRIPT_DIR/themes/btop.sh"
source "$SCRIPT_DIR/themes/wallpapers.sh"
source "$SCRIPT_DIR/themes/dotfiles.sh"
source "$SCRIPT_DIR/themes/zsh.sh"

set -e

# clears scratch space; runs on any exit so an aborted run doesn't leave junk
cleanup() {
    cd "$SCRIPT_DIR" 2>/dev/null || true
    if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/temp" ]; then
        rm -rf "$SCRIPT_DIR/temp" 2>/dev/null || sudo rm -rf "$SCRIPT_DIR/temp"
    fi
}
trap cleanup EXIT

backup_config() {
    [ -d "$HOME/.config" ] || return 0
    if [ -z "$(ls -A "$HOME/.config" 2>/dev/null)" ]; then
        return 0
    fi

    # if the symlinks point back at ~/dotfiles, this is our own stow output —
    # moving it would break the install, so leave it be
    if find "$HOME/.config" -maxdepth 3 -type l -lname "$HOME/dotfiles/*" -print -quit 2>/dev/null | grep -q .; then
        print_info "~/.config looks stow-managed already — skipping backup"
        return 0
    fi

    local backup="$HOME/.config.bak.$(date +%Y%m%d-%H%M%S)"
    print_warning "moving your existing ~/.config to $backup"
    if ! mv "$HOME/.config" "$backup"; then
        print_error "couldn't back up ~/.config — stopping so we don't clobber it"
        return 1
    fi
    print_info "backup at $backup"
}

main() {
    if [ "$(id -u)" -eq 0 ]; then
        print_error "don't run this as root — it installs into \$HOME and calls sudo on its own"
        exit 1
    fi

    clear
    print_logo

    if [ ! -f "$SCRIPT_DIR/packages.conf" ]; then
        print_error "packages.conf is missing next to setup.sh"
        exit 1
    fi
    source "$SCRIPT_DIR/packages.conf"

    # one prompt up front beats getting asked midway through the paru build
    if ! sudo -v; then
        print_error "sudo isn't cooperating — can't continue"
        exit 1
    fi

    print_info "updating the system"
    if ! sudo pacman -Syu --noconfirm; then
        print_error "pacman -Syu failed — sort that out before re-running"
        exit 1
    fi

    setup_aur_helper
    setup_chaotic_aur
    setup_mirror_list
    install_all_packages
    setup_oh_my_posh

    backup_config
    install_grub_theme
    install_sddm_theme
    setup_gtk_theme
    install_swaync_theme
    install_yazi_theme
    install_btop_theme
    install_dotfiles
    install_wallpapers
    setup_zsh_shell

    print_info "cleaning up scratch files"
    print_success "done — reboot when you get a chance"
}

main "$@"
