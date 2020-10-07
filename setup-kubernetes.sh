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
sed -i '' -e "s/\DOCKER_HOST_FQDN/$kibanafqdn/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i '' -e "s/\LINSTORPROTOCOL/$linstorprotocol/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i '' -e "s/\LINSTOR_CONTROLLER_FQDN/$linstorhost/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i '' -e "s/\LINSTORPORT/$linstorport/g" ./import/$linstorhost-linview-kibana.ndjson

echo
echo -e ${GREEN}Thanks! You can now create a ConfigMap from the Import JSON file as mentioned in the Helm Install README${NOCOLOR}
echo
