# Big Data Platform

The aim of this proyect is to make it easy to deploy a kerberized stack of hadoop/yarn/tez/hive.

## Configure Docker networking

All the services start in Docker containers which are deployed with docker-compose so both have
to be installed Hadoop requires reverse DNS.  Under docker-compose, we require an external
network named "com"  for hosts to resolve forward and backwards.

```
docker network create com
```
Probably it's convenient to allow docker more memory/core resources than the defaults.

## Getting started

Running:
```
make all
```

This will:
- Start several services in docker images: keberos, hadoop, yarn, tez, hive or other services
depending on what's defined on `vars.config`
- Pull relevant logs from the docker images which can be seen at `http:localhost:8000`

The file `vars.config` holds the values for:
- The version values for hadoop, hive, tez. 
- The services that will be running.
- Properties that will be overriden for core-site.xml, hdfs-site.xml, yarn-site.xml, tez-site.xml and hive-site.xml.

To tear down everything:
```
make clean
```

## Using a local hive or tez distribution

This can be enabled by setting the variables `HIVE_PATH` or `TEZ_PATH` in `vars.config`. If we want 
dhive to also compile and push the generated tar to the docker containers the variables 
`HIVE_COMPILE` and `TEZ_COMPILE` have to be set to `1`, for example:
```
HIVE_COMPILE=1 make clean all
```

If `HIVE_PATH` or `TEZ_PATH` are not set dhive will download the release from the version specified in `vars.config`.
If `HIVE_PATH` or `TEZ_PATH` are set dhive but not `HIVE_COMPILE` or `TEZ_COMPILE` it won't compile the 
source code but it will still try to get the tarball from the path


## Run commands in containers

We can do this from any running container:
```
docker exec -it nn.example /bin/bash
kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com
hdfs dfs -ls /
```

If hive is running (with kerberos) we can get a beeline prompt:
```
docker exec -it hs2.example /bin/bash
kinit -kt /var/keytabs/hdfs.keytab hive/hs2.example.com
beeline -u "jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM;hive.server2.proxy.user=hive/hs2.example.com@EXAMPLE.COM"

# For example now to activate the whole stack:
jdbc:hive2://hs2.example.com:10000/>CREATE TABLE pokes (foo INT, bar STRING);
jdbc:hive2://hs2.example.com:10000/>INSERT INTO pokes(foo, bar) VALUES (1, "1");
```

## Adding services

Usually the following steps would be taken:
- Add a new `SERVICE_NAME.yml` to `dhive/services`.
- Maybe adding a start script to `dhive/scripts`.
- Maybe creating a new principal in `dhive/scripts/start-kdc.sh`.
- Maybe overriding or removing some of the properties of the configuration files.
- Add the new service to `vars.config` or to a different configuration file (it can be
set with the environment variable `CONFIG_FILE`).

An example of this is adding a mysql backend for the hivemetastore. It can be run with:
```
CONFIG_FILE=vars_mysql.config make all
```

## How it works
The folder `dhive` is formed by the templates. When running:
```
make generate
```
the real files that will deploy the containers are generated under `build`.
This accomplishes being able to use global variables across all the files
and being able to override the properties specified in `vars.config` for the
configuration files.
