#!/usr/bin/env bash

# while ! echo exit | curl ranger.example.com:6080 --connect-timeout 2; do echo "Waiting for ranger admin to come up"; sleep 2; done

sudo chown -R -L hdfs ranger-{{ ranger_version }}-hive-plugin

pushd ranger-{{ ranger_version }}-hive-plugin/

sudo adduser hive
echo hive | sudo passwd hive --stdin

sed -i 's/CUSTOM_GROUP.*/CUSTOM_GROUP=/g' install.properties
sed -i 's/POLICY_MGR_URL.*/POLICY_MGR_URL=http:\/\/ranger.example.com:6080/g' install.properties
sed -i 's/REPOSITORY_NAME.*/REPOSITORY_NAME=hivedev/g' install.properties
sed -i 's/COMPONENT_INSTALL_DIR_NAME.*/COMPONENT_INSTALL_DIR_NAME=\/hive/g' install.properties

sed -i 's/XAAUDIT\.HDFS\.ENABLE.*/XAAUDIT.HDFS.ENABLE=true/g' install.properties
sed -i 's/XAAUDIT\.HDFS\.HDFS_DIR.*/XAAUDIT.HDFS.HDFS_DIR=hdfs:\/\/nn.example.com:9000\/ranger\/audit/g' install.properties
sed -i 's/XAAUDIT.DB.IS_ENABLED .*/XAAUDIT.DB.IS_ENABLED=true/g' install.properties

sed -i 's/XAAUDIT.DB.FLAVOUR.*/XAAUDIT.DB.FLAVOUR=MYSQL/g' install.properties
sed -i 's/XAAUDIT.DB.HOSTNAME.*/XAAUDIT.DB.HOSTNAME=mysql.example.com/g' install.properties
sed -i 's/XAAUDIT.DB.DATABASE_NAME.*/XAAUDIT.DB.DATABASE_NAME=ranger/g' install.properties
sed -i 's/XAAUDIT.DB.USER_NAME .*/XAAUDIT.DB.USER_NAME=ranger/g' install.properties
sed -i 's/XAAUDIT.DB.PASSWORD.*/XAAUDIT.DB.PASSWORD=ranger/g' install.properties

sed -i '$a XAAUDIT.DB.FLAVOUR=MYSQL' install.properties
sed -i '$a XAAUDIT.DB.HOSTNAME=mysql.example.com' install.properties
sed -i '$a XAAUDIT.DB.DATABASE_NAME=ranger_hive' install.properties
sed -i '$a XAAUDIT.DB.USER_NAME=ranger_hive' install.properties
sed -i '$a XAAUDIT.DB.PASSWORD=ranger_hive' install.properties

/usr/lib/jvm/jre-1.8.0-openjdk/bin/java  -cp \
    /ranger-{{ ranger_version }}-admin/mysql-connector-java-{{ mysql_connector_version }}.jar:/ranger-{{ ranger_version }}-admin/jisql/lib/* org.apache.util.sql.Jisql \
    -driver mysqlconj -cstring jdbc:mysql://mysql.example.com/ranger -u 'root' -p 'root_pass' \
    -noheader -trim -c \; -query "CREATE DATABASE ranger_hive;"

/usr/lib/jvm/jre-1.8.0-openjdk/bin/java  -cp \
    /ranger-{{ ranger_version }}-admin/mysql-connector-java-{{ mysql_connector_version }}.jar:/ranger-{{ ranger_version }}-admin/jisql/lib/* org.apache.util.sql.Jisql \
    -driver mysqlconj -cstring jdbc:mysql://mysql.example.com/ranger -u 'root' -p 'root_pass' \
    -noheader -trim -c \; -query 'GRANT ALL PRIVILEGES ON *.* To "ranger_hive"@"%" IDENTIFIED BY "ranger_hive";'

/usr/lib/jvm/jre-1.8.0-openjdk/bin/java  -cp \
    /ranger-{{ ranger_version }}-admin/mysql-connector-java-{{ mysql_connector_version }}.jar:/ranger-{{ ranger_version }}-admin/jisql/lib/* org.apache.util.sql.Jisql \
    -driver mysqlconj -cstring jdbc:mysql://mysql.example.com/ranger -u 'root' -p 'root_pass' \
    -noheader -trim -c \; -query 'GRANT ALL PRIVILEGES ON *.* To "ranger_hive"@"%" IDENTIFIED BY "ranger_hive" WITH GRANT OPTION;'


sudo JAVA_HOME=$JAVA_HOME ./enable-hive-plugin.sh
export HIVE_CLASSPATH="$HIVE_CLASSPATH:$(find /ranger-{{ ranger_version }}-hive-plugin/lib -name '*.jar')"

cp $HIVE_HOME/conf/ranger-hive-audit.xml $HIVE_CONF_DIR/
cp $HIVE_HOME/conf/ranger-hive-security.xml $HIVE_CONF_DIR/
cp $HIVE_HOME/conf/ranger-policymgr-ssl.xml $HIVE_CONF_DIR/
cp $HIVE_HOME/conf/ranger-security.xml $HIVE_CONF_DIR/

# Now this file is not generated
# cp $HIVE_HOME/conf/hiveserver2-site.xml $HIVE_CONF_DIR/

# jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM
# hadoop.security.authentication kerberos
