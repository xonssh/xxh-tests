FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y openssh-client sshpass rsync wget curl git python3-pip vim mc
RUN python3 -m pip install --upgrade pip
RUN pip install xonsh==0.9.14 pexpect pyyaml
RUN echo 'sshpass -p docker ssh docker@arch_p \n\
/xxh/xxh/xxh docker@arch_p +P docker \n\
ssh -i /xxh/xxh-dev/keys/id_rsa root@ubuntu_k \n\
/xxh/xxh/xxh -i keys/id_rsa root@ubuntu_k \n\
ssh -i /xxh/xxh-dev/keys/id_rsa root@ubuntu_kf \n\
/xxh/xxh/xxh -i keys/id_rsa root@ubuntu_kf' > /root/.bash_history

ENTRYPOINT ["tail","-f", "/dev/null"]