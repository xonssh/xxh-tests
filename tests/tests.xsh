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
    print(f'OK {name}')

ssh_opts = ["-o", "StrictHostKeyChecking=accept-new", "-o", "LogLevel=QUIET"]

check(
    'Connect to Hoth using ssh',
    $(ssh @(ssh_opts) -i /xxh-tests/keys/id_rsa root@hoth "echo R2D2"),
    'R2D2'
)

check(
    'Install xxh to Hoth',
    $(xxh/xxh -i /xxh-tests/keys/id_rsa hoth +if +he /root/.xxh/settings.py),
    "{'XXH_VERSION': '%s', 'XXH_HOME': '/root/.xxh', 'PIP_TARGET': '/root/.xxh/pip', 'PYTHONPATH': '/root/.xxh/pip'}" % xxh_version
)

if not os.path.exists(os.path.abspath('~/.xxh/plugins/xxh-plugin-pipe-liner')):
    git clone --quiet --depth 1 https://github.com/xonssh/xxh-plugin-pipe-liner ~/.xxh/plugins/xxh-plugin-pipe-liner

check(
    'Test xxh-plugin-pipe-liner',
    $(xxh/xxh -i /xxh-tests/keys/id_rsa hoth +if +he /xxh-tests/tests/test_plugin_pipeliner.xsh),
    "dog\nlive"
)


print('DONE')