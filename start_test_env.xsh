#!/usr/bin/env xonsh

git clone --depth 1 https://github.com/xonssh/xxh
docker build . -t xonssh/xxh-tests
docker-compose up -d
sleep 1

print('-'*60)
print('RUN TESTS')
print('-'*60)
docker exec xxh-tests_source_host_1 xonsh /xxh-tests/tests/source_tests.xsh