#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    echo "osx"
    # Install some custom requirements on macOS
    # e.g. brew install pyenv-virtualenv

    case "${TOXENV}" in
        py32)
            # Install some custom Python 3.2 requirements on macOS
            ;;
        py33)
            # Install some custom Python 3.3 requirements on macOS
            ;;
    esac
fi

# if [ "$TRAVIS_OS_NAME" == "windows" ]; then
#     echo "windows"
# fi

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    echo "linux"

    sudo sh -c 'echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    sudo apt-get update
    sudo apt-get install ansible -y

    sudo pip install requests[security]

fi
