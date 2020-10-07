#!/bin/bash
####
# This script does the following:
# - Collects information from end user about the installation environment including IP addresses and FQDN
# - Generates a temporary certificate with IP and DNS names for https access
# - Updates the import.json file with proper values for the host and cluster where it will be installed.
# - Add correct values to configuration files from Elastic, Kibana and Metricbeat
# - Start the Docker stack

set -o errexit
set -o nounset

NOCOLOR='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'

echo
echo -e ${GREEN}Please provide the Docker Host system IP${NOCOLOR}
echo

read -p 'Docker/Kibana Host IP or FQDN: ' dockerhostip

echo
echo -e ${GREEN}Please provide the Docker Host / Kibana Host FQDN that Kibana Will be accessed on.${NOCOLOR}
echo

read -p 'Kibana FQDN (eg. kibana.linview.io): ' kibanafqdn
read -p 'Kibana Port (If you have not updated this in docker-compose, enter 5601): ' kibanaport
read -s -p 'Kibana Password: ' kibanapass

echo
echo -e ${GREEN}Please provide the LINSTOR Controller IP or FQDN and Port that the LINSTOR API will be accessed on.${NOCOLOR}
echo

read -p 'LINSTOR Protocol (http or https): ' linstorprotocol
read -p 'LINSTOR Controller IP or FQDN: ' linstorhost
read -p 'LINSTOR Port (Enter 3370 if you did not modify the default port): ' linstorport

# Copy example Kibana import variables to new file with Linstor Controller name
cp ./import/linview_kibana_example.ndjson ./import/$linstorhost-linview-kibana.ndjson

# Replace variables in Kibana import file with proper provided values
sed -i -e "s/\DOCKER_HOST_FQDN/$kibanafqdn/g" ./import/$linstorhost-linview-kibana.ndjson

# Update the Kibana config with the user provided username and password
cp ./emk/kibana/config/kibana.yml ./emk/kibana/config/kibana-$(date +"%Y%m%dT%H%M").yml.orig
sed -i -e "s/\KIBANAPASS/$kibanapass/g" ./emk/kibana/config/kibana.yml

sed -i -e "s/\LINSTORPROTOCOL/$linstorprotocol/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i -e "s/\LINSTOR_CONTROLLER_FQDN/$linstorhost/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i -e "s/\LINSTORPORT/$linstorport/g" ./import/$linstorhost-linview-kibana.ndjson

# Replace LINSTOR host in .env for Kibana setup
cp ./emk/.env ./emk/.env--$(date +"%Y%m%dT%H%M").orig
sed -i -e "s/\LINSTORHOST/$linstorhost/g" ./emk/.env
sed -i -e "s/\LINSTORPORT/$linstorport/g" ./emk/.env

#Update Elastic/Kibana password for Elastic
sed -i -e "s/\ELASTICPW/$kibanapass/g" ./emk/.env

#Update Kibana FQDN for NGINX
sed -i -e "s/\KIBANAFQDN/$kibanafqdn/g" ./emk/.env

#Update Elastic/Kibana password for Metricbeat
sed -i -e "s/\KIBANAPASS/$kibanapass/g" ./emk/metricbeat/config/metricbeat.yml



echo
echo -e ${GREEN}Thanks! You can now create a ConfigMap from the Import JSON file as mentioned in the Helm Install README${NOCOLOR}
echo
