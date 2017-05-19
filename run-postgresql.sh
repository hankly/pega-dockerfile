#!/bin/bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
grep -v ^postgres /etc/passwd > "$HOME/9.4/user/passwd"
echo   "postgres:x:${USER_ID}:${GROUP_ID}:PostgreSQL Server:${HOME}:/bin/bash" >> "$HOME/9.4/user/passwd"
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWORD=${HOME}/9.4/user/passwd
export NSS_WRAPPER_GROUP=/etc/group

echo -n "Initialize postgresql"
if [ ! -d /var/lib/pgsql/9.4/data/userdata/ ];then
	echo -n "userdata dir not exists"
	mkdir /var/lib/pgsql/9.4/data/userdata/
	chmod 700 /var/lib/pgsql/9.4/data/userdata/
fi

if [ -f /var/lib/pgsql/9.4/data/userdata/finnish ];then
	echo "data has exists"
else
	rm -rf /var/lib/pgsql/9.4/data/userdata/*
	cd /var/lib/pgsql/9.4/data/userdata/
	wget -r -nH --cut-dirs=1 . http://pegadata.gl-internal.huawei.com/pega_data/
	touch finnish
fi
echo -n "start postgres daemon"
exec postgres "$@"
