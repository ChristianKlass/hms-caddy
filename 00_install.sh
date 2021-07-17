#!/bin/bash

# this script assumes you have set the environment variables as indicated in README.md, and that you have docker-compose installed.

echo "\n######################################################"
echo "Starting Caddy"
echo "-----"
docker-compose -f ./docker-compose.yml up -d

echo "######################################################"
echo "Creating the storage containers"
echo "-----"
docker-compose -f ./storage/docker-compose.yml up -d

echo "\n######################################################"
echo "Creating the Monitoring apps"
echo "-----"
docker-compose -f ./monitor/docker-compose.yml up -d

echo "\n######################################################"
echo "Creating the HMS apps"
echo "-----"
docker-compose -f ./hms/docker-compose.yml up -d

echo "\n######################################################"
echo "\nCaddy"
echo "---------------"
docker-compose -f ./docker-compose.yml ps

echo "\nMedia Server"
echo "---------------"
docker-compose -f ./hms/docker-compose.yml ps

echo "\nStorage"
echo "---------------"
docker-compose -f ./storage/docker-compose.yml ps

echo "\nMonitoring"
echo "---------------"
docker-compose -f ./monitor/docker-compose.yml ps
