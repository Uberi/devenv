# build: docker build -t uberi/devenv .

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get install -y build-essential cmake autoconf ffmpeg libjpeg-dev libpng-dev libffi-dev rr

# set up locales (from http://jaredmarkell.com/docker-and-locales/)
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# install packages that were removed from the image because of the assumption that it would be used non-interactively (e.g., manpages)
RUN yes | unminimize

# set up Go stuff
RUN apt-get install -y golang golint golang-golang-x-tools

# set up DB stuff
RUN apt-get install -y sqlite3 postgresql-client postgresql-doc

# set up Java stuff
RUN apt-get install -y default-jdk default-jre

# set up JS stuff
RUN apt-get install -y nodejs npm yarnpkg
RUN ln -s /usr/bin/yarnpkg /usr/bin/yarn
# workaround for broken yarnpkg command: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=933229
ENV NODE_PATH=/usr/lib/nodejs:/usr/share/nodejs

# set up Python stuff
RUN apt-get install -y python3-all-dev python3-pip python3-wheel python3-rope python3-numpy python3-sympy python3-sklearn python3-pandas python3-matplotlib python3-serial python3-requests python3-sortedcontainers python3-xdo python3-psycopg2 python3-pudb flake8 mypy python3-scipy python3-plotly python3-seaborn python3-bs4 python3-pexpect python3-pyperclip python3-venv python3-q twine

# set up useful command line tools
RUN apt-get -y update && apt-get install -y vim colordiff tmux p7zip-full curl wget gnupg2 git pcregrep whois net-tools iputils-ping traceroute checkinstall jq miller exif rsync libheif-examples sox lame jupyter-notebook moreutils w3m expect shellcheck catimg mitmproxy cgdb sloccount feedgnuplot

# set up AWS CLI
RUN apt-get install -y groff
RUN curl --silent "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip -q awscliv2.zip && ./aws/install

# set Google Cloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list; curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -; apt-get -y update && apt-get install -y google-cloud-sdk

# set up Heroku CLI
RUN curl --silent https://cli-assets.heroku.com/install-ubuntu.sh | sh

# set up DigitalOcean CLI
RUN curl --silent --location https://github.com/digitalocean/doctl/releases/download/v1.66.0/doctl-1.66.0-linux-amd64.tar.gz | tar --extract --gunzip --verbose --directory /usr/local/bin doctl

# set up Redli (like redis-cli, but supports TLS and has other small quality-of-life improvements)
RUN curl --silent --location https://github.com/IBM-Cloud/redli/releases/download/v0.5.2/redli_0.5.2_linux_amd64.tar.gz | tar --extract --gunzip --verbose --directory /usr/local/bin redli

# set up delta (fancy git diff)
RUN curl --silent --location https://github.com/dandavison/delta/releases/download/0.11.3/git-delta_0.11.3_amd64.deb -o git-delta.deb && dpkg -i git-delta.deb

# set up broot (fancy file browser)
RUN curl --silent https://dystroy.org/broot/download/x86_64-linux/broot -o /usr/local/bin/broot && chmod +x /usr/local/bin/broot && ls -lah /usr/local/bin/broot

# set up user with ZSH and sudo
RUN apt-get install -y zsh zsh-syntax-highlighting zsh-doc socat python3-psutil python3-pygit2 sudo
RUN useradd -ms /bin/bash dev && echo "dev:dev" | chpasswd && adduser dev sudo && chsh -s /usr/bin/zsh dev

USER dev
WORKDIR /home/dev/app

# set up Rust stuff using Rustup's unattended install mode
RUN curl --silent https://sh.rustup.rs -sSf | sh -s -- -y

# apply tmux config and plugins
COPY --chown=dev .tmux.conf /home/dev/.tmux.conf
RUN cd /home/dev && git clone --depth=1 https://github.com/NHDaly/tmux-better-mouse-mode.git

# apply ZSH config
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
RUN git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
COPY --chown=dev .zshrc /home/dev/.zshrc
RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | PROFILE=~/.zshrc zsh; zsh -c 'source ~/.zshrc; nvm install lts/gallium'
RUN broot --install
RUN git config --global core.pager delta && git config --global user.email "dev@devenv" && git config --global user.name "Dev"

ENTRYPOINT [ "/bin/zsh", "--login" ]
