#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_seanime() {
    local temp_dir="$SCRIPT_DIR/temp"
    local install_dir="$HOME/Applications"
    local bin_dir="$HOME/.local/bin"
    local icon_dir="$HOME/.local/share/icons"
    local desktop_dir="$HOME/.local/share/applications"
    local repo="5rahim/seanime"

    print_info "Installing Seanime..."

    if [ -f "$install_dir/Seanime.AppImage" ] && [ -x "$install_dir/Seanime.AppImage" ]; then
        print_success "Seanime is already installed"
        return 0
    fi

    if ! mkdir -p "$install_dir" "$bin_dir" "$icon_dir" "$desktop_dir" "$temp_dir"; then
        print_error "Failed to create install directories"
        return 1
    fi

    cd "$temp_dir" || {
        print_error "Failed to cd into $temp_dir"
        return 1
    }

    print_info "Checking latest release..."

    local latest_tag
    latest_tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
        grep -m1 '"tag_name"' |
        cut -d'"' -f4)

    if [[ -z "$latest_tag" ]]; then
        print_error "Could not determine latest release tag"
        print_info "Possible cause: GitHub API rate limit, or $repo has no releases"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    local version_number="${latest_tag#v}"
    local download_file="seanime-denshi-${version_number}_Linux_x86_64.AppImage"
    local download_url="https://github.com/$repo/releases/download/$latest_tag/$download_file"

    print_info "Downloading Seanime $latest_tag..."
    rm -f "$download_file"

    if ! curl -fL --retry 3 --retry-delay 2 -o "$download_file" "$download_url"; then
        print_error "Failed to download Seanime"
        print_info "Tried: $download_url"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if [[ ! -s "$download_file" ]]; then
        print_error "Downloaded file is empty"
        rm -f "$download_file"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! head -c 4 "$download_file" | grep -q $'\x7fELF'; then
        print_error "Downloaded file is not a valid AppImage (bad magic bytes)"
        rm -f "$download_file"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    print_info "Installing Seanime..."

    if ! chmod +x "$download_file"; then
        print_error "Failed to make AppImage executable"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    if ! mv -f "$download_file" "$install_dir/Seanime.AppImage"; then
        print_error "Failed to move Seanime to $install_dir"
        cd "$SCRIPT_DIR" || true
        return 1
    fi

    ln -sf "$install_dir/Seanime.AppImage" "$bin_dir/seanime"

    print_info "Extracting icon..."
    local extract_dir="/tmp/seanime-extract-$$"
    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"

    (
        cd "$extract_dir" || exit 1
        "$install_dir/Seanime.AppImage" --appimage-extract >/dev/null 2>&1 || true
    )

    local icon_file
    icon_file=$(find "$extract_dir/squashfs-root" \
        \( -name "*.png" -o -name "*.svg" \) 2>/dev/null | head -1)

    if [[ -n "$icon_file" ]]; then
        cp "$icon_file" "$icon_dir/seanime.png"
    else
        print_warning "No icon found in AppImage — using generic icon name"
    fi

    rm -rf "$extract_dir"

    cat >"$desktop_dir/seanime.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Seanime
Comment=Anime manager and media player
Exec=$install_dir/Seanime.AppImage
Icon=$icon_dir/seanime.png
Categories=AudioVideo;Player;Video;
Terminal=false
EOF

    cd "$SCRIPT_DIR" || true
    print_success "Seanime $latest_tag installed successfully!"
}
