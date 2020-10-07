#! /bin/sh
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    #while ! curl -s -X GET 172.16.1.2:9200/_cluster/health/ -u elastic:test@123 | grep -q 'yellow'
#do
    #echo "==> Waiting for cluster yellow status" && sleep 1
#done
    cd /etc/metricbeat/ && chown root /etc/metricbeat/metricbeat.yml && metricbeat modules enable http && metricbeat modules disable system && pip3 install -r python-scripts/requirements.txt
	echo "********************-- Excecuting python script-***************************"

	python3 python-scripts/generateMetricbeat.py -host ${HOST_IP}:${HOST_PORT}
    while true; do sleep 30; done;

else
     echo "******************* Not first container startup **********************"
fi
python3 /etc/metricbeat/python-scripts/generateMetricbeat.py -host ${HOST_IP}:${HOST_PORT}






