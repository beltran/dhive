FROM centos:7

RUN yum -y install krb5-server krb5-workstation
RUN yum -y install java-1.8.0-openjdk-headless
RUN yum -y install apache-commons-daemon-jsvc
RUN yum install net-tools -y
RUN yum install telnet telnet-server -y
RUN yum -y install which
RUN echo "hdfs ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN yum -y install sudo
RUN sed -i -e 's/#//' -e 's/default_ccache_name/# default_ccache_name/' /etc/krb5.conf

RUN useradd -u 1098 hdfs

ADD hadoop-{{ hadoop_version }}.tar.gz /
RUN ln -s hadoop-{{ hadoop_version }} hadoop
RUN chown -R -L hdfs /hadoop
#RUN chmod 777 -R /tmp && chmod o+t -R /tmp
#RUN chown -R -L hdfs /hadoop



COPY conf/core-site.xml /hadoop/etc/hadoop/
COPY conf/hdfs-site.xml /hadoop/etc/hadoop/
COPY conf/ssl-server.xml /hadoop/etc/hadoop/
COPY conf/yarn-site.xml /hadoop/etc/hadoop/
COPY conf/tez-site.xml /hadoop/etc/hadoop/

COPY env /hadoop/etc/hadoop/
COPY env /hadoop/etc/hadoop/

COPY docker_scripts/start-namenode.sh /
COPY docker_scripts/start-datanode.sh /
COPY docker_scripts/start-resourcemanager.sh /
COPY docker_scripts/start-nodemanager.sh /
COPY docker_scripts/populate-data.sh /
COPY docker_scripts/run-and-install-tez.sh /
COPY docker_scripts/start-kdc.sh /
COPY docker_scripts/start-hive.sh /
COPY docker_scripts/start-hive-metastore.sh /
COPY docker_scripts/start-ranger-admin.sh /
COPY docker_scripts/start-ranger-hive.sh /
COPY docker_scripts/sleep.sh /

COPY conf/hive-site.xml /hadoop/etc/hadoop/
COPY conf/hivemetastore-site.xml /hadoop/etc/hadoop/

COPY data/people.json /
COPY data/people.txt /

# Tez section
ENV TEZ_CONF_DIR=/hadoop/etc/hadoop/
ENV TEZ_JARS=/tez_jars
COPY tez.tar.gz /
COPY tez_up.tar.gz /
RUN mkdir $TEZ_JARS
RUN tar -xvzf tez.tar.gz -C $TEZ_JARS

# Hive section
ENV HIVE_HOME=/hive
COPY hive.tar.gz /
RUN mkdir $HIVE_HOME
RUN mkdir $HIVE_HOME/metastore
RUN mkdir $HIVE_HOME/tmp
RUN tar -xvzf hive.tar.gz -C $HIVE_HOME --strip-components 1
ENV PATH=$HIVE_HOME/bin:$PATH
RUN chown -R -L hdfs $HIVE_HOME

# Ranger section
ADD ranger-{{ ranger_version }}-hive-plugin.tar.gz /
ADD ranger-{{ ranger_version }}-admin.tar.gz /

#
ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
ENV PATH=/hadoop/bin:$PATH
ENV HADOOP_CONF_DIR=/hadoop/etc/hadoop
ENV HIVE_CONF_DIR=$HADOOP_CONF_DIR
