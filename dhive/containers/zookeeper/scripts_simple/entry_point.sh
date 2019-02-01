#!/usr/bin/env bash

# We have to wait for the keytab to be created
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done

/scripts/time_scripts.sh &

# sudo cp /conf/krb5.conf /etc/krb5.conf
cp /conf/krb5.conf /etc/krb5.conf

/docker-entrypoint.sh
zkServer.sh start-foreground
