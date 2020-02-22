# xxh-tests
Development and test environment for [xonssh/xxh](https://github.com/xonssh/xxh)

0. Install `xonsh`, `docker` and `docker-compose`
1. Create `./xxh` directory with xxh code. If you skip this step the directory will be created from [xonssh/xxh master](https://github.com/xonssh/xxh).
2. Run `./start_env.xsh`. It builds a network with docker containers and runs tests. The `xxh-tests` directory will be mounted on every container in `/`.
3. Now you can edit, test and commit the code from `./xxh` and `./tests`.
4. When you need to run tests just use last line from `start_env.xsh`.

Thank you for your help!
