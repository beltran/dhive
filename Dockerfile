FROM centos:7

RUN yum -y install krb5-server krb5-workstation
RUN yum -y install java-1.8.0-openjdk-headless
RUN yum -y install apache-commons-daemon-jsvc
RUN yum install net-tools -y
RUN yum install telnet telnet-server -y
RUN yum -y install which

RUN sed -i -e 's/#//' -e 's/default_ccache_name/# default_ccache_name/' /etc/krb5.conf

RUN useradd -u 1098 hdfs

ADD hadoop-2.7.6.tar.gz /
RUN ln -s hadoop-2.7.6 hadoop
RUN chown -R -L hdfs /hadoop


COPY core-site.xml /hadoop/etc/hadoop/
COPY hdfs-site.xml /hadoop/etc/hadoop/
COPY ssl-server.xml /hadoop/etc/hadoop/
COPY yarn-site.xml /hadoop/etc/hadoop/
COPY tez-site.xml /hadoop/etc/hadoop/

COPY hadoop-env.sh /hadoop/etc/hadoop/
COPY yarn-env.sh /hadoop/etc/hadoop/

COPY start-namenode.sh /
COPY start-datanode.sh /
COPY start-resourcemanager.sh /
COPY start-nodemanager.sh /
COPY populate-data.sh /
COPY run-and-install-tez.sh /
COPY start-kdc.sh /

COPY people.json /
COPY people.txt /

ENV TEZ_CONF_DIR=/hadoop/etc/hadoop/
ENV TEZ_JARS=/tez_jars
COPY tez.tar.gz /
RUN mkdir $TEZ_JARS
RUN tar -xvzf tez.tar.gz -C $TEZ_JARS

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
ENV PATH=/hadoop/bin:$PATH
ENV HADOOP_CONF_DIR=/hadoop/etc/hadoop
