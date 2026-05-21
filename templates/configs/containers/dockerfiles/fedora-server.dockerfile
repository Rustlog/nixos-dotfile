FROM fedora:latest

RUN echo "fedora-server" > /etc/hostname

RUN dnf update -y && dnf install --setopt=install_weak_deps=False -y tini nginx httpd mariadb-server postgresql-server openssh-server cronie neovim vim-enhanced net-tools iproute bind-utils zip tar ca-certificates @development-tools python3 python3-pip nodejs npm git curl wget htop procps-ng tree socat tcpdump traceroute nmap-ncat jq rsync tmux findutils which passwd && dnf clean all

RUN npm install -g eslint

RUN pip3 install pylint

RUN ssh-keygen -A && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "root:fedora-root" | chpasswd

RUN mkdir -p /etc/xdg/nvim/
RUN printf '%b\n' "syntax enable\nse sts=4 sw=4 et\nfiletype plugin indent on\n" > /etc/xdg/nvim/init.vim

EXPOSE 22 80 443

WORKDIR /root

