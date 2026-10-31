#!/bin/bash

# what changed: use `command -v` instead of `which` (not guaranteed on a bare Arch),
# match the shell path literally with grep -xF, and fall back to id -un when $USER
# isn't set.

source "$SCRIPT_DIR/utils/display.sh"

setup_zsh_shell() {
    local zsh_path
    zsh_path=$(command -v zsh) || { print_error "zsh isn't installed"; return 1; }

    local login_shell
    login_shell=$(basename "${SHELL:-/bin/bash}")

    if [ "$login_shell" = "zsh" ]; then
        print_info "zsh is already the login shell"
        return 0
    fi

    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        print_info "adding $zsh_path to /etc/shells"
        if ! printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
            print_error "couldn't add zsh to /etc/shells"
            return 1
        fi
    fi

    local user_name="${USER:-$(id -un)}"
    if ! sudo chsh -s "$zsh_path" "$user_name"; then
        print_error "couldn't set zsh as the login shell for $user_name"
        return 1
    fi

    print_success "zsh is now the login shell — log out to pick it up"
}
