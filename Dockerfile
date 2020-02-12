FROM python:3.7-alpine
RUN apk update && apk add openssh rsync wget curl git
RUN pip install xonsh
WORKDIR /xxh-tests
ENTRYPOINT ["tail","-f", "/dev/null"]