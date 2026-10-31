#!/bin/bash

# what changed: cd back to $SCRIPT_DIR even when the cd into ~/dotfiles fails, fail
# loudly if the source is incomplete, and be clearer when stow is missing.

source "$SCRIPT_DIR/utils/display.sh"

install_dotfiles() {
    local src="$SCRIPT_DIR/dotfiles"
    local target="$HOME/dotfiles"

    if [ ! -d "$src/.config" ]; then
        print_error "dotfiles source looks incomplete: $src"
        return 1
    fi

    if [ -d "$target" ]; then
        print_info "refreshing ~/dotfiles"
        if ! rm -rf "$target"; then
            print_error "couldn't remove the old ~/dotfiles"
            return 1
        fi
    fi

    print_info "copying dotfiles to $target"
    if ! cp -r "$src" "$target"; then
        print_error "couldn't copy dotfiles to $target"
        return 1
    fi

    if ! command -v stow &>/dev/null; then
        print_warning "stow isn't installed — copied the dotfiles but didn't link them"
        return 0
    fi

    print_info "linking with stow"
    if ! cd "$target"; then
        print_error "couldn't enter $target"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! stow . --restow --no-folding; then
        print_error "stow failed — look for conflicting files already in \$HOME"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    cd "$SCRIPT_DIR" || true
    print_success "dotfiles linked"
}
