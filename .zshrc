/home/$USER/.scripts/motd.sh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git sudo extract zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

source /home/swim/.oh-my-zsh/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

export ZSH="$HOME/.oh-my-zsh"
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# alias content
alias ls='lsd'

#fzf-tab
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# preview ststytem status
zstyle ':completion:*:systemctl-*:*' list-colors '*.service=0;32:*.target=0;36:*.socket=0;33:*.timer=0;35:*=0;37'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-flags '--color=fg:15,fg+:11,bg:-1,bg+:8,hl:6,hl+:14'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview '
service_name=$word
active_status=$(systemctl is-active $service_name 2>/dev/null)
enabled_status=$(systemctl is-enabled $service_name 2>/dev/null)

case $active_status in
    "active")   active_color="\033[32m" ;;
    "inactive") active_color="\033[33m" ;;
    "failed")   active_color="\033[31m" ;;
    *)          active_color="\033[37m" ;;
esac

case $enabled_status in
    "enabled")  enabled_color="\033[32m" ;;
    "disabled") enabled_color="\033[33m" ;;
    *)          enabled_color="\033[37m" ;;
esac

echo -e "\033[36m=== $service_name ===\033[0m"
echo -e "Active:  ${active_color}$active_status\033[0m"
echo -e "Enabled: ${enabled_color}$enabled_status\033[0m"
echo -e "\033[36m=== Description ===\033[0m"
systemctl show $service_name --property=Description --no-pager | cut -d= -f2
echo -e "\033[36m=== Recent Logs ===\033[0m"
journalctl -u $service_name --no-pager -n 3 --output=cat 2>/dev/null || echo "No recent logs"'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-flags '--preview-window=right:60%:wrap'
# cutom kill command stayle
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
# custom fzf flags
# 为主命令补全设置与 systemctl 相同的配色
zstyle ':fzf-tab:complete:-command-:*' fzf-flags '--color=fg:15,fg+:11,bg:-1,bg+:8,hl:6,hl+:14'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-flags '--color=fg:15,fg+:11,bg:-1,bg+:8,hl:6,hl+:14'
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 90 25
zstyle ':fzf-tab:*' fzf-min-height 15
zstyle ':fzf-tab:complete:(pacman|paru|yay):*' fzf-min-height 25
#pacman complete setting
# pacman - 只查询官方仓库
zstyle ':fzf-tab:complete:pacman:*' fzf-preview 'pacman -Si "$word" 2>/dev/null || pacman -Qi "$word" 2>/dev/null'
zstyle ':fzf-tab:complete:pacman:*' fzf-flags '--preview-window=right:60%:wrap'

# paru - 智能查询（官方仓库 + AUR）
zstyle ':fzf-tab:complete:paru:*' fzf-preview '
if pacman -Qi "$word" &>/dev/null; then
    pacman -Qi "$word"
elif pacman -Si "$word" &>/dev/null; then
    pacman -Si "$word"
else
    paru -Si "$word" 2>/dev/null
fi'
zstyle ':fzf-tab:complete:paru:*' fzf-flags '--preview-window=right:60%:wrap'

# yay - 智能查询（官方仓库 + AUR）
zstyle ':fzf-tab:complete:yay:*' fzf-preview '
if pacman -Qi "$word" &>/dev/null; then
    pacman -Qi "$word"
elif pacman -Si "$word" &>/dev/null; then
    pacman -Si "$word"
else
    yay -Si "$word" 2>/dev/null
fi'
zstyle ':fzf-tab:complete:yay:*' fzf-flags '--preview-window=right:60%:wrap'


#custom funcation 

fv() {
    local file
    file=$(fd --type f --hidden --no-ignore | fzf --preview 'bat --color=always --style=numbers --line-range=:50 {}' --preview-window=right:40%)
    if [[ -n "$file" ]]; then
        nvim "$file"
    fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
