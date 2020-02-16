#!/usr/bin/env xonsh
import os

if not os.path.exists('xxh'):
    git clone --depth 1 https://github.com/xonssh/xxh

docker build . -t xonssh/xxh-tests
docker-compose up -d

print('Sleep 3 sec')
sleep 3

print('-'*70)
print('RUN TESTS')
print('-'*70)
docker exec xxh-tests_tatooine_1 xonsh /xxh-tests/tests/tests.xsh