FROM ubuntu:latest

RUN echo "ubuntu-server" > /etc/hostname

RUN apt-get update -y && apt-get install -y tini nginx apache2 mariadb-server postgresql openssh-server cron neovim vim net-tools iproute2 dnsutils zip tar ca-certificates build-essential python3 python3-pip nodejs npm git curl wget htop procps tree

RUN ssh-keygen -A && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "root:password" | chpasswd

# Expose ports for SSH, HTTP, HTTPS, MySQL/MariaDB, PostgreSQL, Redis
EXPOSE 22 80 443 3306 5432 6379

WORKDIR /root

