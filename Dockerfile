FROM debian:stretch
LABEL maintainer="liang-bo.wang@wustl.edu"

ARG DEBIAN_FRONTEND=noninteractive

# Upgrade APT
# Configure locale and timezone
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    echo "America/Chicago" > /etc/timezone && \
    rm /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata; \
    apt-get update && apt-get install -y locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    # dkpg-reconfigure seems to take over the locale generation
    # locale-gen en_US.UTF-8 && \
    dpkg-reconfigure -f noninteractive locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8; \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8" \
    PATH="/opt/conda/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tmux less libreadline7 gzip bzip2 zstd gnupg2 \
    openssh-client wget curl ca-certificates rsync \
    libglib2.0-0 libxext6 libsm6 libxrender1 git vim-nox make \
    htop parallel ncdu \
    libnss-sss && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Fish shell
RUN curl -o /tmp/fish.key -sL http://download.opensuse.org/repositories/shells:fish:release:3/Debian_9.0/Release.key && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add /tmp/fish.key && \
    echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_9.0/ /' > /etc/apt/sources.list.d/fish.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends fish && \
    chsh -s /usr/bin/fish && \
    rm /tmp/fish.key && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ripgrep and fd
RUN wget --quiet https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep-11.0.2-x86_64-unknown-linux-musl.tar.gz -O $HOME/ripgrep.tar.gz && \
    cd $HOME && tar xf $HOME/ripgrep.tar.gz && \
    cd `find $HOME -type d -name "ripgrep*"` && \
    mkdir -p /usr/local/share/man/man1 && \
    cp doc/rg.1 /usr/local/share/man/man1/ && \
    cp rg /usr/local/bin/ && \
    cp complete/rg.fish /usr/share/fish/vendor_completions.d && \
    rm -rf $HOME/ripgrep* && \
    \
    wget --quiet https://github.com/sharkdp/fd/releases/download/v7.4.0/fd-v7.4.0-x86_64-unknown-linux-musl.tar.gz -O $HOME/fd.tar.gz && \
    cd $HOME && tar xf $HOME/fd.tar.gz && \
    cd `find $HOME -type d -name "fd*"` && \
    cp fd /usr/local/bin/ && \
    cp autocomplete/fd.fish /usr/share/fish/vendor_completions.d/ && \
    cp fd.1 /usr/local/share/man/man1/ && \
    rm -rf $HOME/fd*

# exa
COPY exa_0.9.0_musl/exa /usr/local/bin/
COPY exa_0.9.0_musl/exa.1 /usr/local/share/man/man1/
COPY exa_0.9.0_musl/completions.fish /usr/share/fish/vendor_completions.d/exa.fish

# Miniconda3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O $HOME/miniconda.sh && \
    /bin/bash $HOME/miniconda.sh -b -p /opt/conda && \
    conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    echo '. /opt/conda/etc/profile.d/conda.sh' > /etc/profile.d/conda.sh && \
    rm $HOME/miniconda.sh

# Fish shell setting
RUN git clone https://github.com/ccwang002/dotfiles.git $HOME/dotfiles && \
    cd $HOME/dotfiles && \
    /opt/conda/bin/python3 ./dotfile_setup.py \
        --only "~/.inputrc" --only "~/.editrc" --only "~/.tmux.conf" && \
    rm -rf $HOME/dotfiles/.git && \
    rm -rf /root/.cache
