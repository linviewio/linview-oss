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
echo -e ${GREEN}Please provide a wildcard domain name for internal cert generation.${NOCOLOR}
echo

read -p 'Wildcard domain for internal cert generation (eg. *.example.com): ' wildcarddomain

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

# Generate internal x509 certificates
mkdir ./emk/certs/
openssl req -x509 -nodes -days 365 -subj "/C=US/ST=DC/O=LINVIEW, Inc./CN=$wildcarddomain" -addext "subjectAltName=IP:$dockerhostip,DNS:$kibanafqdn" -newkey rsa:2048 -keyout ./emk/certs/shared.key -out ./emk/certs/shared.crt;

# Copy example Kibana import variables to new file with Linstor Controller name
cp ./import/linview_kibana_example.ndjson ./import/$linstorhost-linview-kibana.ndjson

# Replace variables in Kibana import file with proper provided values
sed -i "s/\DOCKER_HOST_FQDN/$kibanafqdn/g" ./import/$linstorhost-linview-kibana.ndjson

# Update the Kibana config with the user provided username and password
cp ./emk/kibana/config/kibana.yml ./emk/kibana/config/kibana-$(date +"%Y%m%dT%H%M").yml.orig
sed -i "s/\KIBANAPASS/$kibanapass/g" ./emk/kibana/config/kibana.yml

sed -i "s/\LINSTORPROTOCOL/$linstorprotocol/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i "s/\LINSTOR_CONTROLLER_FQDN/$linstorhost/g" ./import/$linstorhost-linview-kibana.ndjson
sed -i "s/\LINSTORPORT/$linstorport/g" ./import/$linstorhost-linview-kibana.ndjson

# Replace LINSTOR host in .env for Kibana setup
cp ./emk/.env ./emk/.env--$(date +"%Y%m%dT%H%M").orig
sed -i "s/\LINSTORHOST/$linstorhost/g" ./emk/.env
sed -i "s/\LINSTORPORT/$linstorport/g" ./emk/.env

#Update Elastic/Kibana password for Elastic
sed -i "s/\ELASTICPW/$kibanapass/g" ./emk/.env

#Update Kibana FQDN for NGINX
sed -i "s/\KIBANAFQDN/$kibanafqdn/g" ./emk/.env

#Update Elastic/Kibana password for Metricbeat
sed -i "s/\KIBANAPASS/$kibanapass/g" ./emk/metricbeat/config/metricbeat.yml

# Run docker containers
cd ./emk
docker-compose up -d

echo
echo -e ${GREEN}Please wait 5 minutes while Elastic and Kibana are configured.${NOCOLOR}
echo

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'
hour=0
min=5
sec=0
tput civis
echo -ne "${RED}"
        while [ $hour -ge 0 ]; do
                 while [ $min -ge 0 ]; do
                         while [ $sec -ge 0 ]; do
                                 if [ "$hour" -eq "0" ] && [ "$min" -eq "0" ]; then
                                         echo -ne "${YELLOW}"
                                 fi
                                 if [ "$hour" -eq "0" ] && [ "$min" -eq "0" ] && [ "$sec" -le "10" ]; then
                                         echo -ne "${GREEN}"
                                 fi
                                 echo -ne "$(printf "%02d" $hour h):$(printf "%02d" $min m):$(printf "%02d" $sec s)\033[0K\r"
                                 let "sec=sec-1"
                                 sleep 1
                         done
                         sec=59
                         let "min=min-1"
                 done
                 min=59
                 let "hour=hour-1"
         done
echo -e "${RESET}"
tput cnorm

echo
echo -e ${GREEN}Deployment is complete.
echo -e Please visit: https://$kibanafqdn ${NOCOLOR}
echo -e User: ${BLUE}elastic${NOCOLOR}
echo -e Pass: ${BLUE}Password you provided for Kibana above${NOCOLOR}
echo