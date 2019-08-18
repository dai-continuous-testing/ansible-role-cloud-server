Experitest - Cloud Server ansible role
=========

[![Build Status](https://travis-ci.org/ExperitestOfficial/ansible-role-cloud-server.svg)](https://travis-ci.org/ExperitestOfficial/ansible-role-cloud-server)

This role will install \ uninstall cloud server for windows and mac os hosts

Requirements
------------

This role assumes that you have java 8 installed on the instance
Supports windows and mac os hosts only.

Role Variables
--------------

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| state | should the application be present or absent | present, absent | present | no |
| app_version | application version to install | string | 12.7.6640 | no |
| server_port | port number for the server | number | 8080 | no |
| extra_application_properties | additional props to be override in application.properties file | dict | {} | no |
| extra_xml_conf | extand xml configuration | dict | {} | no |
| extra_java_options | extand java options | array of strings | [] | no |
| license_type | license type | trial \ sentinel \ license4j | trial | no |
| license4j_file_content | license file content | string |  | when license_type is license4j |
| db_connection_string | connection string to postgres | string | jdbc:postgresql://localhost:5432/cloudserver | no |
| db_username | username for db connection | string | postgres | no |
| db_password | password for db connection | string |  | no |
| installation_folder | the folder in which the applcation will be installed | string | for mac: /Applications/Experitest/cloud-server-version <br> for windows: C:\\Experitest\\cloud-server-version  | no |
| jmx_port | port number for jmx inspection | number | 51234 | no |
| custom_download_url | custom url to download the installation from (zip format) | string |  | no |
| start_after_install | should application start after installation is completed | boolean | True | no |
| clear_temp_folder | remove temp folder after installation | boolean | False | no |
| clear_before_install | removing old installation before installing new version | boolean | False | no |
| cloud_backup_dir | the default path for the cloud backups | string | for mac: /Library/Application Support/Experitest/cloud-server <br> for windows: C:\\ProgramData\\cloud-server  | no |

Example Playbook
----------------
### [see working example](/example)
