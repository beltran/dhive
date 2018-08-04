#!/usr/bin/env bash

KERBEROS={{kerberos}}
SKIP_KERBEROS=0
if [ "$KERBEROS" = "no_kerberos" ]; then
  SKIP_KERBEROS=1
fi

kerberos_auth () {
    if [ "$SKIP_KERBEROS" = "1" ]; then
        echo "Skipping kerberos auth"
    else
        echo "Authenticating with kerberos"
        auth_until_success $1
    fi
}

create_keystore_if_no_kerberos () {
    if [ "$SKIP_KERBEROS" = "1" ]; then
        echo "Creating ssl keystore"
        sudo keytool -genkey -alias nn.example.com -keyalg rsa -keysize 1024 -dname "CN=nn.example.com" -keypass changeme -keystore /var/keytabs/hdfs.jks -storepass changeme
        sudo keytool -genkey -alias dn1.example.com -keyalg rsa -keysize 1024 -dname "CN=dn1.example.com" -keypass changeme -keystore /var/keytabs/hdfs.jks -storepass changeme

        sudo chmod 700 /var/keytabs/hdfs.jks
        sudo chown hdfs /var/keytabs/hdfs.jks
    else
        echo "Skipping creating ssl keystore"
    fi
}

auth_until_success () {
    until kinit -kt /var/keytabs/hdfs.keytab $1; do sleep 2; done
}

wait_for_nn () {
    until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
}
