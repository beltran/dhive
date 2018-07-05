#! /bin/bash



until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com; do sleep 2; done

until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done


hdfs dfsadmin -safemode wait


hdfs dfs -mkdir -p /user/random_user/
hdfs dfs -copyFromLocal /people.json /user/random_user
hdfs dfs -copyFromLocal /people.txt /user/random_user

hdfs dfs -chmod -R 755 /user/random_user
hdfs dfs -chown -R random_user /user/random_user
