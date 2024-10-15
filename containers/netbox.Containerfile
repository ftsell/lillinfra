FROM docker.io/netboxcommunity/netbox:v4.1

RUN echo "netbox-bgp>=0.14.0" >> /opt/netbox/local_requirements.txt &&\
    echo "netbox-floorplan-plugin>=0.4.1" >> /opt/netbox/local_requirements.txt &&\
    echo "netbox-qrcode>=0.0.13" >> /opt/netbox/local_requirements.txt &&\
    echo "netbox-topology-views>=4.1.0" >> /opt/netbox/local_requirements.txt &&\
    /opt/netbox/venv/bin/pip install -r /opt/netbox/local_requirements.txt &&\
    mkdir -p /opt/netbox/netbox/static/netbox_topology_views/img
