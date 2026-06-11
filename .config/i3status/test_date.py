#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import time
import subprocess

def get_date():
    return time.strftime("%A")  # 只改这一行

def get_main_output():
    result = subprocess.run(['~/.config/i3status/main'], capture_output=True, text=True,shell=True)
    return result.stdout



    
def print_line(message):
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    try:
        line = sys.stdin.readline().strip()
        if not line:
            sys.exit(3)
        return line
    except KeyboardInterrupt:
        sys.exit()

if __name__ == '__main__':
    print_line(read_line())
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)
        j.insert(0, {'full_text': get_date(), 'name': 'date'})
        main_output = get_main_output()
        j.insert(1, {'full_text': main_output, 'name': 'date'})
        print_line(prefix + json.dumps(j))
#        print_line(read_line()+'|'+get_date())
