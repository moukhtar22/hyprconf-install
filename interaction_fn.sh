#!/bin/bash
# initial user interaction functions...

# color definition (ascii)
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\x1b[38;5;214m"
end="\e[1;0m"

# cache dir
dir="$(dirname "$(realpath "$0")")"

# creating a cache directory..
cache_dir="$dir/.cache"
cache_file="$cache_dir/user-cache"
shell_cache="$cache_dir/shell"

[[ ! -d "$cache_dir" ]] && mkdir -p "$cache_dir"

#______( starts functions here )______#

fn_welcome() {
    gum style \
        --foreground "#00FFFF" \
        --border-foreground "#00FFFF" \
        --border rounded \
        --align center \
        --width 90 \
        --margin "1 2" \
        --padding "1 2" \
    'Welcome to the' 'Hyprland installation script by,' '
   _____  __           __ __   _   __ _           _       
  / ___/ / /_   ___   / // /  / | / /(_)____     (_)____ _
  \__ \ / __ \ / _ \ / // /  /  |/ // // __ \   / // __ `/
 ___/ // / / //  __// // /  / /|  // // / / /  / // /_/ / 
/____//_/ /_/ \___//_//_/  /_/ |_//_//_/ /_/__/ / \__,_/  
                                           /___/          
'
}

fn_ask() {
    gum confirm "$1" \
        --prompt.foreground "#ff8700" \
        --affirmative "$2" \
        --selected.background "#00FFFF" \
        --selected.foreground "#000" \
        --negative "$3"
}

fn_exit() {
    gum spin --spinner line \
    --spinner.foreground "#FF0000" \
    --title "$1" \
    --title.foreground "#FF0000" -- \
    sleep 1

    exit 1
}


# only for asking the prompts...
fn_ask_prompts() {
    # Generate human-readable labels
    local -A label_to_key
    local labels=()
    for key in "${!options[@]}"; do
        local label=$(echo "$key" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
        label_to_key["$label"]="$key"
        labels+=("$label")
    done

    # Use gum to capture selected options
    local selected
    selected=$(gum choose \
        --header "Select using the 'space' bar" \
        --no-limit \
        --cursor.foreground "#00FFFF" \
        --item.foreground "#fff" \
        --selected.foreground "#00FF00" \
        "${labels[@]}")
    
    # Reset all options to 'N' by default
    for key in "${!options[@]}"; do
        options[$key]="N"
    done

    # Set the selected options to 'Y'
    while IFS= read -r label; do
        if [[ -n "$label" ]]; then
            local key="${label_to_key[$label]}"
            options[$key]="Y"
        fi
    done <<< "$selected"

    # Update the cache file with the new values
    > "$cache_file"
    for key in "${!options[@]}"; do
        echo "$key='${options[$key]}'" >> "$cache_file"
    done
}

# only for asking shell prompts...
fn_shell() {
    # Generate human-readable labels
    local -A label_to_key
    local labels=()
    for key in "${!shell_options[@]}"; do
        local label=$(echo "$key" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
        label_to_key["$label"]="$key"
        labels+=("$label")
    done

    # Use gum to capture selected options
    local selected
    selected=$(gum choose \
        --header "Choose only one. Press 'ENTER'" \
        --limit=1 \
        --cursor.foreground "#00FFFF" \
        --item.foreground "#fff" \
        --selected.foreground "#00FF00" \
        "${labels[@]}")
    
    # Reset all options to 'N' by default
    for key in "${!shell_options[@]}"; do
        shell_options[$key]="N"
    done

    # Set the selected options to 'Y'
    while IFS= read -r label; do
        if [[ -n "$label" ]]; then
            local key="${label_to_key[$label]}"
            shell_options[$key]="Y"
        fi
    done <<< "$selected"

    # Update the cache file with the new values
    > "$shell_cache"
    for key in "${!shell_options[@]}"; do
        echo "$key='${shell_options[$key]}'" >> "$shell_cache"
    done
}

msg() {
    local actn="$1"
    local msg="$2"

    case $actn in
        act)
            printf "${green}=>${end} $msg\n"
            ;;
        ask)
            printf "${orange}??${end} $msg\n"
            ;;
        dn)
            printf "${cyan}::${end} $msg\n\n"
            ;;
        att)
            printf "${yellow}!!${end} $msg\n"
            ;;
        nt)
            printf "${blue}\$\$${end} $msg\n"
            ;;
        skp)
            printf "${magenta}[ SKIP ]${end} $msg\n"
            ;;
        err)
            printf "${red}>< Ohh sheet! an error..${end}\n   $msg\n"
            sleep 1
            ;;
        *)
            printf "$msg\n"
            ;;
    esac
}
