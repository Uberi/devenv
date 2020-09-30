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

PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

# load virtualenv if present
if [ -f /home/dev/app/venv ]; then
    source /home/dev/app/venv/bin/activate
fi

# load config script if present
if [ -f /home/dev/app/config.sh ]; then
    source /home/dev/app/config.sh
fi

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
alias 'gp=git push'
alias 'gph=git push origin HEAD'
alias 'gpf=git push --force-with-lease origin HEAD'
alias 'gcl=git clone'
alias 'gf=git fetch --all'
alias 'gu=git pull'
alias 'gur=git pull --rebase'
alias 'gb=git branch'
alias 'gbd=git branch --delete'
alias 'gbl=git branch --list --all'
alias 'gs=git status'
alias 'gsh=git show'
alias 'gd=git diff'
alias 'gdc=git diff --cached'
alias 'gdt=git difftool --dir-diff --tool=meld --no-prompt'
alias 'gdtc=git difftool --cached --dir-diff --tool=meld --no-prompt'
alias 'ga=git add'
alias 'gau=git add --update'
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
alias rand-password='shuf -n5 /usr/share/dict/american-english | paste -sd " " -'
