#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils/display.sh"

setup_gtk_theme() {
    local theme_name="Catppuccin-Mauve-Dark"

    # Check if theme is already applied
    if [ -f ~/.config/gtk-3.0/settings.ini ] &&
        grep -q "gtk-theme-name=$theme_name" ~/.config/gtk-3.0/settings.ini &&
        [ -f ~/.config/gtk-4.0/settings.ini ] &&
        grep -q "gtk-theme-name=$theme_name" ~/.config/gtk-4.0/settings.ini &&
        [ -f ~/.gtkrc-2.0 ] &&
        grep -q "gtk-theme-name=\"$theme_name\"" ~/.gtkrc-2.0; then
        print_info "GTK theme is already applied"
        return 0
    fi

    print_info "Setting up GTK theme..."

    # Create GTK-3.0 config directory if it doesn't exist
    mkdir -p ~/.config/gtk-3.0

    # Configure GTK 3.0
    cat >~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$theme_name
gtk-icon-theme-name=Dracula
gtk-font-name=JetBrainsMono Nerd Font 11, Vazirmatn
gtk-cursor-theme-name=BreezeX-Black
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-application-prefer-dark-theme=1
EOF

    # Configure GTK 4.0
    mkdir -p ~/.config/gtk-4.0
    cat >~/.config/gtk-4.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$theme_name
gtk-icon-theme-name=Dracula
gtk-font-name=JetBrainsMono Nerd Font 11, Vazirmatn
gtk-cursor-theme-name=BreezeX-Black
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-application-prefer-dark-theme=1
EOF

    # Create symlinks for GTK-4.0 assets
    local theme_path="/usr/share/themes/$theme_name/gtk-4.0"
    if [ -d "$theme_path" ]; then
        ln -sf "$theme_path/assets" ~/.config/gtk-4.0/
        ln -sf "$theme_path/gtk.css" ~/.config/gtk-4.0/
        ln -sf "$theme_path/gtk-dark.css" ~/.config/gtk-4.0/
    else
        print_warning "GTK-4.0 theme directory not found at $theme_path"
        print_warning "Please install the theme package first"
    fi

    # Set theme for legacy GTK 2.0 (using .gtkrc-2.0)
    cat >~/.gtkrc-2.0 <<EOF
gtk-theme-name="$theme_name"
gtk-icon-theme-name="Dracula"
gtk-font-name="JetBrainsMono Nerd Font 11, Vazirmatn"
gtk-cursor-theme-name="BreezeX-Black"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-application-prefer-dark-theme=1
EOF

    print_success "GTK theme configured successfully!"
}
