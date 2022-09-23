#!/bin/bash

source ./lib/color.sh
source ./lib/constants.sh

# FUNCTIONS
removeJunk() {
    printf "${WARNING}Do you want to remove all the Zunder files? [y/N]: ${NORMAL}"
    read prompt
    if [[ $prompt = Y || $prompt = y  ]]; then
        mv "$ZDOTDIR/.zsh_history" "$HOME"
        rm -rf "$HOME/.zshenv" "$ZDOTDIR" "$HOME/.local/share/zinit" "$HOME/.cache/p10k-"* \
               "$HOME/.cache/zinit"
    fi
}

# START
main() {
    removeJunk

    echo "------------"
    printf "${SUCCESS}All done.${NORMAL}\n"
}

main "$@"
