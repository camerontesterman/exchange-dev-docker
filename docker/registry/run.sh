#!/bin/bash

chmod 755 /root/setupdb.sh
/root/setupdb.sh

source /etc/profile.d/registry-settings.sh
source /etc/profile.d/vendor-libs.sh
source /env/bin/activate

cd /opt/registry

python registry.py runserver 0.0.0.0:8001
