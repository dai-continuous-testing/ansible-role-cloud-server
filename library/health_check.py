#!/usr/bin/python

import re
import time
import urllib.error
import urllib.request
import socket

from ansible.module_utils.basic import AnsibleModule

def check_server_status(url, headers, expected_status, timeout, expected_regexp):
    try:
        req = urllib.request.Request(url, headers=headers)
        resp = urllib.request.urlopen(req, timeout=timeout)
    
    except urllib.error.HTTPError as e:
        
        if e.code == expected_status:
            return True, 'OK'
        else:
            return False, 'Expected status %d, actual: %d' % (
                expected_status, resp.getcode())
        
    except (urllib.error.URLError, socket.error) as e:
        return False, str(e)

    if resp.getcode() != expected_status:
        return False, 'Expected status %d, actual: %d' % (
            expected_status, resp.getcode())

    content = resp.read()
    resp.close()

    if expected_regexp and not re.match(expected_regexp, content):
        return False, 'Content did not match expected regexp.'

    return True, 'OK'

def main():
    
    module_args = dict(
        url = dict(required=True),
        headers = dict(required=False, type='dict', default=None),
        initial_delay = dict(required=False, type='int', default=0),
        delay_between_tries = dict(required=False, type='int', default=5),
        max_retries = dict(required=False, type='int', default=10),
        timeout = dict(request=False, type='int', default=10),
        expected_status = dict(request=False, type='int', default=200),
        expected_regexp = dict(request=False, default=None)
    )
    
    module = AnsibleModule(
        argument_spec=module_args
    )

    url = module.params['url']
    headers = module.params['headers'] or {}
    initial_delay = module.params['initial_delay']
    delay_between_tries = module.params['delay_between_tries']
    max_retries = module.params['max_retries']
    timeout = module.params['timeout']
    expected_status = module.params['expected_status']
    expected_regexp = module.params['expected_regexp']

    time.sleep(initial_delay)
    
    for attempt in range(max_retries):
        
        if attempt != 0:
            time.sleep(delay_between_tries)
        
        success, info = check_server_status(
                url=url, 
                headers=headers, 
                timeout=timeout,
                expected_status=expected_status,
                expected_regexp=expected_regexp)
        
        if success:
            module.exit_json(failed_attempts=attempt)
    
    else:
        module.fail_json(msg='Maximum attempts reached: ' + info,
                         failed_attempts=attempt)

if __name__ == '__main__':
    main()
