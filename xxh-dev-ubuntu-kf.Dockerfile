FROM xxh/xxh-dev-ubuntu-k
# https://github.com/rastasheep/ubuntu-sshd
RUN apt update && apt install -y fuse rsync

