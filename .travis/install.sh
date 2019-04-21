#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    echo "osx"

    brew cask install docker
    /Applications/Docker.app/Contents/MacOS/Docker &
    
    sudo pip install ansible

    while (! docker stats --no-stream ); do
        # Docker takes a few seconds to initialize
        echo "Waiting for Docker to launch..."
        sleep 1
    done

    docker ps -a
    docker --version
    docker run hello-world
    
fi

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    echo "linux"

    sudo sh -c 'echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    sudo apt-get update
    sudo apt-get install ansible -y

    sudo pip install requests[security]

fi
