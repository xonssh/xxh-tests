Development and test environment for [xxh/xxh](https://github.com/xxh/xxh) contains 
network of docker containers which allow to test the ssh connections and xxh functionality 
with or without [AppImage FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE). 

Docker containers in the network:

| Name/Host | Auth                                          | FUSE |
|-----------|-----------------------------------------------|------|
| start     | `./xde goto start`                            |      |
| ubuntu_k  | `start$ ssh -i keys/id_rsa root@ubuntu_k`     |      |
| ubuntu_kf | `start$ ssh -i keys/id_rsa root@ubuntu_kf`    | yes  |
| arch_p    | `start$ sshpass -p docker ssh docker@arch_p`  |      |

Every container has `/xxh-dev` it is the volume that contains files in this directory. For example 
if you'll add a file to `tests/new.xsh` it appears on all hosts immediately in `/xxh-dev/tests/new.xsh`.

## Workflow

1. Install `xonsh`, `docker` and `docker-compose` on your dev system
2. Run `./xde build` to git clone the [xxh/xxh](https://github.com/xxh/xxh) master and build the docker containers. 
3. Run `./xde up` to up the containers. Wait around 5 seconds after first start while containers init successfully. 
4. Run `./xde test` to run tests. In case of first errors don't panic and try to run tests again because sometimes 
the initialization takes time.
5. Open your IDE to make changes and commit. You can commit from `./` to `xxh/xxh-dev` and from `./xxh` to `xxh/xxh`.
6. Now you can go to `start` host and try your first connect using xxh:
```
./xde goto start
cd /xxh-dev/xxh
./xxh -i /xxh-dev/keys/id_rsa root@ubuntu_k
```
7. Change the code in IDE and run `./xxh` on `start` container. It's so easy!
8. After end of work you can `./xde stop` or `./xde remove` the containers. You rock! 
9. Try to find easter egg in the code and tell us about your work [on Gitter](https://gitter.im/xonssh-xxh/community)

This workflow was originally developed on `ubuntu 19.10`, `docker 19.03.5`, `docker-compose 1.25.3`, `xonsh 0.9.13`, `pycharm 2019.3.3`.

## xxh development environment tool

```
$ ./xde -h                                                                                                                                                                                              
usage: xde <command>

xxh development environment commands:

   build       Build the docker containers and get the xxh code if ./xxh is not exists
   up          Docker-compose up the containers
   test    t   Run tests
   goto    g   Open bash by the container name part
   start       Docker-compose start the containers
   stop        Docker-compose stop the containers
   remove      Docker-compose remove the containers
   
Try `./xde <command> --help` to get more info.   
   
positional arguments:
  command     Command to run

optional arguments:
  -h, --help  show this help message and exit

```
