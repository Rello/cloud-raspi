#!/bin/bash
# wget -N  https://raw.githubusercontent.com/Rello/cloud-raspi/master/miflora/setup.sh
#

apt-get update
apt-get upgrade
apt-get install python3-pip libglib2.0-dev
pip3 install bluepy
pip3 install miflora

wget -N  https://raw.githubusercontent.com/Rello/cloud-raspi/master/miflora/all_sensors.py
# python3 /home/pi/miflora/all_sensors.py

#
# make PI RO
#
# remove swap; disable checks
update-rc.d -f dphys-swapfile remove
swapoff /var/swap
rm /var/swap

sudo sh -c "grep -q -F 'exit 0' /etc/cron.hourly/fake-hwclock || sed -i '1s/^/exit 0\n/' /etc/cron.hourly/fake-hwclock"
sudo sh -c "grep -q -F 'exit 0' /etc/cron.weekly/man-db || sed -i '1s/^/exit 0\n/' /etc/cron.weekly/man-db"
sudo sh -c "grep -q -F 'exit 0' /etc/cron.daily/man-db || sed -i '1s/^/exit 0\n/' /etc/cron.daily/man-db"

# modify logrotate, php, sql ntp
sed -i 's#/usr/sbin/logrotate /etc/logrotate.conf#/usr/sbin/logrotate --state /var/log/logrotate.state /etc/logrotate.conf#g' /etc/cron.daily/logrotate

# modify fstab to put tmp into ram
sudo sh -c "echo 'tmpfs\t/var/tmp\t tmpfs\tdefaults,noatime,nosuid\t0\t0' >> /etc/fstab"
sudo sh -c "echo 'tmpfs\t/var/log\t tmpfs\tdefaults,noatime,nosuid\t0\t0' >> /etc/fstab"
sudo sh -c "echo 'tmpfs\t/tmp\t tmpfs\tdefaults,noatime,nosuid\t0\t0' >> /etc/fstab"


# sudo mount -o remount,rw /
# sudo mount -o remount,rw /boot
# sudo mount -o remount,ro /
# sudo mount -o remount,ro /boot

#* 11,17 * * * python3 /home/pi/miflora/all_sensors.py
#/etc/init.d/cron restart
