#! /bin/bash

/usr/sbin/kdb5_util -P changeme create -s


## password only user
/usr/sbin/kadmin.local -q "addprinc  -randkey ifilonenko"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/ifilonenko.keytab ifilonenko"

/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/server.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/server.keytab HTTP/server.example.com"

/usr/sbin/kadmin.local -q "addprinc -randkey hdfs/nn.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/nn.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey yarn/nn.example.com"

/usr/sbin/kadmin.local -q "addprinc -randkey hdfs/dn1.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/dn1.example.com"

/usr/sbin/kadmin.local -q "addprinc -randkey hdfs/rm.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/rm.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey yarn/rm.example.com"


/usr/sbin/kadmin.local -q "addprinc -randkey hdfs/nm1.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/nm1.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey yarn/nm1.example.com"

/usr/sbin/kadmin.local -q "addprinc -randkey hdfs/hs2.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey hive/hs2.example.com"


/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hdfs/nn.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab HTTP/nn.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab yarn/nn.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hive/nn.example.com"

/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hdfs/dn1.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab HTTP/dn1.example.com"

/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hdfs/rm.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab HTTP/rm.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab yarn/rm.example.com"

/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hdfs/nm1.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab HTTP/nm1.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab yarn/nm1.example.com"

/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hdfs/hs2.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hive/hs2.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab yarn/hs2.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab HTTP/hs2.example.com"


chown hdfs /var/keytabs/hdfs.keytab


keytool -genkey -alias nn.example.com -keyalg rsa -keysize 1024 -dname "CN=nn.example.com" -keypass changeme -keystore /var/keytabs/hdfs.jks -storepass changeme
keytool -genkey -alias dn1.example.com -keyalg rsa -keysize 1024 -dname "CN=dn1.example.com" -keypass changeme -keystore /var/keytabs/hdfs.jks -storepass changeme

chmod 700 /var/keytabs/hdfs.jks
chown hdfs /var/keytabs/hdfs.jks


krb5kdc -n
