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

Python3 has to be installed. To install the requirements:

```
python -m pip install -r requirements.txt
```

Running:
```
make all
```

This will:
- Start several services in docker images: keberos, hadoop, yarn, tez, hive or other services
depending on what's defined on `config/vars.cfg`
- Pull relevant logs from the docker images which can be seen at `http:localhost:8000`

The file `config/vars.cfg` holds the values for:
- The version values for hadoop, hive, tez. 
- The services that will be running.
- Properties that will be overriden for core-site.xml, hdfs-site.xml, yarn-site.xml, tez-site.xml and hive-site.xml.

To tear down everything:
```
make clean
```

## Using a local hive or tez distribution

This can be enabled by setting the variables `HIVE_PATH` or `TEZ_PATH` in `config/vars.cfg`. If we want 
dhive to also compile and push the generated tar to the docker containers the variables 
`HIVE_COMPILE` and `TEZ_COMPILE` have to be set to `1`, for example:
```
HIVE_COMPILE=1 make clean all
```

If `HIVE_PATH` or `TEZ_PATH` are not set dhive will download the release from the version specified in `config/vars.cfg`.
If won't download it again if it's on the root directory.
If `HIVE_PATH` or `TEZ_PATH` are set dhive but not `HIVE_COMPILE` or `TEZ_COMPILE` it won't compile the 
source code but it will still try to get the tarball from the path.

If some changes are made (changes to `config/vars.cfg` or to the source code) and we want to redeploy
 hive/tez/ranger nodes we can do:
```
make restart-{hive|tez|ranger}
```
If we want to recompile because a change in the source code has been done:
```
HIVE_COMPILE=1 make restart-{hive|tez|ranger}
```


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
- Add the new service to `config/vars.cfg` or to a different configuration file (it can be
set with the environment variable `DHIVE_CONFIG_FILE`).

An example of this is adding a mysql backend for the hivemetastore. It can be run with:
```
DHIVE_CONFIG_FILE=config/mysql.cfg make all
```

## Running a container with a job
This can be done to submit a jar to hadoop to run with tez, or to run hive queries, or more generally,
once the environment is set up, to take actions against it.
An example of how the first would be done is the file `config/run_tez_job.cfg`. It's added like another
service but it has to start with `external`. Four variables are defined inside the service section:
* docker: instructions to add to the `Dockerfile`.
* assure: files to copy to the folder where docker is going to be built.
* run: script to run inside the container.
* kerberos: principals to add for kerberos at the running host.

To run this particular example:
`DHIVE_CONFIG_FILE=config/run_tez_job.cfg make all`

This will also generate the script `build/restart-new-service-name` in case we want to tweak something
in the `.cfg` file and only restart the new service.


## LLAP
LLAP can be deployed with the config file `config/llap.cfg`.


## Ranger
Ranger can be deployed and integrated with hive with the config file `config/ranger.cfg`.


## How it works
The folder `dhive` is formed by the templates. When running:
```
make generate
```
the real files that will deploy the containers are generated under `build`.
This accomplishes being able to use global variables across all the files
and being able to override the properties specified in `config/vars.cfg` for the
configuration files.
