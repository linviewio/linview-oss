# LINVIEW OSS EMK for LINSTOR (Beta)
## Version: 0.05beta (released 04/17/20)

## This project is being heavily developed and there may be breaking changes.

**LINVIEW OSS** is the open-source version of LINVIEW storage dashboard to visualize LINSTOR (https://www.linbit.com/linstor/) storage cluster.

**LINSTOR** is Block Storage Management For Containers. 

With native integration to Kubernetes, LINSTOR makes building, running, and controlling block storage simple. LINSTOR is open-source software designed to manage block storage devices for large Linux server clusters. It’s used to provide persistent Linux block storage for Kubernetes, OpenStack, OpenNebula, and OpenShift environments. 

## Components
* Docker
* Elasticsearch
* Metricbeat
* Kibana

Elastic, Metricbeat and Kibana are often referred to as EMK, so when you see references to EMK, that is what it is referring to.

## Requirements
* Machine or VM with 4 CPU and 8GB of RAM
* Linux
* Docker CE Engine (https://docs.docker.com/engine/install/)
* Docker Compose (https://docs.docker.com/compose/install/)

## Setting up LINVIEW OSS
1. On the machine where LINVIEW OSS will be hosted, clone this repo.
2. `cd linstor-oss-emk/emk`
3. Ensure that Docker CE engine and docker-compose are installed
4. `docker-compose up -d`
5. Login to the interface at `http://hostip:5901`

## Updating and Import Dashboards
1. In the `import` directory, copy `dasboard_all_*version*.ndjson.sample` to `dashboard_all_*version*.ndjson`.
2. Find `DOCKER_HOST_FDQN:PORT` in the import file and replace with the FQDN or IP of your Docker Host and the port Kibana is listening on. Eg: http(s)://127.0.0.1:5901 or http://linview.myorg.local:5901. By default the docker compose file will bring Kibana up on port 5901.
3. Find `LINSTOR_CONTROLLER_FQDN:PORT` in the import file and replace with the FQDN or IP of your LINSTOR controller and the port LINSTOR is listening on.
4. Copy the contents of your modified file to the machine where you will access the Kibana interface from.
5. In Kibana, navigate to `management`, `Kibana`, `Saved Objects` and the choose `Import` and select the modified import file from steps 2-5.
6. Now you can navigate to LINSTOR saved objects in the interface.

## Roadmap
* Script to make updating the necessary import.ndjson file and importing easier.
* Interface "Quick Start Guide"
* Update on API elements collected in Elasticsearch
* Updated dashboard elements for a more concise and informative layout
* Instructions for alerting using Elastic xPack alerting (paid Elastic feature)
* Other Improvements

Please submit issues in GitHub Issues for this project.

