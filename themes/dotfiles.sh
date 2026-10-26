#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_dotfiles() {
    local dotfiles_dir="$SCRIPT_DIR/dotfiles"
    local target="$HOME/dotfiles"

    if [ ! -d "$dotfiles_dir" ]; then
        print_error "Dotfiles source directory not found: $dotfiles_dir"
        return 1
    fi

    if [ ! -d "$dotfiles_dir/.config" ]; then
        print_error "Dotfiles source is incomplete (missing .config/): $dotfiles_dir"
        return 1
    fi

    if [ -d "$target" ]; then
        print_info "Refreshing ~/dotfiles from repository..."
        if ! rm -rf "$target"; then
            print_error "Failed to remove stale ~/dotfiles"
            return 1
        fi
    fi

    print_info "Copying dotfiles to $target..."
    if ! cp -r "$dotfiles_dir" "$target"; then
        print_error "Failed to copy dotfiles to $target"
        return 1
    fi

    if command -v stow &>/dev/null; then
        print_info "Creating symlinks with stow..."
        cd "$target" || {
            print_error "Failed to cd into $target"
            return 1
        }

        if ! stow . --restow --no-folding; then
            print_error "Failed to create symlinks with stow"
            cd "$SCRIPT_DIR" || true
            return 1
        fi

        cd "$SCRIPT_DIR" || return 1
    else
        print_warning "stow not found — symlinks were NOT created"
        print_info "Install 'stow' and re-run this step, or link manually"
    fi

    print_success "Dotfiles installed successfully!"
}
