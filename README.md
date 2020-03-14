Development and test environment for [xxh/xxh](https://github.com/xxh/xxh) contains 
network of docker containers which allow to test the ssh connections and xxh functionality 
with or without [AppImage FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE). 

Docker containers in the network:

| Hostname  | Auth             | FUSE | rsync | users                           |
|-----------|------------------|------|-------|---------------------------------|
| start     | `./xde g start`  |      |       | `root`, `user-[xonsh/zsh/fish]` |
| ubuntu_k  | key              |      |       | `root`                          |
| ubuntu_kf | key              | yes  |  yes  | `root`                          |
| centos_k  | key              |      |       | `root`                          |
| arch_p    | password         |      |       | `root`, `docker`                |

Every container has `/xxh` it is the volume. For example if you'll add a file to `tests/new.xsh` 
it appears on all hosts immediately in `/xxh/xxh-dev/tests/new.xsh`.

## Workflow

1. Install `docker`, `docker-compose` and `xonsh` on your dev system.
2. Create distinct empty `xxh` directory - it becomes partial representation of https://github.com/xxh. Clone this repo and `cd xxh/xxh-dev`.
3. Run `./xde build` to git clone the repos master to `xxh/` and build the docker containers. 
4. Run `./xde up` to up the containers. 
5. Run `./xde test` or `./xde t` to run tests. In case of first errors don't panic and try to run tests again because sometimes 
the initialization takes time.
6. Open `xxh` dir in your IDE to make changes and commit many repos.
7. Now you can go to `start` host and try your first connect using xxh:
```
./xde goto start

# Press UP key to get connection strings to other hosts from bash history.
# Here xxh will be from /xxh/xxh/ that is your local  directory
root@start> xxh -i ~/id_rsa root@ubuntu_k

# Try from another shell
root@start> su user-zsh
user-zsh@start> xxhp i xxh-plugin-zsh-ohmyzsh
user-zsh@start> xxh -i ~/id_rsa root@ubuntu_k
root@ubuntu_k% echo $ZSH_THEME && exit
agnoster
user-zsh@start> source xxh.zsh -i ~/id_rsa root@ubuntu_k
root@ubuntu_k% echo $ZSH_THEME
bira
```
7. Change the code in IDE and run `./xxh` on `start` container. It's so easy!
8. Run tests `./xde t` (don't forget about `./xde t --help`) 
8. After end of work you can `./xde stop` or `./xde remove` the containers. 
9. You rock! Try to find easter egg in the code and tell us about your work [on Gitter](https://gitter.im/xonssh-xxh/community)

This workflow was originally developed on `ubuntu 19.10`, `docker 19.03.5`, `docker-compose 1.25.3`, `xonsh 0.9.14`, `pycharm 2019.3.3`.

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
