# LINVIEW OSS EMK for LINSTOR (Beta)
## Version: 0.6-beta (released 06/11/20)

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
* Target LINSTOR cluster*

*If you need to configure a basic LINSTOR cluster on Ubuntu, you can follow instructions below:

*Official LINSTOR documentation:* https://www.linbit.com/drbd-user-guide/linstor-guide-1_0-en/#s-installation
*Basic 3 Node Setup Script for Ubuntu:* https://github.com/AlphaBravoCompany/linstor-ubuntu-demo 
*Vito Botta blog:* https://vitobotta.com/2019/08/07/linstor-storage-with-kubernetes/

We are actively developing installation scripts to streamline controller and satellite setup, storage pool creation and resource creation. We will update this README once this is complete.

## Setting up LINVIEW OSS
1. On the machine where LINVIEW OSS will be hosted, clone this repo.
2. Change int the LINSTOR OSS directory `cd linstor-oss`
3. Add execute to the setup script `chmod +x ./setup.sh`
4. Run `./setup.sh` and enter the details for the Docker/Kibana host and the LINSTOR Controller host.
5. Login to the interface at `http://dockerhostip:5601` with username and pass that you provided during install.

## Updating and Import Dashboards
1. In the `import` directory, copy `LINSTORHOST-linview-kibana.ndjson file to your local machine.
2. In Kibana, navigate to `management`, `Kibana`, `Saved Objects` and the choose `Import` and select the modified import file from step 1.
3. Now you can navigate to LINVIEW saved objects in the interface.

## Roadmap
* Interface "Quick Start Guide"
* Update on API elements collected in Elasticsearch
* Add support to use Open Distro for Elastic
* Updated dashboard elements for a more concise and informative layout
* Instructions for alerting using Elastic xPack alerting (paid Elastic feature)
* Other Improvements

## Issues
Please submit issues in GitHub Issues for this project.

## Using LINSTOR

Please read the user-guide provided at [docs.linbit.com](https://docs.linbit.com).

## Visualizing and Managing LINSTOR Clusters using the LINVIEW GUI:

LINVIEW OSS: https://github.com/AlphaBravoCompany/linview-oss

LINVIEW Enterprise: Contact LINVIEW at https://linview.io

## Support and Consulting:

Supported enterprise versions of LINSTOR, please contact LINBIT: https://www.linbit.com

LINVIEW Support, please contact LINVIEW: https://linview.io
DevSecOps Acceleration for both public and private sector: https://alphabravo.io