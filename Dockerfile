FROM centos:6
#VOLUME /var/lib/pgsql/9.4/data
RUN rpm -Uvh https://yum.postgresql.org/9.4/redhat/rhel-6.6-x86_64/pgdg-centos94-9.4-3.noarch.rpm && \
	yum -y update && \
	yum install -y postgresql94-server postgresql94-contrib
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
USER 26
COPY run-postgresql.sh /usr/bin/
COPY install.sql /var/lib/pgsql/9.4/
CMD run-postgresql.sh
