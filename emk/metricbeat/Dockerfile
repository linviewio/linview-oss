# backlog - need to check the same configuration in Alpine. Currently we pulled Ubuntu
FROM ubuntu:latest

RUN apt-get update -y && \ 
    apt-get install -y wget


RUN apt-get install -y gnupg2 curl
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN apt-get install apt-transport-https
RUN echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
RUN apt-get update && apt-get install metricbeat

RUN update-rc.d metricbeat defaults 95 10

RUN apt-get install python3 -y \
    && apt-get install python3-pip -y

USER root

VOLUME ["/sys/fs/cgroup"]

COPY entrypoint.sh /etc/
RUN chmod +x /etc/entrypoint.sh
