#!/usr/bin/env xonsh

def check(name, cmd_result, expected_result):
    cmd_result = cmd_result.strip()
    if cmd_result != expected_result:
        raise Exception(f"{name} error: {cmd_result} != {expected_result}")
    print(f'{name}... OK')

print('Run xxh tests')

check(
    'Connect to target_host using ssh',
    $(ssh -o "StrictHostKeyChecking=accept-new" -o "LogLevel=QUIET" -i /xxh-tests/keys/id_rsa -p 2222 snail@target_host "echo TEST"),
    'TEST'
)

print('DONE')