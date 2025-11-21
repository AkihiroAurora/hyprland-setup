#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Create directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Get random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [[ -n "$WALLPAPER" ]]; then
    # Create temporary hyprpaper config
    cat >~/.config/hypr/hyprpaper.conf.tmp <<EOF
preload = $WALLPAPER
wallpaper = ,$WALLPAPER
EOF

    # Replace current config
    mv ~/.config/hypr/hyprpaper.conf.tmp ~/.config/hypr/hyprpaper.conf

    # Kill and restart hyprpaper
    killall hyprpaper
    hyprpaper &
fi
