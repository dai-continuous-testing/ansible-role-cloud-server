
# Example usage

to use the example:
- cd into the example folder

- install dependencies \
  *ansible-galaxy install -r requirements.yml*

- run the playbook \
  *ansible-playbook site.yml -i inventory.ini -k --ask-sudo-pass*

- put the admin password and confirm

## Known issues

## mac runner
when running ansible scripts from mac to winrm.\
actions are required:
- pip install "pywinrm>=0.2.2"
- *export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES*

## mac target

### make sure to add:
    export PATH="/usr/local/bin:$PATH" >> ~/.bashrc

## windows target
run the bootstrap.ps1 script in the target machine\
NOTE:\
*update username and password first*


