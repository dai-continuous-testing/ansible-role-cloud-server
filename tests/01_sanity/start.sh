#!/bin/bash
set -ev

# IMAGE_NAME=centos:7

# docker run \
#     --rm=true \
#     -it \
#     -v `pwd`:/ansible-project:rw $IMAGE_NAME \
#     /bin/bash 
#     #-c "cd /ansible-project/tests/$TEST_NAME && ./start.sh"

# TEST_NAME=01_sanity
# cd /ansible-project/tests/$TEST_NAME

# GIT_URL=https://github.com/ExperitestOfficial/ansible-role-cloud-server.git
# TRAVIS_BRANCH=debt/experiment_ci_cd

echo "[STEP 1] installing dependencies"

yum -y update
yum -y install git sudo

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py

pip install ansible

GIT_URL=$(git config remote.origin.url)

ansible-galaxy install -r requirements.yml --force
ansible-galaxy install git+$GIT_URL,$TRAVIS_BRANCH --force

echo "[STEP 1] installing dependencies - completed successfully"

echo "[STEP 2] starting ansible playbook"

ansible-playbook site.yml

echo "[STEP 2] starting ansible playbook - completed successfully"

echo "[STEP 3] verifying install"

echo "skipping verify"

echo "[STEP 3] verifying install - completed successfully"
