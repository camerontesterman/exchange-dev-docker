#!/bin/bash

source /root/helpers.sh

# install epel-release
yum -y install epel-release
yum -y install python-pip

# upgrade pip
pip install --upgrade pip

# install virtualenv
pip install virtualenv

# setup virtualenv
virtualenv $VENV_DIR
chmod 755 $VENV_DIR

# remove geonode from requirements.txt and install requirements.txt
cp $EXCHANGE_DIR/requirements.txt $EXCHANGE_DIR/req.txt
sed -i.bak "/egg=geonode/d" $EXCHANGE_DIR/req.txt && \
PATH="/opt/boundless/vendor/bin":"${PATH}"                 && \
$VENV_DIR/bin/pip install -r $EXCHANGE_DIR/req.txt

# move exchange-settings.sh file to correct locations
cp /root/exchange-settings.sh /etc/profile.d

# setup MapLoom
rm -rf $VENV_DIR/lib/python2.7/site-packages/maploom/static/maploom                   && \
ln -s /mnt/maploom/build $VENV_DIR/lib/python2.7/site-packages/maploom/static/maploom && \
rm $VENV_DIR/lib/python2.7/site-packages/maploom/templates/maps/maploom.html          && \
ln -s /mnt/maploom/build/maploom.html $VENV_DIR/lib/python2.7/site-packages/maploom/templates/maps/maploom.html

# remove .pyc files
find /mnt/exchange -type f -name "*.pyc" -delete

# source variables
source /etc/profile.d/exchange-settings.sh
source /etc/profile.d/vendor-libs.sh

# install Geonode
$VENV_DIR/bin/pip install -e $GEONODE_DIR

# copy supervisord.conf, waitress.sh, celery-worker.sh, exchange-init to correct places
cp /root/supervisord.conf /etc
cp /root/waitress.sh $EXCHANGE_DIR
cp /root/celery-worker.sh $EXCHANGE_DIR
cp /root/exchange-init /etc/init.d/exchange

# restart systemctl daemon
systemctl daemon-reload

# check if database is up
wait_for_pg "database"

# run migrations
run_migrations

# start up waitress and celery
$VENV_DIR/bin/supervisord
