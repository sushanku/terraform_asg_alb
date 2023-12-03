#!/bin/bash

set -e, -u, -x, -o pipefail

sudo apt update -y

sudo apt install openjdk-17-jre-headless -y

sudo mkdir /opt/deployment
sudo mkdir /var/log/apps

sudo chown -R $USER:$USER /opt/deployment
sudo chown -R $USER:$USER /var/log/apps
