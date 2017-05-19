FROM centos:6
#VOLUME /var/lib/pgsql/9.4/data
COPY	fix-permissions /usr/bin/
RUN rpm -Uvh https://yum.postgresql.org/9.4/redhat/rhel-6.6-x86_64/pgdg-centos94-9.4-3.noarch.rpm && \
	yum -y update && \
	yum install -y postgresql94-server postgresql94-contrib wget cmake perl && \
        rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/nss_wrapper-1.0.3-2.el6.x86_64.rpm
RUN  	mkdir -p /var/lib/pgsql/9.4/user && \
	mkdir -p /var/lib/pgsql/9.4/data && \
	fix-permissions /var/lib/pgsql && \
	fix-permissions /usr/pgsql-9.4 && \
	chown -R postgres:root /var/lib/pgsql

COPY java /opt/java/
RUN  ln -s /opt/java/jre/lib/amd64/server/libjvm.so /lib64/libjvm.so
ENV JAVA_HOME /opt/java 
ENV PATH $JAVA_HOME/bin:$PATH
ENV CLASSPATH .:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tool.jar
 
COPY pljava.jar /usr/pgsql-9.4/lib/
COPY pljava.so /usr/pgsql-9.4/lib/
RUN service postgresql-9.4 initdb
RUN echo "work_mem = 5MB" >> /var/lib/pgsql/9.4/data/postgresql.conf && \
    echo "listen_addresses = '*'" >> /var/lib/pgsql/9.4/data/postgresql.conf && \ 
    echo "pljava.classpath='/usr/pgsql-9.4/lib/pljava.jar'" >> /var/lib/pgsql/9.4/data/postgresql.conf && \
    echo "host	all	all	0.0.0.0/0	md5" >> /var/lib/pgsql/9.4/data/pg_hba.conf
EXPOSE 5432
ENV  PATH /usr/pgsql-9.4/bin:$PATH
ENV  PGDATA /var/lib/pgsql/9.4/data/user
ENV  HOME /var/lib/pgsql
RUN  chmod -R 777 /var/lib/pgsql/9.4/*
USER postgres
COPY run-postgresql.sh /usr/bin/
COPY install.sql /var/lib/pgsql/9.4/
CMD run-postgresql.sh
