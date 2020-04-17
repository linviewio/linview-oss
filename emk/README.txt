Docker-Compose Utility was used to setup ELK in DEV/Test Servers. And the servers consists docker-compose.yml in the directory "/root/docker/emk" where we can issue the commands

Bind mounts:

Python scripts	: /root/docker/emk/python_scripts
Docker-Compose	: /root/docker/emk
Metricbeat	: /root/docker/emk/metricbeat/
Elasticsearch	: /root/docker/emk/elasticsearch
Kibana		: /root/docker/emk/kibana


Setup Commands:

	#Navigate to the directory where docker-compose.yml exists
	`cd /root/docker/emk`
	
	#For the first time it might take a while to pull and configure the Elasticsearch and Kibana Images
	`docker-compose -f docker-compose.yml up`

	#SSH TUNELLING to your Localhost
	`ssh -i private_key root@157.245.208.219 -L 5601:157.245.208.219:5601 -L 9200:157.245.208.219:9200 -L 9300:157.245.208.219:9300`
	
	#Stop Services
	`docker-compose stop`
	
	#clean up
	`docker-compose down`

Backlogs:

Search backlogs using the command `grep -nir "backlog "`, the results indicates that they need to be revisted or need some assistance


Note:
	
	To change the password for Elasticsearch & Kibana, edit the following in "/root/docker/emk" dir
	
	```
	docker-compose.yml:22:      ELASTIC_PASSWORD: test@123 //Change your password later
	kibana/config/kibana.yml:13:elasticsearch.password: test@123 //Change your password later
	```