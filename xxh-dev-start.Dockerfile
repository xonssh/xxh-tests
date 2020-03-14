FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y openssh-client sshpass rsync wget curl git python3-pip vim mc zsh fish sudo
RUN python3 -m pip install --upgrade pip
RUN pip install xonsh==0.9.14 pexpect pyyaml asciinema

WORKDIR /root
RUN echo 'su user-fish \n\
su user-zsh \n\
su user-xonsh \n\
sshpass -p docker ssh docker@arch_p \n\
./xxh docker@arch_p +P docker \n\
ssh -i id_rsa root@ubuntu_k \n\
./xxh -i id_rsa root@ubuntu_k \n\
ssh -i id_rsa root@ubuntu_kf \n\
./xxh -i id_rsa root@ubuntu_kf' > .bash_history
RUN ln -s /root /home/root

RUN useradd -s $(which xonsh) -m user-xonsh
RUN useradd -s $(which zsh) -m user-zsh
RUN useradd -s $(which fish) -m user-fish

USER user-zsh
WORKDIR /home/user-zsh
# https://github.com/ohmyzsh/ohmyzsh/#manual-installation
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git .oh-my-zsh
RUN cp .oh-my-zsh/templates/zshrc.zsh-template .zshrc

USER root
WORKDIR /root
ADD xxh-dev-start.entrypoint.sh /xxh-dev-start.entrypoint.sh
ENTRYPOINT ["/xxh-dev-start.entrypoint.sh"]
