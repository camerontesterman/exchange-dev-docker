#!/bin/bash

source /etc/profile.d/exchange-settings.sh
cd /mnt/exchange
source .venv/bin/activate
celery worker --app=exchange.celery_app --uid=exchange --loglevel=info
