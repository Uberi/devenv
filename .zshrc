#####################
# ZSH configuration #
#####################

# setup oh-my-zsh
ZSH_THEME=robbyrussell
DISABLE_AUTO_UPDATE=true

# setup zgen and use it to install oh-my-zsh and zsh-completions
source /usr/share/zgen/zgen.zsh
if ! zgen saved; then
    zgen oh-my-zsh
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/wd
    zgen oh-my-zsh plugins/command-not-found
    zgen load zsh-users/zsh-completions src
    zgen load lukechilds/zsh-nvm
    zgen save
    nvm install lts/erbium
fi

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

alias 'gl=git log --graph --all --decorate --date=local'
alias 'gcl=git clone'
alias "gbl=git for-each-ref refs/heads --color=always --sort -committerdate --format='%(HEAD)%(color:reset);%(color:yellow)%(refname:short)%(color:reset);%(contents:subject);%(color:green)(%(committerdate:relative))%(color:blue);<%(authorname)>' | column -t -s ';'"  # show branches ordered by most recently modified
alias 'gs=git status'
alias 'gsh=git show'
alias 'gd=git diff'
alias 'gdc=git diff --cached'
alias 'gk=git checkout'
alias 'gr=git reset'
alias 'grh=git reset --hard'
alias 'grm=git rm'
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
