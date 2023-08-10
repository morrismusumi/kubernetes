#!/bin/bash

# generate config file
envsubst < /semaphore/config_template.json > /semaphore/config.json
# configure admin user settings
ADMIN_USER=$(semaphore user list --config /semaphore/config.json | grep $SEMAPHORE_ADMIN)
if [ -n "$ADMIN_USER" ]; then
    echo "Admin user found! Setting Admin user creds"
    semaphore user change-by-login $SEMAPHORE_ADMIN_NAME --admin --email $SEMAPHORE_ADMIN_EMAIL --login $SEMAPHORE_ADMIN_NAME --name $SEMAPHORE_ADMIN_NAME --password  $SEMAPHORE_ADMIN_PASSWORD --config /semaphore/config.json
else
    echo "Admin user not found. Creating Admin user"
    semaphore user add $SEMAPHORE_ADMIN --admin --password $SEMAPHORE_ADMIN_PASSWORD --name $SEMAPHORE_ADMIN_NAME --login $SEMAPHORE_ADMIN_NAME --email $SEMAPHORE_ADMIN_EMAIL --config /semaphore/config.json
fi
# start semaphore service
semaphore service --config=/semaphore/config.json