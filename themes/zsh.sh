#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

setup_zsh_shell() {
    # Check if ZSH is already the default shell
    local current_shell="$(basename "$SHELL")"
    if [ "$current_shell" = "zsh" ]; then
        print_success "ZSH is already the default shell"
        return 0
    fi

    print_info "Setting up ZSH as default shell..."

    # Check if ZSH is installed
    if ! command -v zsh &>/dev/null; then
        print_error "ZSH is not installed. Please install it first."
        return 1
    fi

    # Check if ZSH is in /etc/shells
    local zsh_path="$(which zsh)"
    if ! grep -q "$zsh_path" /etc/shells; then
        print_info "Adding ZSH to available shells..."
        if ! echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
            print_error "Failed to add ZSH to /etc/shells"
            return 1
        fi
    fi

    # Change the default shell for the current user
    print_info "Changing default shell to ZSH..."
    if ! sudo chsh -s "$zsh_path" "$USER"; then
        print_error "Failed to change default shell to ZSH"
        return 1
    fi

    print_success "ZSH set as default shell successfully!"
}
