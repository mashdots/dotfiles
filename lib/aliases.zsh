alias thisBranch="git branch | grep '^\*' | cut -d' ' -f2" #        shows text for current branch of current directory #
alias prs="gh pr list --author mashdots" #                                               list my current PRs in Github #
alias mypy="dc run --workdir /web --rm --no-deps web mypy --show-error-codes src/aplaceforrover/**/*.py" #    run mypy #
alias db="rebuild db_replica"
alias generate_api_schemas="m generate_api_schemas && (cd /workspaces/web/src/frontend/rsdk && yarn run build:apiClient)"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi
