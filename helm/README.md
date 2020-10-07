# Kubernetes Helm Install for Linview OSS

The Kubernetes Installation steps for Linview are a bit different than with docker-compose.

Helm is used to do the install, but there is a prerequisite creation of a Kubernetes ConfigMap with your configuration created using the setup.sh file.  Also, you will need a supported Ingress Controller running on your cluster - see values.yaml for the ingress configuration for Kibana. You will have to customize the Helm chart if you want to run with Istio or a different mesh.

## Optional

If you don't have an existing Linstor cluster, you can spin one up quickly on Kubernetes using Piraeus (https://github.com/piraeusdatastore/piraeus) or the Piraeus Operator.  Then, just use the piraeus controller service as HOST IP and HOST PORT when using setup.sh and updating values.yaml.

## Steps

1. First, run the setup.sh file according to the normal installation instructions

```
sudo ./setup.sh
```

2. Now, we need to make a Secret with our Kibana Configuration. Run the following from within the linview-oss root.  You can add a namespace if you plan on installing the helm chart in a specific namespace.

```
cp ./import/linview_kibana_<WHAT YOUR LINSTOR HOST WAS>.ndjson ./import/IMPORT_JSON
kubectl create secret generic import-json-secret --from-file=./import/IMPORT_JSON
```

3. Now, we can proceed with the installation of our Helm Chart.  Change the values.yaml as necessary, then run (from within the helm folder):

```
helm install . linview-oss
```

4. Once everything spins up, you will be able to access the Kibana Dashboard via the ingress record created in your cluster.