#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    echo "osx"

    brew update 

    brew cask install docker
    /Applications/Docker.app/Contents/MacOS/Docker
    docker ps -a
    docker --version
    docker run hello-world
    

    sudo pip install ansible
fi

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    echo "linux"

    sudo sh -c 'echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    sudo apt-get update
    sudo apt-get install ansible -y

    sudo pip install requests[security]

fi
