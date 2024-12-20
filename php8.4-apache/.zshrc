# ZSH and Bash Configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="wezm"

plugins=(
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='nano'
export PATH="$PATH:$HOME/.composer/vendor/bin"

# ALias
alias art="php artisan"
