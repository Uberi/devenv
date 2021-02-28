devenv
======

A Docker image and wrapper script set up for full-stack web dev using Python/Javascript/Go, various databases, and various cloud providers (AWS, GCP).

Features:

* One command to drop you into an isolated `zsh` with Oh-My-Zsh, syntax highlighting, `nvm`, and other goodies already set up.
* Your working directory on the host machine is mounted as `/home/dev/app` within the container, but nothing else is available.
* Somewhat protects your machine against potentially malicious packages (see "Rationale" section for details and caveats).
* Avoid file/config pollution by packages that write files to unusual places (e.g., NLTK, Puppeteer, GCloud SDK).
* Includes useful but proprietary utilities such as nGrok.
* Mounts `.git` from your working directory as read-only, preventing software inside the environment from tampering with Git settings such as hooks, diff commands, credential helper tools, etc.

Basically I want more isolation when developing software, so this is a Docker image that closely resembles [my dev setup](https://github.com/Uberi/setup-machine). See the "Rationale" section for caveats and intended use cases.

Quickstart:

```bash
# download the image and create the wrapper script
docker pull uberi/devenv
cat << 'EOF' > ~/.local/bin/devenv
#!/usr/bin/env bash
docker run -v "$(pwd):/home/dev/app" -v "$(pwd)/.git:/home/dev/app/.git:ro" --read-only --cap-drop ALL --security-opt no-new-privileges "$@" -it uberi/devenv
EOF
cat << 'EOF' > ~/.local/bin/devenv-lite
#!/usr/bin/env bash
docker run -v "$(pwd):/home/dev/app" -v "$(pwd)/.git:/home/dev/app/.git:ro" --network host "$@" -it uberi/devenv
EOF
chmod +x ~/.local/bin/devenv ~/.local/bin/devenv-lite

# now, try it out
devenv

# this version allows sudo to be used within the container (password is "dev"), and makes services inside and outside the container able to see each other
# devenv-lite is potentially less secure because sudo requires us to use a less restrictive seccomp profile, and services within the container could make network calls to servers running on the host OS
# (e.g., programs inside the container could access the host's CUPS print server)
devenv-lite
```

Or, build it yourself:

```bash
git clone git@github.com:Uberi/devenv.git
cd devenv
docker build -t uberi/devenv .

# push it to Docker Hub
docker push uberi/devenv
```

Rationale
---------

NPM and PyPI packages are largely uncurated and unvetted, which has caused problems before. NPM has it especially bad, due to sprawling dependency trees in many popular frameworks:

* [Malicious npm package opens backdoors on programmers' computers](https://www.zdnet.com/article/malicious-npm-package-opens-backdoors-on-programmers-computers/) (2020, `twilio-npm`)
* [Malicious npm package caught trying to steal sensitive Discord and browser files](https://www.zdnet.com/article/malicious-npm-package-caught-trying-to-steal-sensitive-discord-and-browser-files/) (2020, `fallguys`)
* [Three npm packages found opening shells on Linux, Windows systems](https://www.zdnet.com/article/three-npm-packages-found-opening-shells-on-linux-windows-systems/) (2020, `plutov-slack-client`, `nodetest199`, `nodetest1010`)
* [Plot to steal cryptocurrency foiled by the npm security team](https://blog.npmjs.org/post/185397814280/plot-to-steal-cryptocurrency-foiled-by-the-npm) (2019, `electron-native-notify`)
* [npm Pulls Malicious Package that Stole Login Passwords](https://www.bleepingcomputer.com/news/security/npm-pulls-malicious-package-that-stole-login-passwords/) (2019, `bb-builder`)
* [Details about the event-stream incident](https://blog.npmjs.org/post/180565383195/details-about-the-event-stream-incident) (2018, `event-stream`)
* [Postmortem for Malicious Packages Published on July 12th, 2018](https://eslint.org/blog/2018/07/postmortem-for-malicious-package-publishes) (2018, `eslint-scope`, `eslint-config-eslint`)
* [Reported malicious module: getcookies](https://blog.npmjs.org/post/173526807575/reported-malicious-module-getcookies) (2018, `getcookies`)

PyPI isn't totally safe either:

* [Malicious Python libraries targeting Linux servers removed from PyPI](https://www.zdnet.com/article/malicious-python-libraries-targeting-linux-servers-removed-from-pypi/)
* [Snake bites: Beware malicious Python libraries](https://www.infoworld.com/article/3487701/snake-bites-beware-malicious-python-libraries.html)

**You may trust your direct dependencies, but do you trust your dependencies' dependencies?** As you move further down the dependency tree, you also move further away from code that you've vetted and trusted. You likely have not vetted `event-stream`'s dependencies, but missing even that one malicious package means that you end up [getting your money stolen or worse](https://blog.npmjs.org/post/185397814280/plot-to-steal-cryptocurrency-foiled-by-the-npm).

**Why bother with any isolation then, if your software would be compromised anyways?** Completely true - this probably doesn't help much if you're using this at the typical workplace - who cares about what else is on the laptop if your product itself is compromised?

However, if you work on your own machine, you probably have other valuable things you'd like to protect besides the current thing you're working on. Many developers run `npm install` on the same machine that they use to log into their bank and email.

Some people do development inside virtual machines. I used to do this as well, but having to switch projects multiple times a day was a very frustrating experience: shared folders cause all sorts of problems (e.g., some hot reloaders fail to reload, unpredictable write performance), RAM usage prevents more than 3-4 projects from being open at a time, and battery life is severely reduced.

**Isn't it relatively easy to escape from a Docker container?** I don't claim that `devenv` will protect the rest of your system from all malware, but I do claim that `devenv` will at least prevent all of the attacks in the articles above from affecting the rest of your system - relatively low-effort malware that could easily be prevented by equally low-effort sandboxing technology.

In the future, I will consider solutions that are specifically designed for isolation, such as FirecrackerVM. However, putting everything in containers already significantly raises the bar for malware, while keeping the dev experience as vanilla as possible. And of course, `devenv` drops root and uses the `--security-opt no-new-privileges` flag as per best practices.

It's also important to build an awareness of what isolation will protect you from. I was reminded of this a while ago, when a popular JS framework silently decided to install a pre-commit hook in the project's `.git` directory - apparently for linting purposes. I then accidentally ran `git commit` on my host machine, causing the untrusted hook script to execute.

**Why use this over just containerizing the project properly?** Sometimes, you just don't have time - a demo to finish by 6pm, an onboarding session where you're setting things up live, or a meeting where you want to code something up in real-time during your presentation. I've been guilty before of breaking my habits for all of these reasons. That's why this Docker image is as complete and flexible as possible, so we don't have to compromise when getting started is urgent.

Usage
-----

The main entry point is `devenv`, a shell script that accepts the same arguments as `docker run`.

In the examples below, lines beginning with `$` are on the host machine, lines beginning with `~` are in the `devenv` shell.

For example, to work on a React app:

```bash
$ cd path/to/your/react/app
$ devenv -p 127.0.0.1:3000:3000  # drop into devenv shell with port 3000 mapped to port 3000 on the host (app will be available at http://localhost:3000)
~ npm start  # start your app with a development server running on port 3000
Compiled successfully!

You can now view test-app in the browser.

  Local:            http://localhost:3000
  On Your Network:  http://172.17.0.2:3000

Note that the development build is not optimized.
To create a production build, use npm run build.
```

Or run a script without network access:

```bash
$ devenv --network none
~ curl http://google.com
curl: (6) Could not resolve host: google.com
```

Or relax the restrictions a bit to allow `sudo` (password is "dev") and access to host network interfaces:

```bash
$ devenv-lite
~ sudo apt install openscad
[sudo] password for dev: 
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
...
```
