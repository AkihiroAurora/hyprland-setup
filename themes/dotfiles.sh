#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

install_dotfiles() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local main_script_dir="$(dirname $script_dir)"
    local dotfiles_dir="$main_script_dir/dotfiles/"

    # Check if already installed
    if [ -d "$HOME/dotfiles" ]; then
        print_info "dotfiles are already installed"
        return 0
    fi

    print_info "Installing dotfiles..."

    # Copy theme
    mv "$dotfiles_dir" "$HOME"

    # Create symlinks
    cd "$HOME/dotfiles"
    stow . --no-folding

    print_success "dotfiles installed successfully!"
}
