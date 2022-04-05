#!/bin/bash

PROJECT_DIR=$HOME/projects/hms-caddy/
LOG_FILE=update.log
D_COMPOSE=/usr/local/bin/docker-compose

cd $PROJECT_DIR

# redirect all output to a file
exec &>> $LOG_FILE

echo "Starting HMS Update - $(date +%Y%m%d-%T)" 
echo "##############################"
echo "Current Directory: $(pwd)"
echo "Logs in $(pwd)/$LOG_FILE"
echo "---------"
$D_COMPOSE pull 
$D_COMPOSE up -d
echo "---------"
$D_COMPOSE -f hms/docker-compose.yml pull
$D_COMPOSE -f hms/docker-compose.yml up -d --remove-orphans
echo "---------" 
$D_COMPOSE -f monitor/docker-compose.yml pull
$D_COMPOSE -f monitor/docker-compose.yml up -d --remove-orphans
echo "---------"
$D_COMPOSE -f storage/docker-compose.yml pull 
$D_COMPOSE -f storage/docker-compose.yml up -d --remove-orphans
echo "##############################" 
echo " "
