FROM ubuntu:18.04
RUN apt update && apt install -y openssh-client sshpass rsync wget curl git python3-pip vim mc
RUN python3 -m pip install --upgrade pip
RUN pip install xonsh==0.9.13 pexpect
ENTRYPOINT ["tail","-f", "/dev/null"]