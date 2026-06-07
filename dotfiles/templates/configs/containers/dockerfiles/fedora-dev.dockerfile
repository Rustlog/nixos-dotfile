FROM fedora:latest

RUN echo "fedora-dev" > /etc/hostname

RUN dnf update -y && dnf install --setopt=install_weak_deps=False -y iproute tini fzf lsd bat zsh nginx httpd nodejs npm java clang gcc openssh-server neovim tmux rsync git git-extras python3 python3-pip golang rust cargo make cmake gdb strace jq curl wget htop ripgrep procs procps-ng tree ShellCheck zip unzip && dnf clean all

RUN npm install -g eslint

RUN pip3 install pylint

RUN ssh-keygen -A && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "root:fedora-root" | chpasswd

RUN mkdir -p /etc/xdg/nvim/
RUN printf '%b\n' "syntax enable\nse sts=4 sw=4 et\nfiletype plugin indent on" > /etc/xdg/nvim/init.vim

EXPOSE 22 80 443

WORKDIR /root

