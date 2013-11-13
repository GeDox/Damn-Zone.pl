#!/bin/sh
if [ $# -lt 2 ] ; then
echo "podaj jako pierwszy parametr nazwe uzytkownika, jako drugi parametr jego folder"
else
ftpasswd --passwd --file /etc/proftpd/ftpd.passwd --name $1  --home $2 -p  --uid 106  --gid 65534 --shell /bin/false
mkdir -p $2
chown -R proftpd:nogroup $2
chmod 751 $2
fi
