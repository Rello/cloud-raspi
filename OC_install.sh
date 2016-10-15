wwpath='/var/www'
ocpath='/var/www/owncloud'
ocdata='/var/owncloud'
htuser='www-data'

echo "start OC update"

cd ${ocpath}
read -p "Welche Zielversion? z.B. 9.1.1: " DLVERSION

wget -O ${wwpath}/owncloud-latest.tar.bz2 http://download.owncloud.org/community/owncloud-${DLVERSION}.tar.bz2
sudo rm -rf ${wwpath}/owncloud

cd ${wwpath}
tar -xjvf owncloud-latest.tar.bz2
sudo rm ${wwpath}/owncloud-latest.tar.bz2

sudo find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
sudo find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750
sudo chown -R root:${htuser} ${ocpath}/
sudo chown -R ${htuser}:${htuser} ${ocpath}/apps/
sudo chown -R ${htuser}:${htuser} ${ocpath}/config/

find ${ocdata}/ -type f -print0 | xargs -0 chmod 0640
find ${ocdata}/ -type d -print0 | xargs -0 chmod 0750
sudo chown -R ${htuser}:${htuser} ${ocdata}/

cd ${ocpath}
