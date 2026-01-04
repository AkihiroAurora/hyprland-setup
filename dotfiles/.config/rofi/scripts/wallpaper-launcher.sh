#!/bin/bash

# Set some variables
wall_dir="${HOME}/Pictures/wallpapers/"
cacheDir="${HOME}/.cache/jp/"
rofi_command="rofi -x11 -dmenu -theme ${HOME}/.config/rofi/wallselect.rasi"

# Create cache dir if not exists
if [ ! -d "${cacheDir}" ]; then
    mkdir -p "${cacheDir}"
fi

# Convert images in directory and save to cache dir
for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
    if [ -f "$imagen" ]; then
        nombre_archivo=$(basename "$imagen")
        if [ ! -f "${cacheDir}/${nombre_archivo}" ]; then
            convert -strip "$imagen" -thumbnail 400x225^ -gravity center -extent 400x225 "${cacheDir}/${nombre_archivo}"
        fi
    fi
done

# Select a picture with rofi
wall_selection=$(find "${wall_dir}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A; do echo -en "$A\x00icon\x1f""${cacheDir}"/"$A\n"; done | $rofi_command)

# Set the wallpaper with swww
[[ -n "$wall_selection" ]] || exit 1

# Set wallpaper with swww using wipe transition
swww img "${wall_dir}/${wall_selection}" --transition-fps 60 --transition-type grow

exit 0
