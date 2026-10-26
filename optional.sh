#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
source "$SCRIPT_DIR/utils/display.sh"
source "$SCRIPT_DIR/utils/aur.sh"

# Source optional installers
source "$SCRIPT_DIR/optionals/prismlauncher.sh"
source "$SCRIPT_DIR/optionals/seanime.sh"

# Exit on any error
set -e

main() {
    # Check if paru is installed
    if ! command -v paru &>/dev/null; then
        print_error "paru is not installed. Run setup.sh first!"
        exit 1
    fi

    paru -S --noconfirm gum

    # Clear screen
    clear

    # Selection GUI
    local selections
    selections=$(gum choose \
        --no-limit \
        --cursor="→ " \
        --cursor.foreground="#cba6f7" \
        --item.foreground="#cdd6f4" \
        --selected.foreground="#cba6f7" \
        --selected-prefix="✓ " \
        --unselected-prefix="  " \
        --header="Select actions to run:" \
        --height=10 \
        "PrismLauncher Setup" \
        "Seanime Setup")

    # Check if user made selections
    if [[ -z "$selections" ]]; then
        paru -Rs --noconfirm gum
        clear
        print_error "No selections made."
        exit 0
    fi

    # Process each selection
    local item
    IFS=$'\n'
    for item in $selections; do
        case "$item" in
        "PrismLauncher Setup")
            install_prismlauncher
            ;;
        "Seanime Setup")
            install_seanime
            ;;
        esac
        echo "" # Empty line between actions
    done
    unset IFS

    # ── Safe temp cleanup — only touch our own directory ─────────────
    if [ -d "$SCRIPT_DIR/temp" ]; then
        # sudo only if root-owned files exist inside
        if find "$SCRIPT_DIR/temp" -user root -print -quit 2>/dev/null | grep -q .; then
            sudo rm -rf "$SCRIPT_DIR/temp"
        else
            rm -rf "$SCRIPT_DIR/temp"
        fi
    fi

    paru -Rs --noconfirm gum

    print_success "All selected actions completed!"
}

main "$@"
