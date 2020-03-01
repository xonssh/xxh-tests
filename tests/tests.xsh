#!/usr/bin/env xonsh

import sys, os, argparse, re

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')  )
from xxh.xonssh_xxh.settings import global_settings

xxh_version=global_settings['XXH_VERSION']
verbose = False
vverbose = False

def cmd_str(c):
    return c

def check(name, cmd, expected_result):
    print('TEST: '+name, end='...')
    cmd = cmd.strip()
    cmd_result = $(bash -c @(cmd)).strip()
    cmd_result = re.sub('\x1b]0;.*\x07','', cmd_result)
    cmd_result = re.sub(r'\x1b\[\d+m','', cmd_result)

    expected_result = expected_result.strip()
    if cmd_result != expected_result or vverbose:
        print('\n',end='')
        if verbose:
            print(f'CMD: {cmd}')
        print(f"OUTPUT {repr(cmd_result)}\nEXPECT {repr(expected_result)} ")

        if cmd_result != expected_result:
            print('ERROR!')
            cmdv = cmd.replace('xxh ', 'xxh +v ')
            yn = input(f'Run again verbose? [Y/n]: %s' % cmdv)
            if yn.lower().strip() in ['y','']:
                bash -c @(cmdv)
            sys.exit(1)

    print('OK')

if __name__ == '__main__':

    argp = argparse.ArgumentParser(description=f"xde test")
    argp.add_argument('-v', '--verbose', default=False, action='store_true', help="Verbose mode.")
    argp.add_argument('-vv', '--vverbose', default=False, action='store_true', help="Super verbose mode.")
    argp.add_argument('-H', '--hosts', default=[], help="Comma separated hosts list")
    argp.usage = argp.format_usage().replace('usage: tests.xsh', 'xde test')
    opt = argp.parse_args()
    verbose = opt.verbose
    if opt.vverbose:
        verbose = vverbose = True

    if opt.hosts:
        opt.hosts = opt.hosts.split(',')

    hosts = {}
    hosts['ubuntu_k'] = {
        'user':'root',
        'home':'/root',
        'ssh_auth': ['-i', '/xxh-dev/keys/id_rsa'],
        'xxh_auth': ['-i', '/xxh-dev/keys/id_rsa'],
        'sshpass': []
    }
    hosts['ubuntu_kf'] = hosts['ubuntu_k']
    hosts['arch_p'] = {
        'user':'docker',
        'home':'/home/docker',
        'ssh_auth':[],
        'xxh_auth':['+P','docker'],
        'sshpass': ['sshpass', '-p', 'docker']
    }

    rm -rf ~/.ssh/known_hosts

    ssh_opts = ["-o", "StrictHostKeyChecking=accept-new", "-o", "LogLevel=QUIET"]
    for host, h in hosts.items():
        if opt.hosts and host not in opt.hosts:
            continue

        print(f'\n[{host}]')
        user = h['user']
        server = user + '@' + host
        host_home = h['home']

        check(
            'Test connect using ssh',
            $(echo @(h['sshpass']) ssh @(h['ssh_auth']) @(ssh_opts) @(server) "echo Test!"),
            'Test!'
        )

        check(
            'Test install xxh',
            $(echo xxh/xxh @(h['xxh_auth']) @(server) +if +he @(f"{host_home}/.xxh/settings.py") ),
            "{{'XXH_VERSION': '{xxh_version}', 'XXH_HOME': '{host_home}/.xxh', 'PIP_TARGET': '{host_home}/.xxh/pip', 'PYTHONPATH': '{host_home}/.xxh/pip'}}".format(xxh_version=xxh_version, host_home=host_home)
        )

        check(
            'Test AppImage extraction on the host',
            $(echo @(h['sshpass']) ssh @(h['ssh_auth']) @(ssh_opts) @(server) @(f"[ -d {host_home}/.xxh/xonsh-squashfs ] && echo 'extracted' ||echo 'not_extracted'") ),
            'not_extracted' if 'f' in host.split('_')[-1] else 'extracted'
        )

        check(
            'Test python',
            $(echo xxh/xxh @(h['xxh_auth']) @(server) +he /xxh-dev/tests/test_python.xsh),
            "Python 3.8"
        )

        check(
            'Test pip upgrade',
            $(echo xxh/xxh @(h['xxh_auth']) @(server) +he /xxh-dev/tests/test_pip_upgrade.xsh),
            ""
        )
        check(
            'Test pip package install',
            $(echo xxh/xxh @(h['xxh_auth']) @(server) +he /xxh-dev/tests/test_pip_package_install.xsh),
            ""
        )
        check(
            'Test pip package import',
            $(echo xxh/xxh @(h['xxh_auth']) @(server) +he /xxh-dev/tests/test_pip_package_import.xsh),
            "[[1], [2], [3]]"
        )

        # Xontribs

        check(
            'Test xontrib autojump',
            $(echo xxh/xxh @(h['xxh_auth']) @(server) +if +he /xxh-dev/tests/test_xontrib.xsh),
            "autojump  installed      loaded\nschedule  installed      loaded"
        )

        # Plugins

        if not p'/root/.xxh/plugins/xxh-plugin-pipe-liner'.exists():
            git clone --quiet --depth 1 https://github.com/xonssh/xxh-plugin-pipe-liner /root/.xxh/plugins/xxh-plugin-pipe-liner

        check(
            'Test xxh-plugin-pipe-liner',
            $(echo xxh/xxh @(h['xxh_auth']) @(server) +if +he /xxh-dev/tests/test_plugin_pipeliner.xsh),
            "1234\n5678"
        )

    print('\nDONE')
