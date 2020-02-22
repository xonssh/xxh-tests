#!/usr/bin/env xonsh

import sys, os

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')  )
from xxh.xonssh_xxh.settings import global_settings

xxh_version=global_settings['XXH_VERSION']

def check(name, cmd_result, expected_result):
    cmd_result = cmd_result.strip()

    if '\x07' in cmd_result:
        cmd_result = cmd_result.split('\x07')[1]

    expected_result = expected_result.strip()
    if cmd_result != expected_result:
        raise Exception(f"{name} error: {repr(expected_result)} != {repr(cmd_result)}")
    print(f'{name} OK')

ssh_opts = ["-o", "StrictHostKeyChecking=accept-new", "-o", "LogLevel=QUIET"]

for host in ['ubuntu_without_fuse', 'ubuntu_with_fuse']:
    print(f'\nHOST: {host}')
    user_host = 'root@' + host
    check(
        f'Connect to {host} using ssh',
        $(ssh @(ssh_opts) -i /xxh-dev/keys/id_rsa @(user_host) "echo Test!"),
        'Test!'
    )

    check(
        f'Install xxh to {host}',
        $(xxh/xxh -i /xxh-dev/keys/id_rsa @(user_host) +if +he /root/.xxh/settings.py),
        "{'XXH_VERSION': '%s', 'XXH_HOME': '/root/.xxh', 'PIP_TARGET': '/root/.xxh/pip', 'PYTHONPATH': '/root/.xxh/pip'}" % xxh_version
    )

    if not os.path.exists(os.path.abspath('/root/.xxh/plugins/xxh-plugin-pipe-liner')):
        git clone --quiet --depth 1 https://github.com/xonssh/xxh-plugin-pipe-liner /root/.xxh/plugins/xxh-plugin-pipe-liner

    check(
        f'Test xxh-plugin-pipe-liner on {host}',
        $(xxh/xxh -i /xxh-dev/keys/id_rsa @(user_host) +if +he /xxh-dev/tests/test_plugin_pipeliner.xsh),
        "1234\n5678"
    )


print('\nDONE')