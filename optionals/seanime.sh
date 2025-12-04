#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

install_seanime() {
    local temp_dir="$SCRIPT_DIR/temp"
    local install_dir="$HOME/Applications"
    local bin_dir="$HOME/.local/bin"
    local icon_dir="$HOME/.local/share/icons"
    local repo="5rahim/seanime"

    print_info "Installing Seanime..."

    # Create directories
    mkdir -p "$install_dir" "$bin_dir" "$icon_dir" "$temp_dir"

    # Check if already installed
    if [[ -f "$install_dir/Seanime.AppImage" ]]; then
        print_success "Seanime is already installed"
        return 0
    fi

    # Create and use temp directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"

    # Get the latest release tag
    print_info "Checking latest release..."

    local latest_tag
    if ! latest_tag=$(curl -s "https://github.com/$repo/releases" | grep -o 'releases/tag/v[0-9]*\.[0-9]*\.[0-9]*' | head -1 | cut -d'/' -f3); then
        print_error "Failed to get latest version information"
        cd "$SCRIPT_DIR"
        return 1
    fi

    if [[ -z "$latest_tag" ]]; then
        latest_tag=$(curl -s "https://github.com/$repo/releases" | grep -o '/releases/tag/[^"]*' | head -1 | cut -d'/' -f4)
    fi

    if [[ -z "$latest_tag" ]]; then
        print_error "Could not find latest release tag"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Remove 'v' prefix if present for filename
    local version_number="${latest_tag#v}"

    # Construct the filename
    local download_file="seanime-denshi-${version_number}_Linux_x86_64.AppImage"

    print_info "Downloading Seanime $latest_tag..."

    # Without v prefix in URL
    if ! wget "https://github.com/$repo/releases/download/$latest_tag/$download_file"; then
        print_error "Failed to download Seanime"
        print_info "Tried downloading: https://github.com/$repo/releases/download/$latest_tag/$download_file"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Verify download
    if [[ ! -f "$download_file" ]]; then
        print_error "Seanime AppImage not found after download"
        cd "$SCRIPT_DIR"
        return 1
    fi

    print_info "Installing Seanime..."

    # Move to Applications directory with consistent name
    if ! mv -v "$download_file" "$install_dir/Seanime.AppImage"; then
        print_error "Failed to move Seanime to Applications directory"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Make executable
    chmod +x "$install_dir/Seanime.AppImage"

    # Create symlink
    ln -sf "$install_dir/Seanime.AppImage" "$bin_dir/seanime"

    # Extract icon from AppImage
    print_info "Extracting icon..."
    mkdir -p /tmp/seanime-extract
    cd /tmp/seanime-extract
    "$install_dir/Seanime.AppImage" --appimage-extract >/dev/null 2>&1

    # Look for icon files
    local icon_file=$(find squashfs-root -name "*.png" -o -name "*.svg" | head -1)

    if [[ -n "$icon_file" ]]; then
        cp "$icon_file" "$icon_dir/seanime.png"
    else
        print_warning "No icon found in AppImage, using generic icon"
    fi

    # Clean up
    rm -rf /tmp/seanime-extract
    cd "$SCRIPT_DIR"

    # Create desktop entry with icon
    local desktop_dir="$HOME/.local/share/applications"
    mkdir -p "$desktop_dir"

    cat >"$desktop_dir/seanime.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Seanime
Comment=Anime manager and media player
Exec=$install_dir/Seanime.AppImage
Icon=seanime
Categories=AudioVideo;Player;Video;
Terminal=false
EOF

    print_success "Seanime $latest_tag installed successfully!"
}
