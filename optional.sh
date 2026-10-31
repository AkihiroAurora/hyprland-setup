#!/bin/bash

# what changed: only remove gum if we installed it, and run all cleanup from an EXIT
# trap so ctrl-c / a gum error / a failed optional step still tidies up; dropped the
# unused aur.sh source; read selections line by line instead of clobbering $IFS.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils/display.sh"
source "$SCRIPT_DIR/optionals/prismlauncher.sh"
source "$SCRIPT_DIR/optionals/seanime.sh"

set -e

gum_installed_by_us=0

cleanup() {
    cd "$SCRIPT_DIR" 2>/dev/null || true

    if [ "$gum_installed_by_us" -eq 1 ] && command -v paru &>/dev/null; then
        paru -Rs --noconfirm gum 2>/dev/null || true
    fi

    if [ -d "$SCRIPT_DIR/temp" ]; then
        if find "$SCRIPT_DIR/temp" -user root -print -quit 2>/dev/null | grep -q .; then
            sudo rm -rf "$SCRIPT_DIR/temp"
        else
            rm -rf "$SCRIPT_DIR/temp"
        fi
    fi
}
trap cleanup EXIT

main() {
    if ! command -v paru &>/dev/null; then
        print_error "paru isn't installed — run setup.sh first"
        exit 1
    fi

    if ! command -v gum &>/dev/null; then
        if ! paru -S --noconfirm gum; then
            print_error "couldn't install gum, which is needed for the menu"
            exit 1
        fi
        gum_installed_by_us=1
    fi

    clear

    local selections=""
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
        "Seanime Setup" 2>/dev/null) || true

    if [ -z "$selections" ]; then
        print_error "nothing selected"
        return 0
    fi

    local item
    while IFS= read -r item; do
        case "$item" in
            "PrismLauncher Setup") install_prismlauncher ;;
            "Seanime Setup")       install_seanime ;;
        esac
        echo
    done <<< "$selections"

    print_success "all selected actions finished"
}

main "$@"
