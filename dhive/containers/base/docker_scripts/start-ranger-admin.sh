#!/bin/bash -x

RANGER_VERSION={{ ranger_version }}
MYSQL_VERSION={{ mysql_connector_version }}
RANGER_ADMIN_FOLDER=ranger-{{ ranger_version }}-admin/

sudo adduser ranger
echo ranger | sudo passwd ranger --stdin
sudo yum -y install bc

sudo chown -R -L hdfs ranger-{{ ranger_version }}-admin

pushd $RANGER_ADMIN_FOLDER
sed -i 's/db_root_user.*/db_root_user=root/g' install.properties
sed -i 's/db_root_password.*/db_root_password=root_pass/g' install.properties

sed -i 's/db_host.*/db_host=mysql.example.com/g' install.properties
sed -i 's/audit_store.*/audit_store=/g' install.properties

sed -i 's/db_name.*/db_name=ranger/g' install.properties
sed -i 's/db_user.*/db_user=ranger/g' install.properties
sed -i 's/db_password.*/db_password=ranger/g' install.properties

sed -i 's/rangerAdmin_password.*/rangerAdmin_password=12345678a/g' install.properties
sed -i 's/rangerTagsync_password.*/rangerTagsync_password=12345678a/g' install.properties
sed -i 's/rangerUsersync_password.*/rangerUsersync_password=12345678a/g' install.properties
sed -i 's/keyadmin_password.*/keyadmin_password=12345678a/g' install.properties

sed -i 's/admin_principal.*/admin_principal=admin\/ranger.example.com@EXAMPLE.COM/g' install.properties
sed -i 's/admin_keytab.*/admin_keytab=\/var\/keytabs\/hdfs.keytab/g' install.properties

sed -i 's/spnego_principal.*/spnego_principal=HTTP\/ranger.example.com@EXAMPLE.COM/g' install.properties
sed -i 's/spnego_keytab.*/spnego_keytab=\/var\/keytabs\/hdfs.keytab/g' install.properties

sed -i 's/lookup_principal.*/lookup_principal=lookup\/ranger.example.com@EXAMPLE.COM/g' install.properties
sed -i 's/lookup_keytab.*/lookup_keytab=\/var\/keytabs\/hdfs.keytab/g' install.properties

sed -i 's/cookie_domain.*/cookie_domain=ranger.example.com/g' install.properties
sed -i 's/cookie_path.*/cookie_path=\//g' install.properties
sed -i 's/authentication_method.*/authentication_method=UNIX/g' install.properties
sed -i 's/hadoop_conf.*/hadoop_conf=\/hadoop\/etc\/hadoop/g' install.properties


sed -i 's/policymgr_external_url.*/policymgr_external_url=http:\/\/ranger.example.com:6080/g' install.properties

sed -i '$a xasecure.audit.destination.db.jdbc.driver=com.mysql.jdbc.Driver' install.properties
sed -i '$a xasecure.audit.destination.db.jdbc.url=jdbc:mysql://mysql.example.com/ranger_audit' install.properties
sed -i '$a xasecure.audit.destination.db.user=ranger' install.properties
sed -i '$a xasecure.audit.destination.db.password=ranger' install.properties
sed -i '$a xasecure.audit.destination.db.password.alias=auditDBCred' install.properties

curl -L -o "mysql-connector-java-$MYSQL_VERSION.jar" "https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_VERSION/mysql-connector-java-$MYSQL_VERSION.jar"
sed -i "s/SQL_CONNECTOR_JAR.*/SQL_CONNECTOR_JAR=\/ranger-{{ ranger_version }}-admin\/mysql-connector-java-$MYSQL_VERSION.jar/g" install.properties

# mysql -h mysql.example.com -e 'CREATE DATABASE ranger' -u root -proot_pass
# mysql -h mysql.example.com -e 'GRANT ALL PRIVILEGES ON *.* To "ranger"@"%" IDENTIFIED BY "ranger";' -u root -proot_pass
# mysql -h mysql.example.com -e 'GRANT ALL PRIVILEGES ON *.* To "ranger"@"%" IDENTIFIED BY "ranger" WITH GRANT OPTION;' -u root -proot_pass


/usr/lib/jvm/jre-1.8.0-openjdk/bin/java  -cp \
    /ranger-{{ ranger_version }}-admin/mysql-connector-java-{{ mysql_connector_version }}.jar:/ranger-{{ ranger_version }}-admin/jisql/lib/* org.apache.util.sql.Jisql \
    -driver mysqlconj -cstring jdbc:mysql://mysql.example.com/ranger -u 'root' -p 'root_pass' \
    -noheader -trim -c \; -query "CREATE DATABASE ranger;"


/usr/lib/jvm/jre-1.8.0-openjdk/bin/java  -cp \
    /ranger-{{ ranger_version }}-admin/mysql-connector-java-{{ mysql_connector_version }}.jar:/ranger-{{ ranger_version }}-admin/jisql/lib/* org.apache.util.sql.Jisql \
    -driver mysqlconj -cstring jdbc:mysql://mysql.example.com/ranger -u 'root' -p 'root_pass' \
    -noheader -trim -c \; -query "CREATE DATABASE ranger_audit;"


/usr/lib/jvm/jre-1.8.0-openjdk/bin/java  -cp \
    /ranger-{{ ranger_version }}-admin/mysql-connector-java-{{ mysql_connector_version }}.jar:/ranger-{{ ranger_version }}-admin/jisql/lib/* org.apache.util.sql.Jisql \
    -driver mysqlconj -cstring jdbc:mysql://mysql.example.com/ranger -u 'root' -p 'root_pass' \
    -noheader -trim -c \; -query 'GRANT ALL PRIVILEGES ON *.* To "ranger"@"%" IDENTIFIED BY "ranger";'

/usr/lib/jvm/jre-1.8.0-openjdk/bin/java  -cp \
    /ranger-{{ ranger_version }}-admin/mysql-connector-java-{{ mysql_connector_version }}.jar:/ranger-{{ ranger_version }}-admin/jisql/lib/* org.apache.util.sql.Jisql \
    -driver mysqlconj -cstring jdbc:mysql://mysql.example.com/ranger -u 'root' -p 'root_pass' \
    -noheader -trim -c \; -query 'GRANT ALL PRIVILEGES ON *.* To "ranger"@"%" IDENTIFIED BY "ranger" WITH GRANT OPTION;'

sudo JAVA_HOME=$JAVA_HOME ./setup.sh
#sudo JAVA_HOME=$JAVA_HOME ./setup_authentication.sh ACTIVE_DIRECTORY ews/webapp


log_file=/ranger-{{ ranger_version }}-admin//ews/webapp/WEB-INF/log4j.properties
sudo sed -i 's/log4j.rootLogger.*/log4j.rootLogger=debug,xa_log_appender/g' $log_file
sudo sed -i 's/log4j.category.org.apache.ranger.*/log4j.category.org.apache.ranger=debug,xa_log_appender/g' $log_file
sudo sed -i 's/log4j.category.xa.*/log4j.category.xa=debug,xa_log_appender/g' $log_file
sudo sed -i 's/log4j.category.org.springframework.*/log4j.category.org.springframework=debug,xa_log_appender/g' $log_file

sudo ranger-admin start

popd

pushd /hive
# Web login: username, password = admin, 12345678a
# jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM;hive.server2.proxy.user=hive/hs2.example.com@EXAMPLE.COM

source /common.sh
kerberos_auth admin/ranger.example.com

curl --cookie-jar cook --negotiate -u :  'http://ranger.example.com:6080/service/plugins/services'
session_id=`cat cook | grep RANGERADMINSESSIONID | awk '{print $7}'`

# Add hiveserver repository
curl 'http://localhost:6080/service/plugins/services' -H "Cookie: clientTimeOffset=420; RANGERADMINSESSIONID=$session_id" -H 'Origin: http://localhost:6080' -H 'Accept-Encoding: gzip, deflate, br' -H 'X-XSRF-HEADER: ""' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.87 Safari/537.36' -H 'Content-Type: application/json' -H 'Accept-Language: en-US,en;q=0.9' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://localhost:6080/index.html' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data-binary '{"name":"hivedev","description":"","isEnabled":true,"tagService":"","configs":{"username":"hive","password":"12345678a","jdbc.driverClassName":"org.apache.hive.jdbc.HiveDriver","jdbc.url":"jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM","commonNameForCertificate":"","hadoop.security.authentication":"kerberos","lookupprincipal":"hive/hs2.example.com","lookupkeytab":"/var/keytabs/hdfs.keytab","rangerprincipal":"hive/hs2.example.com","keytabfile":"/var/keytabs/hdfs.keytab","rangerkeytab":"/var/keytabs/hdfs.keytab","authtype":"kerberos"},"type":"hive"}' --compressed

# TODO: This only seem to work if the username is named admin. usersync should be used to make hive an admin
# The id is 7 or 8.
# Make hive an admin
curl 'http://localhost:6080/service/xusers/secure/users/7' -X PUT -H "Cookie: clientTimeOffset=420; RANGERADMINSESSIONID=$session_id" -H 'Content-Type: application/json' -H 'Accept-Language: en-US,en;q=0.9' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://localhost:6080/' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data-binary '{"id":7,"createDate":"2018-06-24T05:44:32Z","updateDate":"2018-06-24T07:06:04Z","owner":"Admin","updatedBy":"Admin","name":"hive","firstName":"","lastName":"","description":"hive","groupIdList":[],"groupNameList":[],"status":1,"isVisible":1,"userSource":1,"userRoleList":["ROLE_SYS_ADMIN"],"passwordConfirm":"","emailAddress":""}' --compressed
curl 'http://localhost:6080/service/xusers/secure/users/8' -X PUT -H "Cookie: clientTimeOffset=420; RANGERADMINSESSIONID=$session_id" -H 'Content-Type: application/json' -H 'Accept-Language: en-US,en;q=0.9' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://localhost:6080/' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data-binary '{"id":8,"createDate":"2018-06-24T05:44:32Z","updateDate":"2018-06-24T07:06:04Z","owner":"Admin","updatedBy":"Admin","name":"hive","firstName":"","lastName":"","description":"hive","groupIdList":[],"groupNameList":[],"status":1,"isVisible":1,"userSource":1,"userRoleList":["ROLE_SYS_ADMIN"],"passwordConfirm":"","emailAddress":""}' --compressed

# Add user hive_meta and whoever
curl 'http://localhost:6080/service/xusers/secure/users' -H "Cookie: clientTimeOffset=420; RANGERADMINSESSIONID=$session_id" -H 'Origin: http://localhost:6080' -H 'Accept-Encoding: gzip, deflate, br' -H 'X-XSRF-HEADER: ""' -H 'Content-Type: application/json' -H 'Accept-Language: en-US,en;q=0.9' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://localhost:6080/index.html' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data-binary '{"groupIdList":null,"status":1,"userRoleList":["ROLE_USER"],"name":"hive_meta","password":"sakjdl129083","firstName":"hive_meta","lastName":"","emailAddress":""}' --compressed
curl 'http://localhost:6080/service/xusers/secure/users' -H "Cookie: clientTimeOffset=420; RANGERADMINSESSIONID=$session_id" -H 'Origin: http://localhost:6080' -H 'Accept-Encoding: gzip, deflate, br' -H 'X-XSRF-HEADER: ""' -H 'Content-Type: application/json' -H 'Accept-Language: en-US,en;q=0.9' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://localhost:6080/index.html' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data-binary '{"groupIdList":null,"status":1,"userRoleList":["ROLE_USER"],"name":"whoever","password":"sakjdl129083","firstName":"whoever","lastName":"","emailAddress":""}' --compressed

# Give whoever all privileges (This is not currently working)
# curl 'http://localhost:6080/service/plugins/policies/2' -X PUT -H 'Cookie: clientTimeOffset=420; RANGERADMINSESSIONID=$session_id' -H 'Origin: http://localhost:6080' -H 'Accept-Encoding: gzip, deflate, br' -H 'X-XSRF-HEADER: ""' -H 'Content-Type: application/json' -H 'Accept-Language: en-US,en;q=0.9' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://localhost:6080/' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data-binary '{"id":2,"guid":"cc0268fa-dee4-4e87-8d16-1c33ddb7273a","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1529867359000,"updateTime":1529873660000,"version":3,"service":"hivedev","name":"all - database, table, column","policyType":0,"policyPriority":0,"description":"Policy for all - database, table, column","resourceSignature":"ffd181600c642189ed345de83c0fb4649f19c4d89487a478b08bb5a88fa4602e","isAuditEnabled":true,"resources":{"database":{"values":["*"],"isRecursive":false,"isExcludes":false},"table":{"values":["*"],"isRecursive":false,"isExcludes":false},"column":{"values":["*"],"isRecursive":false,"isExcludes":false}},"policyItems":[{"users":["hive","lookup","whoever"],"delegateAdmin":true,"accesses":[{"type":"select","isAllowed":true},{"type":"update","isAllowed":true},{"type":"create","isAllowed":true},{"type":"drop","isAllowed":true},{"type":"alter","isAllowed":true},{"type":"index","isAllowed":true},{"type":"lock","isAllowed":true},{"type":"all","isAllowed":true},{"type":"read","isAllowed":true},{"type":"write","isAllowed":true}]}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"options":{},"validitySchedules":[],"policyLabels":[""]}' --compressed

popd

/sleep.sh
