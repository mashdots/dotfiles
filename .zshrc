# ------------------------------------------------------ Exports -------------------------------------------------------
ZSH_THEME="schminitz-v2"
plugins=(git macos npm node sudo wd vscode)
export ZSH=$HOME/.oh-my-zsh
# ------------------------------------------------------ Aliases -------------------------------------------------------

alias thisBranch="git branch | grep '^\*' | cut -d' ' -f2" #        shows text for current branch of current directory #
alias darker="python -mdarker --config ./pyproject.toml --isort --revision master... src/aplaceforrover"
alias prs="gh pr list --author mashdots" #                                               list my current PRs in Github #

# ----------------------------------------------------- Functions ------------------------------------------------------

commit() { # <-- Wrapper for git commit with a message for the current branch
  local message="$*"
  if ((${#message} > 0)); then
    git commit -m "[`thisBranch`] $message"
  else
    echo "you need to append a commit message"
  fi
}