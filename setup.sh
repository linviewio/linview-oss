#!/bin/bash
####
# This script does the following:
# - Updates the import.json file with proper values for the host and cluster where it will be installed.
# - 

NOCOLOR='\033[0m'
GREEN='\033[0;32m'

echo
echo -e ${GREEN}Please provide the Docker Host / Kibana Host IP or FQDN and Port that Kibana Will be accessed on.${NOCOLOR}
echo

read -p 'Protocol/Kibana (http or https): ' kibanaprotocol
read -p 'Docker/Kibana Host IP or FQDN: ' kibanahost
read -p 'Kibana Port: ' kibanaport
read -p 'Kibana Username: ' kibanauser
read -s -p 'Kibana Password: ' kibanapass


echo
echo -e ${GREEN}Please provide the LINSTOR Controller IP or FQDN and Port that the LINSTOR API will be accessed on.${NOCOLOR}
echo

read -p 'LINSTOR Protocol (http or https): ' linstorprotocol
read -p 'LINSTOR Controller IP or FQDN: ' linstorhost
read -p 'LINSTOR Port: ' linstorport

# Copy example Kibana import variables to new file with Linstor Controller name
cp ./import/linview_kibana_example.ndjson ./import/$linstorhost-linview-kibana.ndjson

# Replace variables in Kibana import file with proper provided values
sed -i "s/\KIBANAPROTOCOL/$kibanaprotocol/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i "s/\KIBANAHOST/$kibanahost/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i "s/\KIBANAPORT/$kibanaport/g" ./import/$linstorhost-linview-kibana.ndjson

# Update the Kibana config with the user provided username and password
cp ./emk/kibana/config/kibana.yml ./emk/kibana/config/kibana.yml.orig
sed -i "s/\KIBANAUSER/$kibanauser/g" ./emk/kibana/config/kibana.yml
sed -i "s/\KIBANAPASS/$kibanapass/g" ./emk/kibana/config/kibana.yml

sed -i "s/\LINSTORPROTOCOL/$linstorprotocol/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i "s/\LINSTORHOST/$linstorhost/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i "s/\LINSTORPORT/$linstorport/g" ./import/$linstorhost-linview-kibana.ndjson

# Replace LINSTOR host in .env for Kibana setup
cp ./emk/.env ./emk/.env.orig
sed -i "s/\LINSTORHOST/$linstorhost/g" ./emk/.env
sed -i "s/\LINSTORPORT/$linstorport/g" ./emk/.env

# Run docker containers
cd ./emk
docker-compose up -d
