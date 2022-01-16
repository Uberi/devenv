#####################
# ZSH configuration #
#####################

# configure oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"  # hyphen-insensitive completion
zstyle ':omz:update' mode disabled  # disable automatic updates
DISABLE_UNTRACKED_FILES_DIRTY="true" # disable marking untracked files under VCS as dirty - makes status check for large repositories much faster
plugins=(git sudo wd command-not-found zsh-completions)
source $ZSH/oh-my-zsh.sh

# configure syntax highlighting
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"

# load virtualenv if present
if [ -d "$HOME/app/venv" ]; then
    source "$HOME/app/venv/bin/activate"
fi

# load config script if present
if [ -f "$HOME/app/config.sh" ]; then
    source "$HOME/app/config.sh"
fi

alias 'c=cat --show-nonprinting'
alias 'l=ls -l --all --human-readable --color'
alias 'flatten=mv ./*/**/*(.D) .'
alias 'archive-tgz=tar --create --gzip --verbose --file' # `archive-tgz TGZ_FILE_TO_CREATE FILES*`
alias 'archive-tar=tar --create --verbose --file' # `archive-tgz TAR_FILE_TO_CREATE FILES*`
alias 'archive-zip=zip -v' # `archive-zip ZIP_FILE_TO_CREATE FILES*`
alias 'unarchive-tgz=tar --extract --gzip --verbose --file' # `unarchive-tgz TGZ_FILE_TO_EXTRACT`
alias 'unarchive-tar=tar --extract --verbose --file' # `unarchive-tar TAR_FILE_TO_EXTRACT`
alias 'unarchive-zip=unzip -v' # `unarchive-zip ZIP_FILE_TO_EXTRACT`

alias 'va=python3 -m venv venv'
alias 'v+=source venv/bin/activate'
alias 'v-=deactivate'

# useful Git aliases; short for fast, efficient Git workflow (based on actual usage history of git commands)
alias 'gl=git log --graph --all --decorate --date=local'
alias 'gp=git push'
alias 'gph=git push origin HEAD'
alias 'gpf=git push --force-with-lease origin HEAD'
alias 'gcl=git clone'
alias 'gf=git fetch --all'
alias 'gu=git pull'
alias 'gur=git pull --rebase'
alias 'gb=git branch'
alias 'gbd=git branch --delete'
alias "gbl=git for-each-ref refs/heads --color=always --sort -committerdate --format='%(HEAD)%(color:reset);%(color:yellow)%(refname:short)%(color:reset);%(contents:subject);%(color:green)(%(committerdate:relative))%(color:blue);<%(authorname)>' | column -t -s ';'"  # show branches ordered by most recently modified
alias 'gs=git status'
alias 'gsh=git show'
alias 'gd=DELTA_FEATURES=side-by-side git diff'
alias 'gdc=DELTA_FEATURES=side-by-side git diff --cached'
alias 'gdw=git diff'
alias 'gdcw=git diff --cached'
unalias ga gau  # remove aliases that were added by the git plugin in Oh-My-Zsh
ga () { git add "$@"; git status }
gau () { git add --update "$@"; git status }
alias 'gc=git commit'
alias 'gcm=git commit -m'
alias 'gk=git checkout'
alias 'gkb=git checkout -b'
alias 'gr=git reset'
alias 'grh=git reset --hard'
alias 'grm=git rm'
alias 'grb=git rebase'
alias 'grbi=git rebase --interactive'
alias 'gt=git tag -s'
alias 'gt=git tag --list'
alias 'grem=git remote'
alias 'gh=git stash'
alias 'ghp=git stash pop'
alias 'ghl=git stash list'
alias 'ghist=git log --follow -p --stat --' # show the full history of a file, including renames and diffs for each change
alias 'groot=cd $(git rev-parse --show-toplevel)'  # go to root level of the current git repo
alias 'gbranches=git for-each-ref --sort=-authordate --format "%(authordate:iso) %(align:left,25)%(refname:short)%(end) %(subject)" refs/heads'

# random generation
alias rand-token='echo $(head -c 16 /dev/urandom | xxd -p -c1000)'
alias rand-password='grep -v "['"'"'A-Z]" /usr/share/dict/american-english | shuf -n5 | paste -sd " " -'

# for showing notifications outside of the container - when run, causes a notification to show up on the host machine
# to use this, run the following bash on the host machine: `while true; do if [ -f .devenv-notify ]; then rm .devenv-notify; notify-send 'Completed!' 'The long-running operation just completed'; fi; sleep 3; done`
alias notif='touch $HOME/app/.devenv-notify'

# for copying some text to outside of the container - when run, causes its stdin to be copied to the host machine's clipboard
# to use this, run the following bash on the host machine: `while true; do if [ -f .devenv-clipboard ]; then cat .devenv-clipboard | xclip -selection c; rm .devenv-clipboard; notify-send 'Copied!' 'Value was copied to clipboard'; fi; sleep 3; done`
alias clip='tee $HOME/app/.devenv-clipboard'
