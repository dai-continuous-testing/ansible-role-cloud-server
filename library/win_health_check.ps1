#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = 'Stop'

$params = Parse-Args $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false
$_remote_tmp = Get-AnsibleParam $params "_ansible_remote_tmp" -type "path" -default $env:TMP


$url = Get-AnsibleParam -obj $params -name "url" -type "str" -failifempty $true
$timeout = Get-AnsibleParam -obj $params -name "timeout" -type "int" -default 10
$expected_status = Get-AnsibleParam -obj $params -name "expected_status" -type "int" -default 200
$max_retries = Get-AnsibleParam -obj $params -name "max_retries" -type "int" -default 10
$initial_delay = Get-AnsibleParam -obj $params -name "initial_delay" -type "int" -default 0
$delay_between_tries = Get-AnsibleParam -obj $params -name "delay_between_tries" -type "int" -default 5

# $headers = Get-AnsibleParam -obj $params -name "headers" -type "dict" -default @{}
# $expected_regexp = Get-AnsibleParam -obj $params -name "expected_regexp" -type "str" -default @{}

Function Request-Url($url, $timeout, $expected_status) {

    $response = try { 
        Invoke-WebRequest `
            -Uri $url `
            -ErrorAction Stop `
            -UseBasicParsing `
            -Method 'GET' `
            -TimeoutSec $timeout
    } catch [System.Net.WebException] { 
    }    

    if ($response.StatusCode -eq $expected_status) {
        return @{
            msg = "Success: $($response.StatusCode) = $($expected_status)"
            success = $true
        }
    } 
    else {
        return @{
            msg = "Result is $($response.StatusCode)"
            success = $false
        }
    }
}

$result = @{
    changed = $false
    success = $false
    url = $url
    failed_attempts = 0
    msg = ""
}

Start-Sleep -s $initial_delay

For ($i=0; $i -lt $max_retries; $i++) {

    $res = Request-Url -url $url -timeout $timeout -expected_status $expected_status
    
    $result.success = $res.success
    $result.msg = $res.msg

    if ($result.success) {
        Exit-Json -obj $result
    } else {
        $result.failed_attempts = $i + 1
    }

    Start-Sleep -s $delay_between_tries
}

Fail-Json -obj $result
