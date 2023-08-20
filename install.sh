#!/bin/bash

source ./lib/color.sh
source ./lib/functions.sh
source ./lib/constants.sh

select_system() {
  local distro_name

  printf "\n%bWelcome to the %bzunder-zsh%b installation script.%b\n" \
    "$ITALIC" "$YELLOW" "$NORMAL$ITALIC" "$NORMAL"
  print_line
  echo "1. Arch based (pacman)."
  echo "2. Debian/Ubuntu based (apt)."
  echo "3. Fedora based (dnf)."
  echo "4. Void Linux."
  echo "5. Mac OS."
  echo "6. Android."
  echo "7. Other."
  read -rp $'\nSelect your current operating system [1-7]: ' distro

  while ! [[ "$distro" =~ ^[1-7]$ ]]; do
    print_error "Value entered is invalid."
    read -rp $'\nSelect your current operating system [1-7]: ' distro
  done

  case $distro in
    1) distro_name="Arch based" ;;
    2) distro_name="Debian/Ubuntu based" ;;
    3) distro_name="Fedora based" ;;
    4) distro_name="Void Linux" ;;
    5) distro_name="Mac OS" ;;
    6) distro_name="Android" ;;
    7) distro_name="Other" ;;
    *) distro_name="an unknown distro" ;;
  esac
  print_info "You entered $distro_name."
}

dependecy_check() {
  declare -a dependencies=("zsh" "unzip" "curl" "git")

  print_line
  echo "DEPENDENCY CHECK"
  print_line

  if ((distro == 3)); then
    dependencies+=("sqlite3")
  fi

  if ((distro == 6)); then
    dependencies+=("exa" "file")
  fi

  not_installed=0
  for dependency in "${dependencies[@]}"; do
    if ! command_exists "$dependency"; then
      if ((distro == 7)); then
        print_warning "$dependency is not installed and is required." \
          "Please install it manually and try again."
        exit 1
      elif [[ "$dependency" == "sqlite3" ]]; then
        install_program sqlite
      else
        install_program "$dependency"
      fi
      ((not_installed++))
    fi
  done

  if ((not_installed == 0)); then
    print_success "All dependencies are satisfied."
  fi
}

install_program() {
  local prompt

  print_warning "$1 is not installed and is required."
  read -rp $'\nInstall it? [Y/n]: ' prompt

  prompt=${prompt:-Y}

  if [[ "$prompt" =~ [Nn] ]]; then
    print_error "$1 is required."
    exit 1
  fi

  printf "\n"
  case $distro in
    1) sudo pacman -S "$1" ;;
    2) sudo apt install "$1" ;;
    3) sudo dnf install "$1" ;;
    4) sudo xbps-install "$1" ;;
    5) brew install "$1" ;;
    6) pkg install "$1" ;;
    *) print_error "An error has occurred." ;;
  esac
}

set_default() {
  local prompt

  print_line
  read -rp "Zsh is not your current default shell, do you want to set it? [Y/n]: " prompt

  case $prompt in
    [Nn])
      print_warning "Zsh won't be setted as the default shell."
      ;;
    *)
      if ((distro != 6)); then
        sudo usermod -s "$(which zsh)" "$USER" && default_applied=true
      else
        chsh -s zsh && default_applied=true
      fi

      if $default_applied; then
        print_success "Zsh was setted as the default shell."
      else
        print_warning "Zsh was not setted as the default shell."
      fi
      ;;
  esac
}

load_files() {
  local prompt

  print_line
  printf "Zunder-zsh will store its configuration in %b%s%b.\n" \
    "$CYAN" "$ZDOTDIR" "$NORMAL"
  read -rp "Continue? [y/N]: " prompt

  case $prompt in
    [yY])
      printf "\n"
      mkdir -vp "$ZDOTDIR" 2>/dev/null
      cp -v ./config/aliases.zsh "$ZDOTDIR"
      cp -v ./config/options.zsh "$ZDOTDIR"
      cp -v ./config/key-bindings.zsh "$ZDOTDIR"
      cp -v ./config/plugins.zsh "$ZDOTDIR"
      cp -v ./config/.zshrc "$ZDOTDIR"
      cp -v ./config/.zshenv "$HOME"
      mv -v "$HOME/.zsh_history" "$ZDOTDIR" 2>/dev/null
      [ ! -f "$ZDOTDIR/user-config.zsh" ] \
        && echo "# Write your configurations here" >"$ZDOTDIR/user-config.zsh"
      ;;
    *)
      print_error "Canceled. This won't apply your changes at all," \
        "try running the script again."
      exit 1
      ;;
  esac
}

install_icons() {
  print_info "Installing icons..."

  # Create directory if it does not exist
  mkdir -p "$HOME/.local/share/fonts"

  # Download font file
  curl -fLo "$HOME/.local/share/fonts/Symbols Nerd Font.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFont-Regular.ttf" \
    || return 1

  print_success "Icons installed successfully in $HOME/.local/share/fonts/Symbols Nerd Font.tff."
}

main() {
  declare -i distro
  default_applied=false

  select_system

  dependecy_check

  if [[ "$(basename "$SHELL")" != "zsh" && $distro -ne 5 && $distro -ne 7 ]]; then
    set_default
  fi

  load_files

  if [[ ! -d "$HOME/.local/share/zinit" ]]; then
    print_info "Installing zunder-zsh..."
    zsh -i -c exit
  fi

  if [[ "$distro" -lt 5 ]]; then
    fc-list | grep -q "Symbols Nerd Font" || install_icons
  fi

  print_line
  print_success "All done."

  if [[ -n "$default_applied" ]]; then
    print_warning "It may be necessary to reboot the system to see" \
      "zsh as the default shell."
  fi
}

main "$@"
