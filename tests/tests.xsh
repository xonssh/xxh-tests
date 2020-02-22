#!/usr/bin/env xonsh

import sys, os

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')  )
from xxh.xonssh_xxh.settings import global_settings

xxh_version=global_settings['XXH_VERSION']

def check(name, cmd, expected_result):
    print('  '+name, end='...')
    cmd_result = cmd().strip()

    if '\x07' in cmd_result:
        cmd_result = cmd_result.split('\x07')[1]

    expected_result = expected_result.strip()
    if cmd_result != expected_result:
        print(f" ERROR: {repr(expected_result)} != {repr(cmd_result)}")
        sys.exit(1)

    print(' OK')

ssh_opts = ["-o", "StrictHostKeyChecking=accept-new", "-o", "LogLevel=QUIET"]

tests={
    'Connect to host using ssh': lambda: $(ssh @(ssh_opts) -i /xxh-dev/keys/id_rsa @(server) "echo Test!")
}

for host in ['ubuntu_without_fuse', 'ubuntu_with_fuse']:
    print(f'\n[{host}]')
    server = 'root@' + host
    check(
        f'Connect to {host} using ssh',
        lambda:$(ssh @(ssh_opts) -i /xxh-dev/keys/id_rsa @(server) "echo Test!"),
        'Test!'
    )

    check(
        'Test install xxh',
        lambda:$(xxh/xxh -i /xxh-dev/keys/id_rsa @(server) +if +he /root/.xxh/settings.py),
        "{'XXH_VERSION': '%s', 'XXH_HOME': '/root/.xxh', 'PIP_TARGET': '/root/.xxh/pip', 'PYTHONPATH': '/root/.xxh/pip'}" % xxh_version
    )

    check(
        'Test python',
        lambda:$(xxh/xxh -i /xxh-dev/keys/id_rsa @(server) +if +he /xxh-dev/tests/test_python.xsh),
        "Python 3.8"
    )

    check(
        'Test pip upgrade',
        lambda:$(xxh/xxh -i /xxh-dev/keys/id_rsa @(server) +if +he /xxh-dev/tests/test_pip_upgrade.xsh),
        ""
    )
    check(
        'Test pip package install',
        lambda:$(xxh/xxh -i /xxh-dev/keys/id_rsa @(server) +he /xxh-dev/tests/test_pip_package_install.xsh),
        ""
    )
    check(
        'Test pip package import',
        lambda:$(xxh/xxh -i /xxh-dev/keys/id_rsa @(server) +he /xxh-dev/tests/test_pip_package_import.xsh),
        "[[1], [2], [3]]"
    )

    if not os.path.exists(os.path.abspath('/root/.xxh/plugins/xxh-plugin-pipe-liner')):
        git clone --quiet --depth 1 https://github.com/xonssh/xxh-plugin-pipe-liner /root/.xxh/plugins/xxh-plugin-pipe-liner

    check(
        'Test xxh-plugin-pipe-liner',
        lambda:$(xxh/xxh -i /xxh-dev/keys/id_rsa @(server) +if +he /xxh-dev/tests/test_plugin_pipeliner.xsh),
        "1234\n5678"
    )

print('\nDONE')
