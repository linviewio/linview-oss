import requests
import json
import subprocess
import re
# pip install APScheduler
from apscheduler.schedulers.blocking import BlockingScheduler
import logging
import sys
import argparse


logging.basicConfig(stream=sys.stdout, level=logging.INFO)

endpoints = {}
nodes = []
yaml_to_write = []


def data_net_iface_storage_pool(node_name):
    """
    This method appends a desired string(yaml_data) to a list(yaml_to_write).
    """

    yaml_to_write.append(yaml_data.replace("/nodes", "/nodes/"+node_name+"/storage-pools")
                         .replace("nodes_page", "node_storage_pool_page"))
                         
def data_net_iface_res_def(res_name):
    """
    This method appends a desired string(yaml_data) to a list(yaml_to_write).
    """

    yaml_to_write.append(yaml_data.replace("/nodes", "/resource-definitions/"+res_name+"/snapshots")
                         .replace("nodes_page", "res_definitions_snapshots"))
                         
def data_net_iface_res_volume_groups(res_group_name):
    """
    This method appends a desired string(yaml_data) to a list(yaml_to_write).
    """

    yaml_to_write.append(yaml_data.replace("/nodes", "/resource-groups/"+res_group_name+"/volume-groups")
                         .replace("nodes_page", "res_group_volumes"))
                         
def data_net_iface_res_group_volume_maxsize(res_group_name):
    """
    This method appends a desired string(yaml_data) to a list(yaml_to_write).
    """

    yaml_to_write.append(yaml_data.replace("/nodes", "/resource-groups/"+res_group_name+"/query-max-volume-size")
                         .replace("nodes_page", "res_group_volumes_maxsize"))


def error_report(data):
    """
    This method appends a desired string(yaml_data) to a list(yaml_to_write).
    """

    yaml_to_write.append(yaml_data.replace("/nodes", "/error-reports/"+str(data))
                         .replace("nodes_page", "errors_detail_report"))


def resource_names(data, req_num):
    """
    This method performs the required actions on the response content that
    is passed to it from api_req method and appends it to yaml_to_write list
    based on req_num passed.
    """

    if req_num == "5":
        yaml_to_write.append(yaml_data.replace("/nodes", "/controller/properties")
                             .replace("nodes_page", "json_ctrl_properties")
                             .replace("json.is_array: true", "json.is_array: false"))
    elif req_num == "6":
        yaml_to_write.append(yaml_data.replace("/nodes", "/controller/version")
                             .replace("nodes_page", "json_ctrl_version")
                             .replace("json.is_array: true", "json.is_array: false"))
    elif req_num == "8":
        yaml_to_write.append(yaml_data.replace("/nodes", "/view/storage-pools")
                             .replace("nodes_page", "storage_pool_page"))
    elif req_num == "9":
        yaml_to_write.append(yaml_data.replace("/nodes", "/view/resources")
                             .replace("nodes_page", "resources_page"))
    elif req_num == "3":
        yaml_to_write.append(yaml_data.replace("/nodes", "/resource-definitions")
                             .replace("nodes_page", "resource_definition_page"))
    elif req_num == "7":
        yaml_to_write.append(yaml_data.replace("/nodes", "/error-reports")
                             .replace("nodes_page", "error_report_page"))
    elif req_num == "4":
        yaml_to_write.append(yaml_data.replace("/nodes", "/resource-groups")
                             .replace("nodes_page", "resource_group_page"))

    if req_num != "5" or req_num != "6" or req_num != "8":
        for i in range(len(data)):
            if req_num == "1":
                nodes.append(data[i]['name'])
                data_net_iface_storage_pool(data[i]['name'])
            elif req_num == "3":
                nodes.append(data[i]['name'])
                data_net_iface_res_def(data[i]['name'])
            elif req_num == "4":
                nodes.append(data[i]['name'])
                data_net_iface_res_volume_groups(data[i]['name'])
                data_net_iface_res_group_volume_maxsize(data[i]['name'])
            
            # elif req_num == "7":
            #     if i == 0:
            #         yaml_to_write.append(yaml_data.replace("/nodes","/error-reports")\
            #             .replace("nodes_page","error_report_page"))
                # error_report(data[i]['filename'].split("ErrorReport-")[1].split(".log")[0])
               


def api_req(path, req_num):
    """
    This method sends an api request to the desired url and passes the response to
    resource_names() or appends a string to yaml_to_write list depends on status code.
    """

    url = path
    response = requests.get(url)
    # logging.info(str(response.status_code))
    if response.status_code == 200 and response.content:
        body = response.content
        json_data = json.loads(body)
        resource_names(json_data, req_num)
    else:
        info = "There is an issue with the URL :{0}, Returned with Status Code: {1}".format(url, response.status_code)
        logging.info(info)


def request1_first():
    """
    This is the very first method to be called to append the yaml data
    into list and call the URL's
    """

    yaml_to_write.append(yaml_data+"\n")
    logging.info('requets are being sent!')
    for url_id, url_path in endpoints.items():
        api_req(url_path, url_id)


def write_start_service_metricbeat():
    """
    This method opens http.yml file and overwrites the content init with the
    content in yaml_to_write list, and thereby restarts the metric beat service.
    Then deletes the content in the list.
    """

    with open('/etc/metricbeat/modules.d/http.yml', 'w') as f:
        for item in yaml_to_write:
            f.write("%s\n" % item)
    logging.info('metricbeat yaml has been written!')
    subprocess.call(["service", "metricbeat", "restart"])
    f.close()
    del yaml_to_write[:]


def start_process():
    """
    This method is responsible for calling request1_first and
    write_start_service_metricbeat methods
    """

    try:
        request1_first()
        write_start_service_metricbeat()
        logging.info('metricbeat service has been restarted')
    except Exception as excep:
        info = "Exception has occured, details: {0}".format(excep)
        logging.exception(str(info))


def main():
    """
    This method builds a Scheduler and adds start_process method as
    a job to it for every 10 minutes interval
    """
    try:
        scheduler = BlockingScheduler()
        scheduler.add_job(start_process, 'interval', seconds=600)
        scheduler.start()
    except Exception as excep:
        info = "Exception has occured, details: {0}".format(excep)
        logging.exception(str(info))


parser = argparse.ArgumentParser(
    description="python script to generate metricbeat yaml and start the service")

parser.add_argument("-host", help="python <script>.py -host IP:Portnumber")
args = parser.parse_args()

if args.host:
    m = re.search(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:[0-9]+',
                  args.host)
    if m:
        host = m.group(0)
        yaml_data_raw = """- module: http
  metricsets: ["json"]
  period: 60s
  hosts: ["http://%s"]
  namespace: "nodes_page"
  path: "/v1/nodes"
  method: "GET"
  json.is_array: true
  request.enabled: true
  #response.enabled: false
  dedot.enabled: true
        """
        yaml_data = yaml_data_raw % host
        endpoints = {"1": "http://"+host+"/v1/nodes",
                     "2": "http://"+host+"/v1/storage-pool-definitions",
                     "4": "http://"+host+"/v1/resource-groups",
                     "3": "http://"+host+"/v1/resource-definitions",
                     "5": "http://"+host+"/v1/controller/properties",
                     "6": "http://"+host+"/v1/controller/version",
                     "7": "http://"+host+"/v1/error-reports",
                     "8": "http://"+host+"/v1/view/storage-pools",
                     "9": "http://"+host+"/v1/view/resources"}
        start_process()
        main()
else:
    print("please run with python <script>.py -host IP:Portnumber")
