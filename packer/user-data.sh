#!/bin/bash
nohup java -jar /opt/deployment/app.jar > /var/log/apps/app.log 2>&1 &
