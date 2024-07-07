# ENV Variables
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=vim
export KUBE_EDITOR=vim
export PATH=/usr/local/bin/:$PATH:$HOME/bin
export KUBECONFIG=~/.kube/config
export AWS_CLI_AUTO_PROMPT=on-partial
[[ -f ~/.zsh/envs.zsh ]] && source ~/.zsh/envs.zsh

# Aliases 
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh

# Functions
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh

# ZSH Setup
#ZSH_THEME="robbyrussell"
plugins=(git z aws docker ansible salt kubectl zsh-autosuggestions fluxcd helm fzf git ssh-agent)
source $ZSH/oh-my-zsh.sh
HIST_STAMPS="mm/dd/yyyy"
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit

# Autocompletion
# the fzf plugin is for autocompletion
# source <(kubectl completion zsh) #Not needed if plugin is insalled            ## TEST ##
# . <(flux completion bash) # Not neded

# Setup Starship prompt
[[ -f ~/.zsh/starship.zsh ]] && source ~/.zsh/starship.zsh
eval "$(starship init zsh)"

# Setup Fuzzy Finder
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
export FZF_BASE=$(which fzf)

# Setup Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
