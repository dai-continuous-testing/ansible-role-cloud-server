#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    echo "osx"

    brew cask install docker
    open --background -a Docker
    
    sudo pip install ansible

    DOCKER_BIN=/Applications/Docker.app/Contents/Resources/bin/docker

    while (! $DOCKER_BIN system info > /dev/null 2>&1 ); do
        echo "Waiting for Docker to launch..."
        sleep 1
    done

    $DOCKER_BIN ps -a
    $DOCKER_BIN --version
    $DOCKER_BIN run hello-world

    $DOCKER_BIN run -d -p 5432:5432 -e 'POSTGRES_PASSWORD=secretpassword' -e 'POSTGRES_DB=cloudserver' postgres:10

fi

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    echo "linux"

    sudo sh -c 'echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    sudo apt-get update
    sudo apt-get install ansible -y

    sudo pip install requests[security]

    docker run -d -p 5432:5432 -e 'POSTGRES_PASSWORD=secretpassword' -e 'POSTGRES_DB=cloudserver' postgres:10

fi
