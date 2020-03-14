FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y openssh-client sshpass rsync wget curl git python3-pip vim mc zsh fish sudo
RUN python3 -m pip install --upgrade pip
RUN pip install xonsh==0.9.14 pexpect pyyaml asciinema

RUN useradd -s $(which xonsh) -m user-xonsh
RUN useradd -s $(which zsh)   -m user-zsh
RUN useradd -s $(which fish)  -m user-fish

ADD xxh-dev-start*.sh /
RUN /xxh-dev-start.sh

ENTRYPOINT ["/xxh-dev-start-entrypoint.sh"]
