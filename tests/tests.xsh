#!/usr/bin/env xonsh

import sys, os, argparse, re

sys.path.append( str(fp'{__file__}'.parent.parent.parent) )
from xxh.xonssh_xxh.settings import global_settings

xxh_version=global_settings['XXH_VERSION']
verbose = False
vverbose = False
not_interactive = False

def cmd_str(c):
    return c

def check(name, cmd, expected_result):
    print('TEST: '+name, end='...')
    cmd = cmd.strip()
    cmd_result = $(bash -c @(cmd)).strip()
    cmd_result = re.sub('\x1b]0;.*\x07','', cmd_result)
    cmd_result = re.sub(r'\x1b\[\d+m','', cmd_result)
    cmd_result = re.sub(r'\x1b\[\d+;\d+;\d+m','', cmd_result)

    expected_result = expected_result.strip()
    if cmd_result != expected_result or vverbose:
        print('\n',end='')
        if verbose:
            print(f'CMD: {cmd}')
        print(f"OUTPUT {repr(cmd_result)}\nEXPECT {repr(expected_result)} ")

        if cmd_result != expected_result:
            print('ERROR!')
            if not not_interactive:
                cmdv = cmd.replace('xxh ', 'xxh +v ')
                yn = input(f'Run verbose? [Y/n]: %s' % cmdv)
                if yn.lower().strip() in ['y','']:
                    bash -c @(cmdv)
            sys.exit(1)

    print('OK')

if __name__ == '__main__':

    argp = argparse.ArgumentParser(description=f"xde test")
    argp.add_argument('-r', '--remove', default=False, action='store_true', help="Remove xxh home before tests.")
    argp.add_argument('-ni', '--not-interactive', default=False, action='store_true', help="Not interactive mode.")
    argp.add_argument('-v', '--verbose', default=False, action='store_true', help="Verbose mode.")
    argp.add_argument('-vv', '--vverbose', default=False, action='store_true', help="Super verbose mode.")
    argp.add_argument('-H', '--hosts', default=[], help="Comma separated hosts list")
    argp.add_argument('-sr', '--skip-repos-update', default=False, action='store_true', help="Skip repos update before test running.")
    argp.usage = argp.format_usage().replace('usage: tests.xsh', 'xde test')
    opt = argp.parse_args()
    verbose = opt.verbose
    not_interactive = opt.not_interactive
    if opt.vverbose:
        verbose = vverbose = True

    git_verbose_arg = [] if verbose else ['-q']

    if opt.hosts:
        opt.hosts = opt.hosts.split(',')

    hosts = {}
    hosts['ubuntu_k'] = {
        'user':'root',
        'home':'/root',
        'ssh_auth': ['-i', '/xxh/xxh-dev/keys/id_rsa'],
        'xxh_auth': ['-i', '/xxh/xxh-dev/keys/id_rsa'],
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

    rm -rf /root/.ssh/known_hosts

    if opt.remove:
        print('Remove start:/root/.xxh')
        rm -rf /root/.xxh

    if not p'/root/.xxh/xxh/shells'.exists():
        print('First time of executing tests takes time because of downloading files. Take a gulp of water or a few :)')

    mkdir -p /root/.xxh/xxh/plugins /root/.xxh/xxh/shells

    print('Prepare repos (to avoid full update use --skip-repos-update)')

    xxh_shell_repos = {}
    xxh_shell_repos['xxh-shell-xonsh-appimage'] = {
        'shells': ['xxh-shell-xonsh-appimage'],
        'plugins': ['xxh-plugin-xonsh-pipe-liner', 'xxh-plugin-xonsh-theme-bar', 'xxh-plugin-xonsh-autojump']
    }


    for xxh_shell, install_repos in xxh_shell_repos.items():
        for rtype, repos  in install_repos.items():
            for repo in repos:
                repo_dir = fp'/root/.xxh/xxh/{rtype}/{repo}'
                build_file = repo_dir/ 'build.xsh'
                build_dir = repo_dir / 'build'
                if not pf'/xxh/{repo}'.exists():
                    print(f'Repo {repo}: git clone to /xxh/{repo}')
                    git clone @(git_verbose_arg) --depth 1 https://github.com/xxh/@(repo) /xxh/@(repo)

                if repo_dir.exists() and opt.skip_repos_update:
                    print(f'Repo {repo}: skip replacing from /xxh/{repo}')
                else:
                    print(f'Repo {repo}: replaced from /xxh/{repo}. Do not forget to pull from master!')
                    rm -rf /root/.xxh/xxh/@(rtype)/@(repo)
                    cp -r /xxh/@(repo) /root/.xxh/xxh/@(rtype)/

                if build_file.exists():
                    if build_dir.exists() and opt.skip_repos_update:
                        print(f'Repo {repo}: skip building')
                    else:
                        print(f'Repo {repo}: build')
                        rm -rf @(build_dir)
                        @(build_file) 1> /dev/null 2> /dev/null
                else:
                    print(f"Build file is not exists: {build_file}")
                    sys.exit(1)

    xxh_args = []

    xxh = '/xxh/xxh/xxh'
    ssh_opts = ["-o", "StrictHostKeyChecking=accept-new", "-o", "LogLevel=QUIET"]

    for host, h in hosts.items():
        if opt.hosts and host not in opt.hosts:
            continue

        print(f'\n[{host}]')
        user = h['user']
        server = user + '@' + host
        host_home = h['home']

        check(
            f'Remove {server}:~/.xxh',
            $(echo @(h['sshpass']) ssh @(h['ssh_auth']) @(ssh_opts) @(server) "rm -rf ~/.xxh"),
            ''
        )

        check(
            'Test connect using ssh',
            $(echo @(h['sshpass']) ssh @(h['ssh_auth']) @(ssh_opts) @(server) "echo Test!"),
            'Test!'
        )

        check(
            'Test install xxh',
            $(echo @(xxh) @(h['xxh_auth']) @(server) +iff +he @(f"{host_home}/.xxh/xxh/package/settings.py") @(xxh_args) ),
            "{{'XXH_VERSION': '{xxh_version}', 'XXH_HOME': '{host_home}/.xxh', 'PIP_TARGET': '{host_home}/.xxh/pip', 'PYTHONPATH': '{host_home}/.xxh/pip'}}".format(xxh_version=xxh_version, host_home=host_home)
        )

        check(
            'Test AppImage extraction on the host',
            $(echo @(h['sshpass']) ssh @(h['ssh_auth']) @(ssh_opts) @(server) @(f"[ -d {host_home}/.xxh/xxh/shells/xxh-shell-xonsh-appimage/build/xonsh-squashfs ] && echo 'extracted' ||echo 'not_extracted'") ),
            'not_extracted' if 'f' in host.split('_')[-1] else 'extracted'
        )

        check(
            'Test python',
            $(echo @(xxh) @(h['xxh_auth']) @(server) +he /xxh/xxh-dev/tests/xonsh/test_python.xsh @(xxh_args) ),
            "Python 3.8"
        )

        check(
            'Test pip upgrade',
            $(echo @(xxh) @(h['xxh_auth']) @(server) +he /xxh/xxh-dev/tests/xonsh/test_pip_upgrade.xsh @(xxh_args)),
            ""
        )
        check(
            'Test pip package install',
            $(echo @(xxh) @(h['xxh_auth']) @(server) +he /xxh/xxh-dev/tests/xonsh/test_pip_package_install.xsh @(xxh_args)),
            ""
        )
        check(
            'Test pip package import',
            $(echo @(xxh) @(h['xxh_auth']) @(server) +he /xxh/xxh-dev/tests/xonsh/test_pip_package_import.xsh @(xxh_args)),
            "[[1], [2], [3]]"
        )

        # Xontribs

        check(
            'Test xontrib',
            $(echo @(xxh) @(h['xxh_auth']) @(server) +iff +he /xxh/xxh-dev/tests/xonsh/test_xontrib.xsh @(xxh_args)),
            "autojump  installed      loaded\nschedule  installed      loaded"
        )

        check(
            'Test xxh plugins',
            $(echo @(xxh) @(h['xxh_auth']) @(server) +iff +he /xxh/xxh-dev/tests/xonsh/test_plugins.xsh @(xxh_args)),
            "1234\n5678\n\n{bar}\n{WHITE}{prompt_end}{NO_COLOR}"
        )

    print('\nDONE')
