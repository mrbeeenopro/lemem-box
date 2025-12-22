#!/usr/bin/env bash
set -euo pipefail

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' BOLD='' RESET=''
fi

cecho() { printf "%b\n" "$1$2$RESET"; }

declare -A LABELS=(
  [1]="Windows XP"
  [2]="Windows Server 2012 (virtio)"
  [3]="Windows Server 2016 (virtio)"
  [4]="Tiny Windows 10"
  [5]="Tiny Windows 11"
  [6]="Ubuntu"
  [7]="Debian"
  [8]="Alpine Linux"
  [9]="Custom URL"
)

declare -A TARGETS=(
  [1]="windows_xp.sh"
  [2]="win2012_virtio.sh"
  [3]="win2016_virtio.sh"
  [4]="win10_tiny.sh"
  [5]="win11_tiny.sh"
  [6]="ubuntu.sh"
  [7]="debian.sh"
  [8]="alpine.sh"
)

declare -A URLS=(
  [1]=""
  [2]=""
  [3]=""
  [4]=""
  [5]=""
  [6]=""
  [7]=""
  [8]=""
)

declare -A COLORS=(
  [1]="$BLUE"    
  [2]="$CYAN"    
  [3]="$CYAN"    
  [4]="$BLUE"    
  [5]="$BLUE"    
  [6]="$YELLOW"  
  [7]="$RED"     
  [8]="$CYAN"    
  [9]="$MAGENTA" # Custom
)

print_menu() {
  printf "%b\n" "${BOLD}${CYAN}Select an image to download (type number and Enter):${RESET}"
  for i in 1 2 3 4 5 6 7 8 9; do
    label_color="${COLORS[$i]:-}${GREEN}"
    if [[ -z "${COLORS[$i]:-}" ]]; then
      label_color="${GREEN}"
    fi
    printf "  %b) %b\n" "${YELLOW}${i}${RESET}" "${label_color}${LABELS[$i]}${RESET}"
  done
  printf "  %b) %b\n" "q" "${MAGENTA}Quit${RESET}"
}

download() {
  local url="$1" target="$2"
  local tmpfile="${target}.part.$$"

  if [[ -z "$url" ]]; then
    read -r -p "$(printf '%b' "${BOLD}${CYAN}Enter download URL:${RESET} ")" url
    if [[ -z "$url" ]]; then
      printf "%b\n" "${RED}No URL provided. Aborting.${RESET}" >&2
      return 1
    fi
  fi

  printf "%b %s\n" "${BLUE}Downloading from:${RESET}" "$url"
  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --progress-bar -o "$tmpfile" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$tmpfile" "$url"
  else
    printf "%b\n" "${RED}Neither curl nor wget is available. Install one and retry.${RESET}" >&2
    rm -f "$tmpfile" 2>/dev/null || true
    return 1
  fi

  if [[ -f "$target" ]]; then
    mv "$target" "${target}.bak.$(date +%s)"
    printf "%b\n" "${YELLOW}Existing $target moved to ${target}.bak.*${RESET}"
  fi
  mv "$tmpfile" "$target"
  printf "%b\n" "${GREEN}Saved as: $target${RESET}"
}

run_and_replace() {
  local target="$1"

  if [[ ! -f "$target" ]]; then
    printf "%b\n" "${RED}File $target not found; cannot run.${RESET}" >&2
    return 1
  fi

  chmod +x "$target" || true
  printf "%b\n" "${BLUE}Running $target...${RESET}"
  ./$target

  printf "%b\n" "${GREEN}Renaming $target to start.sh and removing setup script...${RESET}"
  mv -f "$target" start.sh

  script_path="$0"
  if [[ ! -f "$script_path" ]]; then
    script_path="$(pwd)/$0"
  fi
  if [[ -f "$script_path" ]]; then
    rm -f -- "$script_path" || true
    printf "%b\n" "${YELLOW}Removed setup script: $script_path${RESET}"
  else
    printf "%b\n" "${RED}Could not locate setup script to remove: $script_path${RESET}" >&2
  fi
}

main() {
  print_menu
  read -r -p "$(printf '%b' "${BOLD}${CYAN}Choice:${RESET} ")" choice
  case "$choice" in
    q|Q)
      printf "%b\n" "${MAGENTA}Bye.${RESET}"; exit 0
      ;;
    1|2|3|4|5|6|7|8)
      url="${URLS[$choice]:-}"
      target="${TARGETS[$choice]:-file_${choice}}"
      download "$url" "$target"
      if [[ $? -ne 0 ]]; then
        exit 1
      fi
      read -r -p "$(printf '%b' "${BOLD}${CYAN}Run downloaded file now, rename to start.sh and delete this setup script? [y/N]: ${RESET}")" runchoice
      if [[ "$runchoice" =~ ^[Yy]$ ]]; then
        run_and_replace "$target"
      fi
      ;;
    9)
      read -r -p "$(printf '%b' "${BOLD}${CYAN}Enter URL to download:${RESET} ")" url
      read -r -p "$(printf '%b' "${BOLD}${CYAN}Enter filename to save as (e.g. custom.sh):${RESET} ")" target
      if [[ -z "$target" ]]; then
        printf "%b\n" "${RED}No filename provided. Aborting.${RESET}" >&2; exit 1
      fi
      download "$url" "$target"
      ;;
    *)
      echo "Invalid choice."; exit 1
      ;;
  esac
}

main "$@"
