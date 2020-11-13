FROM uphy/ubuntu-desktop-jp:20.04

# Install development tools.
RUN apt-get update && \
    apt-get install -y \
      openjdk-11-jdk \
      git \
      && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Install Eclipse
RUN mkdir -p /usr/local/eclipse && \
    wget -qO- http://ftp.yz.yamagata-u.ac.jp/pub/eclipse/eclipse/downloads/drops4/R-4.17-202009021800/eclipse-SDK-4.17-linux-gtk-x86_64.tar.gz | tar zx --strip-components=1 -C /usr/local/eclipse && \
    ln -s /usr/local/eclipse/eclipse /usr/local/bin/eclipse

# Install Maven
RUN mkdir -p /usr/local/maven && \
    wget -qO- http://www-us.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz | tar zx --strip-components=1 -C /usr/local/maven && \
    ln -s /usr/local/maven/bin/mvn /usr/local/bin

# Install Visual Studio Code
RUN mkdir -p /usr/local/vscode && \
    wget -qO vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
    dpkg -i vscode.deb && \
    apt-get install -f && \
    rm -f vscode.deb

# Install *env (hack)
RUN git clone https://github.com/anyenv/anyenv ~/.anyenv && \
    echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(anyenv init -)"' >> ~/.bashrc && \
    mkdir -p ~/.anyenv/envs && \
    echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(anyenv init -)"' >> ~/.bash_profile
ENV PATH=/root/.anyenv/bin:$PATH
RUN anyenv install --force-init && \
    anyenv install jenv && \
    anyenv install goenv

# Setup jenv (hack)
RUN export PATH=/root/.anyenv/envs/jenv/bin:$PATH && \
    mkdir -p /root/.jenv/versions && \
    jenv add /usr/lib/jvm/java-11-openjdk-amd64/ && \
#    jenv global 10.0.2 && \
    mv /root/.jenv/* /root/.anyenv/envs/jenv && \
    rm -rf /root/.jenv

# Setup goenv (hack)
ENV _GO_VERSION=1.15.3
RUN export PATH=/root/.anyenv/envs/goenv/bin:/root/.anyenv/envs/goenv/plugins/go-build/bin:$PATH && \
    goenv install ${_GO_VERSION} && \
    goenv global ${_GO_VERSION} && \
    mv /root/.goenv/* /root/.anyenv/envs/goenv && \
    rm -rf /root/.goenv

# Install VScode Go extension(beta version)
RUN wget -q $(curl -s https://api.github.com/repos/golang/vscode-go/releases/latest | grep "browser_download_url.*.vsix" | grep "go-" | cut -d : -f 2,3 | sed -e 's/"//' -e 's/"$//') && \
    mv go-*.vsix Go-latest.vsix && \
    code --install-extension Go-latest.vsix --user-data-dir "."
# Required modules for Go extension
# set PATH because anyenv doesn't work for Dockerfile
RUN export PATH=/root/.anyenv/envs/goenv/versions/${_GO_VERSION}/bin/:$PATH && \
    go get github.com/mdempsky/gocode && \
    go get github.com/uudashr/gopkgs/cmd/gopkgs && \
    go get github.com/ramya-rao-a/go-outline && \
    go get github.com/acroca/go-symbols && \
    go get golang.org/x/tools/cmd/guru && \
    go get golang.org/x/tools/cmd/gorename && \
    go get github.com/derekparker/delve/cmd/dlv && \
    go get github.com/stamblerre/gocode && \
    go get github.com/rogpeppe/godef && \
    go get github.com/ianthehat/godef && \
    go get golang.org/x/tools/cmd/godoc && \
    go get github.com/sqs/goreturns && \
    go get golang.org/x/lint/golint && \
    go get github.com/cweill/gotests/... && \
    go get github.com/fatih/gomodifytags && \
    go get github.com/josharian/impl && \
    go get github.com/davidrjenni/reftools/cmd/fillstruct && \
    go get github.com/haya14busa/goplay/cmd/goplay

COPY files /
