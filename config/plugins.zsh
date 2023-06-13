# ZINIT ------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d $ZINIT_HOME ]] && mkdir -p "$(dirname $ZINIT_HOME)"
[[ ! -d $ZINIT_HOME/.git ]] \
    && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Compiles zinit.zsh if it's newer than its compiled version. Then sources it.
[[ "$ZINIT_HOME/zinit.zsh.zwc" -nt "$ZINIT_HOME/zinit.zsh" ]] || zcompile -R "$ZINIT_HOME/zinit.zsh"
source "$ZINIT_HOME/zinit.zsh"

# PLUGINS ----------------------------------------------------------------------
# This determines the OS name. It's used to determine if the user is on Android.
OS="$(uname -o || uname)" &> /dev/null

# Installs fzf from github releases if it's not installed.
zi ice from"gh-r" as"program" if'! command_exists fzf'
zi light junegunn/fzf

# Installs exa from github releases, unless the OS is Android as it doesn't work there.
# Android users should install exa from their package manager.
zi ice from"gh-r" as"program" pick"bin/exa" \
    has"unzip" if'[[ "$OS" != "Android" ]]' \
    atclone"cp completions/exa.zsh _exa" pull'%atclone'
zi light ogham/exa

# zsh plugins
zi light-mode nocd for \
    OMZL::key-bindings.zsh \
    OMZP::command-not-found \
    OMZP::sudo \
    has"fzf" \
        https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh \
    blockf \
        zsh-users/zsh-completions \
    as"completion" has"docker" \
        https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zi wait lucid light-mode nocd  for \
    zdharma-continuum/fast-syntax-highlighting \
    atload'_zsh_autosuggest_start' if'[[ -n $DISPLAY || $OS == "Android" ]]' \
        zsh-users/zsh-autosuggestions

# zunder-prompt
zi ice compile'./gitstatus/(install|*.zsh)'
zi light "Warbacon/zunder-prompt"

# CONFIGURATION ----------------------------------------------------------------
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
FZF_ALT_C_COMMAND="find * -type d 2> /dev/null"
FZF_CTRL_T_COMMAND="find * 2> /dev/null" 
if [[ -n $DISPLAY || $OS == "Android" ]]; then
    ZUNDER_PROMPT_CHAR=""
    ZUNDER_PROMPT_CHAR_COLOR=3
else
    ZUNDER_PROMPT_CHAR=">"
fi

