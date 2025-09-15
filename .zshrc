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
plugins=(git golang sudo extract zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

source /home/swim/.oh-my-zsh/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

export SAVEHIST=10000
export ZSH="$HOME/.oh-my-zsh"

# alias content
alias cat='bat'
alias copy='wl-copy'
alias ls='lsd'
alias update='sudo pacman -Syu'
alias restartplasma='systemctl --user restart plasma-plasmashell.service'
alias netpaste='curl -F "c=@-" "https://fars.ee/"'
alias rm='rm -I'
alias tmp='cd /tmp/TheSw1m_tmp/'

# custom shell scripts
alias enablecam='~/.local/shell_scripts/enable_cam.sh'
alias disablecam='~/.local/shell_scripts/disable_cam.sh'
alias enable_adb_proxy='~/.local/shell_scripts/adb_proxy.sh'
alias disable_adb_proxy='~/.local/shell_scripts/adb_disbale_proxy.sh'
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
# preview ls command
zstyle ':fzf-tab:complete:lsd:*' fzf-preview '
if [[ -d $realpath ]]; then
    eza -la --color=always $realpath 2>/dev/null || ls -la --color=always $realpath
elif [[ -f $realpath ]]; then
    bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || cat $realpath 2>/dev/null | head -50
fi'
zstyle ':fzf-tab:complete:ls:*' fzf-flags '--preview-window=right:60%:wrap'
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

# custom kill command style
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'

# custom fzf flags
# 为主命令补全设置与 systemctl 相同的配色
zstyle ':fzf-tab:complete:-command-:*' fzf-flags '--color=fg:15,fg+:11,bg:-1,bg+:8,hl:6,hl+:14'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-flags '--color=fg:15,fg+:11,bg:-1,bg+:8,hl:6,hl+:14'
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:15,fg+:195,bg:-1,bg+:236,hl:75,hl+:195,info:109,prompt:75,pointer:195,marker:220,spinner:11,header:109
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 90 25
zstyle ':fzf-tab:*' fzf-min-height 15
zstyle ':fzf-tab:complete:(pacman|paru|yay):*' fzf-min-height 25
#
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
# cd 命令预览目录内容
zstyle ':fzf-tab:complete:cd:*' fzf-preview '
if [[ -d $realpath ]]; then
    eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath
else
    echo "不是目录"
fi'
zstyle ':fzf-tab:complete:cd:*' fzf-flags '--preview-window=right:50%:wrap'
# ls 命令安全预览

zstyle ':fzf-tab:complete:ls:*' fzf-preview '
if [[ -d $realpath ]]; then
    eza -la --color=always $realpath 2>/dev/null || ls -la --color=always $realpath
elif [[ -f $realpath ]]; then
    # 检查文件大小 (1MB限制)
    size=$(stat -c%s $realpath 2>/dev/null || echo 0)
    if (( size > 1048576 )); then
        echo -e "\033[33m⚠️  文件过大 ($(numfmt --to=iec $size))，仅显示文件信息\033[0m"
        file $realpath 2>/dev/null
        ls -lh $realpath
    elif file $realpath | grep -q "binary\|executable\|archive\|image\|video\|audio"; then
        echo -e "\033[36m📁 二进制文件:\033[0m"
        file $realpath
        ls -lh $realpath
    else
        bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || head -50 $realpath
    fi
fi'
zstyle ':fzf-tab:complete:ls:*' fzf-flags '--preview-window=right:60%:wrap'

# cat/less/more/bat 等查看文件的命令安全预览

zstyle ':fzf-tab:complete:(cat|less|more|bat):*' fzf-preview '
if [[ -f $realpath ]]; then
    # 检查文件大小 (512KB限制，因为是要查看的文件)
    size=$(stat -c%s $realpath 2>/dev/null || echo 0)
    if (( size > 524288 )); then
        echo -e "\033[33m⚠️  文件过大 ($(numfmt --to=iec $size))\033[0m"
        echo -e "\033[36m文件信息:\033[0m"
        file $realpath
        echo -e "\033[36m前几行预览:\033[0m"
        head -10 $realpath 2>/dev/null
    elif file $realpath | grep -q "binary\|executable"; then
        echo -e "\033[31m⚠️  二进制文件，不适合用文本查看器打开\033[0m"
        file $realpath
        ls -lh $realpath
    else
        bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || head -100 $realpath
    fi
elif [[ -d $realpath ]]; then
    eza -la --color=always $realpath 2>/dev/null || ls -la --color=always $realpath
fi'
zstyle ':fzf-tab:complete:(cat|less|more|bat):*' fzf-flags '--preview-window=right:60%:wrap'

# cp/mv 命令安全预览

zstyle ':fzf-tab:complete:(cp|mv):*' fzf-preview '
if [[ -f $realpath ]]; then
    echo -e "\033[36m=== 文件信息 ===\033[0m"
    ls -lh $realpath
    file $realpath
    
    # 只对小文件显示内容预览
    size=$(stat -c%s $realpath 2>/dev/null || echo 0)
    if (( size <= 262144 )); then  # 256KB限制
        if ! file $realpath | grep -q "binary\|executable"; then
            echo -e "\033[36m=== 文件内容预览 ===\033[0m"
            bat --color=always --style=numbers --line-range=:20 $realpath 2>/dev/null || head -20 $realpath
        fi
    else
        echo -e "\033[33m文件过大，跳过内容预览\033[0m"
    fi
elif [[ -d $realpath ]]; then
    echo -e "\033[36m=== 目录内容 ===\033[0m"
    eza -la --color=always $realpath 2>/dev/null || ls -la --color=always $realpath
fi'

zstyle ':fzf-tab:complete:(cp|mv):*' fzf-flags '--preview-window=right:60%:wrap'
# rm 命令安全预览（危险操作，显示更多信息但限制大小）

zstyle ':fzf-tab:complete:rm:*' fzf-preview '
if [[ -f $realpath ]]; then
    echo -e "\033[31m⚠️  即将删除文件: $realpath\033[0m"
    echo -e "\033[36m=== 文件信息 ===\033[0m"
    ls -lah $realpath
    file $realpath
    
    # 只对小文本文件显示内容
    size=$(stat -c%s $realpath 2>/dev/null || echo 0)
    if (( size <= 131072 )) && ! file $realpath | grep -q "binary\|executable"; then  # 128KB限制
        echo -e "\033[36m=== 文件内容预览 ===\033[0m"
        bat --color=always --style=numbers --line-range=:15 $realpath 2>/dev/null || head -15 $realpath
    else
        echo -e "\033[33m文件过大或为二进制文件，跳过内容预览\033[0m"
    fi
elif [[ -d $realpath ]]; then
    echo -e "\033[31m⚠️  即将删除目录: $realpath\033[0m"
    echo -e "\033[36m=== 目录信息 ===\033[0m"
    ls -lad $realpath
    echo -e "\033[36m=== 目录内容 ===\033[0m"
    eza -la --color=always $realpath 2>/dev/null || ls -la --color=always $realpath
fi'
zstyle ':fzf-tab:complete:rm:*' fzf-flags '--preview-window=right:65%:wrap'

# vim/nano/code 等编辑器安全预览

zstyle ':fzf-tab:complete:(vim|nvim|nano|code|emacs):*' fzf-preview '
if [[ -f $realpath ]]; then
    # 检查文件大小
    size=$(stat -c%s $realpath 2>/dev/null || echo 0)
    if (( size > 1048576 )); then  # 1MB限制
        echo -e "\033[33m⚠️  文件过大 ($(numfmt --to=iec $size))\033[0m"
        file $realpath
        echo -e "\033[36m前几行:\033[0m"
        head -10 $realpath 2>/dev/null
    elif file $realpath | grep -q "binary\|executable\|archive\|image\|video\|audio"; then
        echo -e "\033[36m📁 二进制文件:\033[0m"
        file $realpath
        ls -lh $realpath
    else
        bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || head -50 $realpath
    fi
elif [[ -d $realpath ]]; then
    eza -la --color=always $realpath 2>/dev/null || ls -la --color=always $realpath
fi'
zstyle ':fzf-tab:complete:(vim|nvim|nano|code|emacs):*' fzf-flags '--preview-window=right:60%:wrap'

# 通用安全文件预览（作为后备）
zstyle ':fzf-tab:complete:*:*' fzf-preview '
if [[ -f $realpath ]]; then
    # 检查文件大小和类型
    size=$(stat -c%s $realpath 2>/dev/null || echo 0)
    if (( size > 524288 )); then  # 512KB限制
        echo -e "\033[33m文件过大 ($(numfmt --to=iec $size))，仅显示基本信息\033[0m"
        file $realpath 2>/dev/null
        ls -lh $realpath
    elif file $realpath 2>/dev/null | grep -q "binary\|executable\|archive\|image\|video\|audio"; then
        echo -e "\033[36m二进制文件:\033[0m"
        file $realpath
        ls -lh $realpath
    else
        bat --color=always --style=numbers --line-range=:30 $realpath 2>/dev/null || head -30 $realpath 2>/dev/null
    fi
elif [[ -d $realpath ]]; then
    eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath
fi'#custom funcation 

fv() {
    local file
    file=$(fd --type f --hidden --no-ignore | fzf --preview 'bat --color=always --style=numbers --line-range=:50 {}' --preview-window=right:40%)
    if [[ -n "$file" ]]; then
        nvim "$file"
    fi
}

#fzf copy
fzfcp() {
    local file
    file=$(fd --type f --hidden \
        --exclude .git \
        --exclude node_modules \
        --exclude .cache \
        | fzf --preview 'bat --color=always --style=numbers --line-range=:50 {} 2>/dev/null' \
              --preview-window=right:40%)
    
    if [[ -n "$file" ]]; then
        echo "$file" | wl-copy
        echo "已复制到剪切板: $file"
    fi
}
# history with fzf 
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf) )
  
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}

zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

safe_preview() {
    local file="$1"
    local max_size=${2:-1048576}  # 默认1MB限制
    
    # 检查文件是否存在
    [[ ! -e "$file" ]] && { echo "文件不存在"; return 1; }
    
    if [[ -d "$file" ]]; then
        # 目录预览
        eza -la --color=always "$file" 2>/dev/null || ls -la --color=always "$file"
    elif [[ -f "$file" ]]; then
        # 检查文件大小
        local size=$(stat -c%s "$file" 2>/dev/null || echo 0)
        if (( size > max_size )); then
            echo -e "\033[33m⚠️  文件过大 ($(numfmt --to=iec $size))，跳过预览\033[0m"
            file "$file" 2>/dev/null
            return 0
        fi
        
        # 检查是否为二进制文件
        if file "$file" | grep -q "binary\|executable\|archive\|image\|video\|audio"; then
            echo -e "\033[36m📁 二进制文件信息:\033[0m"
            file "$file"
            ls -lh "$file"
        else
            # 文本文件预览
            bat --color=always --style=numbers --line-range=:50 "$file" 2>/dev/null || \
            head -50 "$file" 2>/dev/null
        fi
    else
        echo "特殊文件类型"
        ls -la "$file"
    fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
