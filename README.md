Development and test environment for [xonssh/xxh](https://github.com/xonssh/xxh) contains 
network of docker containers which allow to test the ssh connections and xxh functionality 
with or without [AppImage FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE). 

There are three containers in the network with names/hostnames:
* `start` host has xonsh installed from pip and other tools
* `ubuntu_without_fuse` host has ssh server without FUSE and AppImage should be extracted before using
* `ubuntu_with_fuse` host has ssh server and FUSE for running AppImage without extracting

Every container has `/xxh-dev` it is the volume that contains files in this directory. For example 
if you'll add a file to `tests/new.xsh` it appears on all hosts immediately in `/xxh-dev/tests/new.xsh`.

## Workflow

1. Install `xonsh`, `docker` and `docker-compose` on your dev system
2. Run `./xde build` to git clone the [xonssh/xxh](https://github.com/xonssh/xxh) master and build the docker containers. 
3. Run `./xde up` to up the containers. Wait around 5 seconds after first start while containers init successfully. 
4. Run `./xde test` to run tests. In case of first errors don't panic and try to run tests again because sometimes 
the initialization takes time.
5. Open `./` and `./xxh` directories in your IDE to make changes and commit.
6. Now you can go to `start` host and try your first connect using xxh:
```
docker exec -it xxh-dev_start_1 bash
cd /xxh-dev/xxh
./xxh -i /xxh-dev/keys/id_rsa root@ubuntu_without_fuse
```
7. Change the code in IDE and run `./xxh` on `start` container. It's so easy!
8. After end of work you can `./xde stop` or `./xde remove` the containers. You rock! 
9. Tell us about your work [on Gitter](https://gitter.im/xonssh-xxh/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

## Xxh development environment (XDE)

```
$ ./xde --help                                                                                                    
usage: xde <command>

xxh development environment (xde) commands:

   build   Build the docker containers and get the xxh code if ./xxh is not exists
   up      Docker-compose up the containers
   test    Run tests
   start   Docker-compose start the containers
   stop    Docker-compose stop the containers
   remove  Docker-compose remove the containers

positional arguments:
  command     Command to run

optional arguments:
  -h, --help  show this help message and exit
```
