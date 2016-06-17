wwpath='/var/www'
ocpath='/var/www/owncloud'
ocdata='/var/owncloud'
htuser='www-data'

echo "start OC update"

cd ${ocpath}
sudo -u www-data php occ -V
read -p "Welche Zielversion? z.B. 8.0.7: " DLVERSION
sudo -u www-data php occ maintenance:mode --on
sudo -u www-data php occ app:disable contacts
sudo -u www-data php occ app:disable calendar

cd ${wwpath}
sudo rm -rf ${wwpath}/owncloud-backup
sudo mkdir ${wwpath}/owncloud-backup
sudo chmod 777 ${wwpath}/owncloud-backup/
sudo cp ${ocpath}/config/config.php ${wwpath}/owncloud-backup/
sudo cp -R ${ocpath}/themes/ ${wwpath}/owncloud-backup/
echo "files copied"

sudo mysqldump --opt --user=root --password=root --databases owncloud | gzip -c -9 > ${wwpath}/owncloud-backup/owncloud_DB.gz
echo "DB copied"

wget -O ${wwpath}/owncloud-latest.tar.bz2 http://download.owncloud.org/community/owncloud-${DLVERSION}.tar.bz2
sudo rm -rf ${wwpath}/owncloud

cd ${wwpath}
tar -xjvf owncloud-latest.tar.bz2
sudo cp ${wwpath}/owncloud-backup/config.php ${ocpath}/config/
sudo cp -R ${wwpath}/owncloud-backup/themes/ ${ocpath}/ 
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
sudo -u www-data php occ upgrade
#sudo -u www-data php occ app:enable contacts
#sudo -u www-data php occ app:enable calendar
sudo -u www-data php occ maintenance:mode --off
sudo -u www-data php occ -V
