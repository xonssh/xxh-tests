#!/usr/bin/env xonsh

def check(name, cmd_result, expected_result):
    cmd_result = cmd_result.strip()
    if cmd_result != expected_result:
        raise Exception(f"{name} error: {cmd_result} != {expected_result}")
    print(f'{name}... OK')

print('Run xxh tests')

ssh_opts = ["-o", "StrictHostKeyChecking=accept-new", "-o", "LogLevel=QUIET"]

check(
    'Connect to ahchto using ssh',
    $(ssh @(ssh_opts) -i /xxh-tests/keys/id_rsa root@hoth "echo R2D2"),
    'R2D2'
)

print('DONE')