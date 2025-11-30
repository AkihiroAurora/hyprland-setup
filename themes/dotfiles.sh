#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_dotfiles() {
    local dotfiles_dir="$SCRIPT_DIR/dotfiles"

    # Check if already installed
    if [ -d "$HOME/dotfiles" ]; then
        print_success "Dotfiles are already installed"
        return 0
    fi

    print_info "Installing dotfiles..."

    # Check if source dotfiles directory exists
    if [ ! -d "$dotfiles_dir" ]; then
        print_error "Dotfiles directory not found: $dotfiles_dir"
        return 1
    fi

    # Copy dotfiles to home directory
    if ! cp -r "$dotfiles_dir" "$HOME"; then
        print_error "Failed to copy dotfiles to home directory"
        return 1
    fi

    # Create symlinks using stow
    if command -v stow &>/dev/null; then
        cd "$HOME/dotfiles"
        if ! stow . --no-folding; then
            print_error "Failed to create symlinks with stow"
            return 1
        fi
        cd "$SCRIPT_DIR"
    else
        print_warning "stow not found, skipping symlink creation"
        print_info "You may need to manually create symlinks or install stow"
    fi

    print_success "Dotfiles installed successfully!"
}
