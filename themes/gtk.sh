#!/bin/bash

source "$SCRIPT_DIR/utils/display.sh"

setup_gtk_theme() {
    local theme_name="Catppuccin-Mauve-Dark"
    local dotfiles_config="$SCRIPT_DIR/dotfiles/.config"
    local gtk3_dir="$dotfiles_config/gtk-3.0"
    local gtk4_dir="$dotfiles_config/gtk-4.0"

    if [ -f "$gtk3_dir/settings.ini" ] &&
        grep -q "gtk-theme-name=$theme_name" "$gtk3_dir/settings.ini" &&
        [ -f "$gtk4_dir/settings.ini" ] &&
        grep -q "gtk-theme-name=$theme_name" "$gtk4_dir/settings.ini" &&
        [ -f "$SCRIPT_DIR/dotfiles/.gtkrc-2.0" ] &&
        grep -q "gtk-theme-name=\"$theme_name\"" "$SCRIPT_DIR/dotfiles/.gtkrc-2.0" &&
        [ -f "$SCRIPT_DIR/dotfiles/.xsettingsd.conf" ] &&
        grep -q "Net/ThemeName \"$theme_name\"" "$SCRIPT_DIR/dotfiles/.xsettingsd.conf"; then
        print_info "GTK theme is already applied"
        return 0
    fi

    print_info "Setting up GTK theme..."

    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface icon-theme 'Dracula' || true
    fi

    if ! mkdir -p "$gtk3_dir"; then
        print_error "Failed to create $gtk3_dir"
        return 1
    fi
    cat >"$gtk3_dir/settings.ini" <<EOF
[Settings]
gtk-theme-name=$theme_name
gtk-icon-theme-name=Dracula
gtk-font-name=JetBrainsMono Nerd Font 11.5, Vazirmatn UI
gtk-cursor-theme-name=BreezeX-Black
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-application-prefer-dark-theme=1
EOF

    if ! mkdir -p "$gtk4_dir"; then
        print_error "Failed to create $gtk4_dir"
        return 1
    fi
    cat >"$gtk4_dir/settings.ini" <<EOF
[Settings]
gtk-theme-name=$theme_name
gtk-icon-theme-name=Dracula
gtk-font-name=JetBrainsMono Nerd Font 11.5, Vazirmatn UI
gtk-cursor-theme-name=BreezeX-Black
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-application-prefer-dark-theme=1
EOF

    cat >"$SCRIPT_DIR/dotfiles/.xsettingsd.conf" <<EOF
Net/ThemeName "$theme_name"
Net/IconThemeName "Dracula"
Gtk/CursorThemeName "BreezeX-Black"
Net/EnableEventSounds 1
EnableInputFeedbackSounds 0
Xft/Antialias 1
Xft/Hinting 1
Xft/HintStyle "hintslight"
Xft/RGBA "rgb"
EOF

    local theme_path="/usr/share/themes/$theme_name/gtk-4.0"
    if [ -d "$theme_path" ]; then
        ln -sf "$theme_path/assets" "$gtk4_dir/assets"
        ln -sf "$theme_path/gtk.css" "$gtk4_dir/gtk.css"
        ln -sf "$theme_path/gtk-dark.css" "$gtk4_dir/gtk-dark.css"
    else
        print_warning "GTK-4.0 theme directory not found at $theme_path"
        print_warning "Please install the theme package first"
    fi

    cat >"$SCRIPT_DIR/dotfiles/.gtkrc-2.0" <<EOF
gtk-theme-name="$theme_name"
gtk-icon-theme-name="Dracula"
gtk-font-name="JetBrainsMono Nerd Font 11.5, Vazirmatn UI"
gtk-cursor-theme-name="BreezeX-Black"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-application-prefer-dark-theme=1
EOF

    print_success "GTK theme configured successfully!"
}
