FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y openssh-client sshpass rsync wget curl git python3-pip vim mc
RUN python3 -m pip install --upgrade pip
RUN pip install xonsh==0.9.14 pexpect pyyaml
RUN echo 'sshpass -p docker ssh docker@arch_p \n\
./xxh docker@arch_p +P docker \n\
ssh -i id_rsa root@ubuntu_k \n\
./xxh -i id_rsa root@ubuntu_k \n\
ssh -i id_rsa root@ubuntu_kf \n\
./xxh -i id_rsa root@ubuntu_kf' > /root/.bash_history

ENTRYPOINT ["/bin/sh","-c", "cp /xxh/xxh-dev/keys/id_rsa ~/ && chown root:root ~/id_rsa && chmod 0600 ~/id_rsa && ln -s /xxh/xxh/xxh ~/xxh && tail -f /dev/null"]