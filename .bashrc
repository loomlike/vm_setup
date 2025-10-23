# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Decorate prompt helper functions 
git_branch() {
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

git_status() {
    local status="$(git status --porcelain 2>/dev/null)"
    local output=''
    [[ -n $(egrep '^[MADRC]' <<<"$status") ]] && output="${output}o" # staged
    [[ -n $(egrep '^.[MD]' <<<"$status") ]] && output="${output}*"   # dirty
    [[ -n $(git log --branches --not --remotes) ]] && output="${output}+"  # ahead commits
    echo $output
}

git_color() {
    local committed=$([[ $1 =~ \+ ]] && echo yes)
    local staged=$([[ $1 =~ o ]] && echo yes)
    local dirty=$([[ $1 =~ \* ]] && echo yes)
    if [[ -n $dirty ]]; then
        echo -e '\033[1;31m'  # bold red
    elif [[ -n $staged ]]; then
        echo -e '\033[1;33m'  # bold yellow
    elif [[ -n $committed ]]; then
        echo -e '\033[1;32m'  # bold green
    else
        echo -e '\033[1;37m'  # bold white
    fi
}

git_prompt() {
    local branch=$(git_branch)
    if [[ -n $branch ]]; then
        local state=$(git_status)
        local color=$(git_color $state)
        # Now output the actual code to insert the branch and status
        echo -e "\x01$color\x02$branch\x01\033[00m\x02"  # last bit resets color
    fi
}

# Helper to show venv or conda env (venv takes priority)
env_prompt() {
    local env_name=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
        env_name="$(basename "$(dirname "$VIRTUAL_ENV")")"
    elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        env_name="$CONDA_DEFAULT_ENV"
    fi
    if [[ -n "$env_name" ]]; then
        if [ ${#env_name} -gt 10 ]; then
            env_name="${env_name:0:7}..."
        fi
        echo "($env_name) "
    fi
}

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[1;35m\]$(env_prompt)\[\033[00m\]$(git_prompt) \[\033[1;34m\]\w \[\033[1;35m\]\$ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}$(env_prompt)$(git_prompt) \w \$ '
fi

unset color_prompt force_color_prompt

# If this is an xterm, set the terminal title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

print_cow() {
    local msg="$1"
    local -a lines=()
    local trimmed sanitized
    local visible_len max_len=0

    # Read message line-by-line (preserves final non-terminated line too)
    while IFS= read -r line || [ -n "$line" ]; do
        # Remove carriage returns, then trim leading/trailing whitespace (bash-only)
        line=${line//$'\r'/}
        # trim leading
        line="${line#"${line%%[![:space:]]*}"}"
        # trim trailing
        line="${line%"${line##*[![:space:]]}"}"

        lines+=("$line")

        # Compute visible length: strip common ANSI CSI sequences for measurement
        # Keep the original line intact so colors still display when printing.
        sanitized=$(printf '%s' "$line" | sed -r 's/\x1B\[[0-9;?]*[a-zA-Z]//g')

        # visible_len uses character count (works with UTF-8 in typical shells/locales)
        visible_len=${#sanitized}
        (( visible_len > max_len )) && max_len=$visible_len
    done <<< "$msg"

    # Build top border (max_len visible chars plus two spaces inside the box)
    local border
    border=$(printf '%*s' "$((max_len + 2))" '' | tr ' ' '-')
    printf ' %s\n' "$border"

    # Print each line padded to visible width so '>' aligns.
    local i pad
    for i in "${!lines[@]}"; do
        trimmed=${lines[i]}
        sanitized=$(printf '%s' "$trimmed" | sed -r 's/\x1B\[[0-9;?]*[a-zA-Z]//g')
        visible_len=${#sanitized}
        pad=$((max_len - visible_len))
        # Print: "< " + content + (pad spaces) + " >"
        # We use two printf calls so that any ANSI escapes in $trimmed do not affect padding measurement.
        printf '< %s' "$trimmed"
        if (( pad > 0 )); then
            printf '%*s' "$pad" ''
        fi
        printf ' >\n'
    done

    # Bottom border
    printf ' %s\n' "$border"

    # Cow ASCII
    cat <<'EOF'
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
EOF
}

# >>> conda initialize >>>
# TODO: Move your 'conda init' output from end of the file to here
# <<< conda initialize <<<
conda config --set changeps1 false

# Not show venv to the prompt since we handle that
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Add SSH agent and keys
eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/id_rsa

# To show date and weather:
weather="$(curl --max-time 5 wttr.in/?0q 2>/dev/null)"
print_cow "$weather
$(date +"%a %b %-d %Y
%H:%M %Z")"
