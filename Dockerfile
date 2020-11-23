# build: docker build -t uberi/docker-dev-env .

FROM ubuntu:20.04
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake autoconf ffmpeg libjpeg-dev libpng-dev libffi-dev rr

# set up locales (from http://jaredmarkell.com/docker-and-locales/)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# install packages that were removed from the image because of the assumption that it would be used non-interactively (e.g., manpages)
RUN yes | unminimize

# set up Go stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y golang golint golang-golang-x-tools

# set up DB stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y sqlite3 postgresql-client postgresql-doc

# set up Java stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk default-jre

# set up JS stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs npm yarnpkg
RUN ln -s /usr/bin/yarnpkg /usr/bin/yarn

# set up Python stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-all-dev python3-pip python3-wheel python3-rope python3-numpy python3-sympy python3-sklearn python3-pandas python3-matplotlib python3-serial python3-requests python3-sortedcontainers python3-xdo python3-psycopg2 python3-pudb flake8 mypy python3-scipy python3-plotly python3-seaborn python3-bs4 python3-pexpect python3-pyperclip python3-venv python3-q python3-flask twine
RUN ln -s /usr/bin/python3 /usr/bin/python && ln -s /usr/bin/pip3 /usr/bin/pip

# set up useful command line tools
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y colordiff tree tmux p7zip-full curl wget gnupg2 git jekyll pcregrep whois net-tools iputils-ping traceroute checkinstall jq miller exif rsync libheif-examples sox lame jupyter-notebook moreutils vim w3m shellcheck expect

# set up nGrok
RUN curl -o ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip ngrok.zip ngrok -d /usr/bin

# set up AWS CLI
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y groff
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# set Google Cloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list; curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | DEBIAN_FRONTEND=noninteractive apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -; apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y google-cloud-sdk

# set up user with ZSH and sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y zsh zsh-syntax-highlighting zsh-doc zgen socat python3-psutil python3-pygit2 powerline
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y sudo
RUN useradd -ms /bin/bash dev && echo "dev:dev" | chpasswd && adduser dev sudo && chsh -s /usr/bin/zsh dev
USER dev
WORKDIR /home/dev/app

# set up Rust stuff using Rustup's unattended install mode
RUN curl https://sh.rustup.rs -sSf |  sh -s -- -y

# set up vend, a package vendoring utility for Golang (usage: run "vend" in the working directory, then `go build -mod vendor` when building)
RUN go get github.com/nomad-software/vend

# apply ZSH config and shell aliases
COPY --chown=dev .zshrc /home/dev/.zshrc
RUN zsh /home/dev/.zshrc

# apply tmux config and plugins
COPY --chown=dev .tmux.conf /home/dev/.tmux.conf
RUN cd /home/dev && git clone --depth=1 https://github.com/NHDaly/tmux-better-mouse-mode.git

# workaround for broken yarnpkg command: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=933229
ENV NODE_PATH=/usr/lib/nodejs:/usr/share/nodejs

ENTRYPOINT [ "/bin/zsh" ]
