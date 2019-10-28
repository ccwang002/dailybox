# My daily Docker image for McDonnell Genome Institute (MGI)
This Docker image `lbwang/dailybox` based on Debian stable includes several tools that work on MGI cluster. It includes:

- tmux
- less
- wget, curl, rsync
- git
- make
- vim
- htop
- parallel
- ncdu
- zstd
- fish
- ripgrep
- fd
- exa
- miniconda3


## exa binary
The folder `exa_0.9.0_musl` contains [exa] static binary (linux x84_64 musl):

    git clone https://github.com/ogham/exa.git
    docker run -v $PWD:/volume -w /volume -it --rm clux/muslrust bash

    # Inside Docker
    apt-get update
    apt-get install cmake
    make target/release/exa
    mkdir release_linux_musl
    install -m755 target/x86_64-unknown-linux-musl/release/exa release_linux_musl/
    install -m644 contrib/completions.fish release_linux_musl/
    install -m644 contrib/man/exa.1 release_linux_musl/

[exa]: https://github.com/ogham/exa
