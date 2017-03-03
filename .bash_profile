if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

# 
# Exports
# 
export PATH="/usr/local/mysql/bin:$PATH" # MySQL
export GOPATH="/usr/local/go/" # Go
export HISTFILESIZE=10000000
export HISTSIZE=100000 


source ~/.git-completion.bash
# source /usr/local/git/contrib/completion/git-prompt.sh
source ~/.ps1

if [ "$TERM" != "dumb" ]; then
  export LS_OPTIONS='--color=auto'
  eval `gdircolors ~/.dircolors`
fi

parse_git_branch() {
    git_branch=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ $git_branch ]; then
        #echo "•$git_branch"
        echo " $git_branch"
    fi
}

## The prompt below gets ideas from the following:
# http://briancarper.net/blog/570/git-info-in-your-zsh-prompt
# http://github.com/adamv/dotfiles/blob/master/bashrc
# http://wiki.archlinux.org/index.php/Color_Bash_Prompt
txtred='\[\e[0;31m\]' # Red
txtwht='\[\e[0;37m\]' # White
txtylw='\[\e[0;33m\]' # Yellow
txtmgt='\[\e[0;35m\]' # Magenta
txtgrn='\[\e[0;32m\]' # Green
txtcyn='\[\e[0;36m\]' # Cyan
bldred='\[\e[1;31m\]' # Red
bldmgt='\[\e[1;35m\]' # Magenta
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldwht='\[\e[1;37m\]' # White
bldcyn='\[\e[1;36m\]' # Cyan

end='\[\e[0m\]'    # Text Reset

function parse_git {
    branch=$(__git_ps1 "%s")
    if [[ -z $branch ]]; then
        return
    fi

    local forward="⟰"
    local behind="⟱"
    local dot="•"

    remote_pattern_ahead="# Your branch is ahead of"
    remote_pattern_behind="# Your branch is behind"
    remote_pattern_diverge="# Your branch and (.*) have diverged"

    status="$(git status 2>/dev/null)"

    state=""
    branchcolor=""
    if [[ $status =~ "working directory clean" ]]; then
        #state=${bldgrn}${dot}${end}
        branchcolor=${txtgrn}
    else
        if [[ $status =~ "Untracked files" ]]; then
            state="${bldred}${dot}${end} "
            branchcolor=${txtred}
        fi
        if [[ $status =~ "Changes not staged for commit" ]]; then
            #state=${state}${bldylw}${dot}${end}
            branchcolor=${txtylw}
        fi
        if [[ $status =~ "Changes to be committed" ]]; then
            #state=${state}${bldylw}${dot}${end}
            branchcolor=${txtylw}
        fi
    fi

    direction=""
    if [[ $status =~ $remote_pattern_ahead ]]; then
        direction="${txtgrn}${forward}${end} "
        #direction=""
    elif [[ $status =~ $remote_pattern_behind ]]; then
        direction=${bldred}${behind}${end}
    elif [[ $status =~ $remote_pattern_diverge ]]; then
        direction=${bldred}${forward}${end}${bldgrn}${behind}${end}
    fi

    branch=${branchcolor}${branch}${end}
    git_bit="${branch} ${state}${git_bit}${direction}"

    printf "%s" "$git_bit"
}

function set_titlebar {
    case $TERM in
        *xterm*|ansi|rxvt)
            printf "\033]0;%s\007" "$*"
            ;;
    esac
}

function set_prompt {
    local snowman=""
    git="$(parse_git)"

    PS1="${txtmgt}\h${end} ${txtcyn}\w${end}"
    if [[ -n "$git" ]]; then
        PS1="$PS1 $git${txtwht}$ ${end}"
    else
        PS1="$PS1 ${txtwht}$ ${end}"
    fi
      set_titlebar "$USER@${HOSTNAME%%.*} $PWD"
export PROMPT_COMMAND=set_prompt # Go

git aliase='git branch -d' 
