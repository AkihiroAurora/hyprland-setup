#!/bin/bash

# what changed: clear stale gtk-4.0 symlinks before relinking — the old ln -sf would
# nest a link inside an existing directory on a re-run. rest is the same config,
# just tidied.

source "$SCRIPT_DIR/utils/display.sh"

setup_gtk_theme() {
    local theme_name="Catppuccin-Mauve-Dark"
    local cfg="$SCRIPT_DIR/dotfiles/.config"
    local gtk3="$cfg/gtk-3.0"
    local gtk4="$cfg/gtk-4.0"

    if [ -f "$gtk3/settings.ini" ] &&
        grep -q "gtk-theme-name=$theme_name" "$gtk3/settings.ini" &&
        [ -f "$gtk4/settings.ini" ] &&
        grep -q "gtk-theme-name=$theme_name" "$gtk4/settings.ini" &&
        [ -f "$SCRIPT_DIR/dotfiles/.gtkrc-2.0" ] &&
        grep -q "gtk-theme-name=\"$theme_name\"" "$SCRIPT_DIR/dotfiles/.gtkrc-2.0" &&
        [ -f "$SCRIPT_DIR/dotfiles/.xsettingsd.conf" ] &&
        grep -q "Net/ThemeName \"$theme_name\"" "$SCRIPT_DIR/dotfiles/.xsettingsd.conf"; then
        print_info "gtk theme already applied"
        return 0
    fi

    print_info "writing gtk config"

    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface icon-theme 'Dracula' || true
    fi

    mkdir -p "$gtk3" "$gtk4" || { print_error "couldn't create the gtk config dirs"; return 1; }

    cat >"$gtk3/settings.ini" <<EOF
[Settings]
gtk-theme-name=$theme_name
gtk-icon-theme-name=Dracula
gtk-font-name=JetBrainsMono Nerd Font 11.5, Vazirmatn UI
gtk-cursor-theme-name=BreezeX-Black
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-application-prefer-dark-theme=1
EOF

    cat >"$gtk4/settings.ini" <<EOF
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
        rm -rf "$gtk4/assets" "$gtk4/gtk.css" "$gtk4/gtk-dark.css"
        ln -sf "$theme_path/assets" "$gtk4/assets"
        ln -sf "$theme_path/gtk.css" "$gtk4/gtk.css"
        ln -sf "$theme_path/gtk-dark.css" "$gtk4/gtk-dark.css"
    else
        print_warning "no $theme_path — install the catppuccin gtk theme first"
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

    print_success "gtk theme set"
}
