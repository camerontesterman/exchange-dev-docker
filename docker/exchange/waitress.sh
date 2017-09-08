#!/bin/bash

source /etc/profile.d/exchange-settings.sh
cd /mnt/exchange
source .venv/bin/activate
/mnt/exchange/.venv/bin/waitress-serve --asyncore-use-poll --threads 8 --port=8000 exchange.wsgi:application
