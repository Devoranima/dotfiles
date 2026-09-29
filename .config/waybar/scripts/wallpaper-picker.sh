#!/usr/bin/env bash

wallpaper_dir="$HOME/Pictures/Wallpapers"
cache_dir="$HOME/.cache/wallpaper-thumbs"
mkdir -p "$cache_dir"

# ImageMagick 7 uses `magick`, 6 uses `convert`
if command -v magick >/dev/null 2>&1; then
    im_cmd=(magick)
elif command -v convert >/dev/null 2>&1; then
    im_cmd=(convert)
else
    im_cmd=()
fi

declare -A wallpapers
menu=""

prettify() {
    local n="${1%.*}"
    n="${n//[-_]/ }"
    n="$(printf '%s' "$n" | tr -s ' ' | sed 's/^ *//; s/ *$//')"
    (( ${#n} > 38 )) && n="${n:0:30}… ${n: -6}"
    printf '%s' "$n"
}

while IFS= read -r img; do
    name=$(basename "$img")

    # 16:9 cached thumbnail, regenerated when the source is newer
    key=$(printf '%s' "$img" | sha1sum | cut -d' ' -f1)
    thumb="$cache_dir/$key.png"
    if [ ${#im_cmd[@]} -gt 0 ] && { [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; }; then
        "${im_cmd[@]}" "$img" -thumbnail 400x225^ -gravity center \
            -extent 400x225 "$thumb" 2>/dev/null
    fi
    [ -f "$thumb" ] || thumb="$img"

    # Human-readable label, uniquified so two files never collide in the map
    label=$(prettify "$name")
    i=2
    while [ -n "${wallpapers[$label]+x}" ]; do
        label="$(prettify "$name") ($i)"
        ((i++))
    done
    wallpapers["$label"]="$img"

    menu+="img:$thumb:text:$label"$'\n'
done < <(find "$wallpaper_dir" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [ -z "$menu" ]; then
    notify-send "Wallpaper picker" "No images found in $wallpaper_dir" 2>/dev/null
    exit 1
fi

selected=$(printf '%s' "$menu" | wofi --show dmenu \
    --define image_size=110 \
    --define allow_markup=false \
    --allow-images \
    --insensitive \
    --prompt "Search wallpapers" \
    --width 760 \
    --height 560 \
    --style ~/.config/wofi/style/wallpaper.css)

[ -z "$selected" ] && exit 0

# wofi echoes the whole line back, so strip the img:...:text: prefix
selected="${selected##*:text:}"

target="${wallpapers[$selected]}"
[ -z "$target" ] && exit 1

swww img "$target" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-duration 1 \
    --transition-fps 60
