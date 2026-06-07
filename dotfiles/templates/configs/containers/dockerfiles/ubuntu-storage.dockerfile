FROM ubuntu:latest

RUN echo "ubuntu-storage" > /etc/hostname

RUN apt update -y && apt install -y tini openssh-server rsync rclone restic zip unzip curl wget s3fs nfs-common samba cifs-utils parted fdisk lvm2 xfsprogs btrfs-progs tree htop procps && apt-get clean

RUN mkdir /var/run/sshd && \
    ssh-keygen -A && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "root:I-m-root" | chpasswd

EXPOSE 22 445

WORKDIR /root

