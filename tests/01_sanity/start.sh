#!/bin/bash
set -ev

echo "[STEP 1] installing dependencies"

yum -y update

yum -y install git

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py

pip install ansible


# GIT_URL=$(git remote get-url origin)

GIT_URL=$(git config remote.origin.url)

ansible-galaxy install -r requirements.yml --force
ansible-galaxy install git+$GIT_URL,$ --force

echo "[STEP 1] installing dependencies - completed successfully"

echo "[STEP 2] starting ansible playbook"

ansible-playbook site.yml

echo "[STEP 2] starting ansible playbook - completed successfully"

echo "[STEP 3] verifying install"

echo "skipping verify"

echo "[STEP 3] verifying install - completed successfully"
