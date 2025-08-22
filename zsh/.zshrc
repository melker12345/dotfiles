## Set the Zsh configuration directory
export ZSH="$HOME/.oh-my-zsh"

## Set the theme
ZSH_THEME="pure" # set by `omz`

# Enable color support
#export CLICOLOR=1
#export LSCOLORS=GxFxCxDxBxegedabagacad

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load pure theme if it's not loaded as a theme
#if [[ "$ZSH_THEME" != "pure" ]]; then
#    fpath+=(/home/melker/.oh-my-zsh/custom/themes/pure)
#    autoload -U promptinit; promptinit
#    prompt pure
#fi


# Use eza/exa for file listing with icons (after Oh My Zsh to override defaults)
#if command -v eza &> /dev/null; then
#    alias ls='eza --icons --color=auto'
#    alias ll='eza -l --icons --color=auto'
#    alias la='eza -la --icons --color=auto'
#    alias tree='eza --tree --icons --color=auto'
#elif command -v exa &> /dev/null; then
#    alias ls='exa --icons --color=auto'
#    alias ll='exa -l --icons --color=auto'
#    alias la='exa -la --icons --color=auto'
#    alias tree='exa --tree --icons --color=auto'
#else
#    alias ls='ls --color=auto'
#    alias ll='ls -l --color=auto'
#    alias la='ls -la --color=auto'
#fi


# Option 2: Use Oh My Zsh colors (uncomment to try)
# ZSH_DISABLE_COMPFIX="true"
# Uncomment the line below to use Oh My Zsh's built-in colors instead of eza
# alias ls='ls --color=auto'
# alias ll='ls -l --color=auto'
# alias la='ls -la --color=auto'

# Load completion system
zstyle :compinstall filename '/home/melker/.zshrc'
#autoload -Uz compinit
compinit
export PATH="$HOME/.cargo/bin:$PATH"
