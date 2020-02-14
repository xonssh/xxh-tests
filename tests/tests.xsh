#!/usr/bin/env xonsh

import sys, os

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')  )
from xxh.xonssh_xxh.settings import global_settings

xxh_version=global_settings['XXH_VERSION']

def check(name, cmd_result, expected_result):
    cmd_result = cmd_result.strip()
    expected_result = expected_result.strip()
    if cmd_result != expected_result:
        raise Exception(f"{name} error: {repr(cmd_result)} != {repr(expected_result)}")
    print(f'{name}... OK')

print('Run xxh tests')

ssh_opts = ["-o", "StrictHostKeyChecking=accept-new", "-o", "LogLevel=QUIET"]

check(
    'Connect to Hoth using ssh',
    $(ssh @(ssh_opts) -i /xxh-tests/keys/id_rsa root@hoth "echo R2D2"),
    'R2D2'
)

check(
    'Install xxh to Hoth',
    $(xxh/xxh -i /xxh-tests/keys/id_rsa hoth +if +he /root/.xxh/settings.xsh),
    "{'XXH_VERSION': '%s', 'XXH_HOME': '/root/.xxh', 'PIP_TARGET': '/root/.xxh/pip', 'PYTHONPATH': ['/root/.xxh/pip']}" % xxh_version
)

print('DONE')