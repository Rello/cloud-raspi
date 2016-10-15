#!/bin/bash
#
# *******************
# Set basic variables
# *******************

# Password & User for Samba
	PASS="admin"
	LOGIN="admin"
# Password & User for Samba


read -p "Full-Auto-Setup or step-by-step? (full/part) " x
if [ "$x" = "full" ]; then
	APTOPTION="-y"
	FULL="yes"
else
	FULL="no"
fi

# ============================================================
# Set hostname
# ============================================================
hostn=$(cat /etc/hostname)
read -p "change current hostname $hostn ? (y/n) " x
if [ "$x" = "y" ]
then
	echo "     changing hostename"
	read -r -p "     Enter new hostname: " newhost
	sed -i 's/'"$hostn"'/'"$newhost"'/g' /etc/hostname
	hostn=$(cat /etc/hostname)
fi

# ============================================================
# Configure timezone and locale
# ============================================================
if [ "$FULL" = "yes" ]; then
	x="y"
else
	read -p "set timezone&locale? (y/n) " x
fi
if [ "$x" = "y" ]; then
	echo "Europe/Berlin" > /etc/timezone
	dpkg-reconfigure -f noninteractive tzdata
	sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
	echo 'LANG="de_DE.UTF-8"'>/etc/default/locale
	dpkg-reconfigure --frontend=noninteractive locales
	update-locale LANG="de_DE.UTF-8"
	echo "     locales set"
fi

# ============================================================
# expand filesystem
# /etc/fstab: add tmpfs for /var/tmp and /var/log
# set PI2 to 1GHZ and gpu_memory to 16 for headless usage
# ============================================================
if [ "$FULL" = "yes" ]; then
	x="y"
else
	read -p "modify /etc/fstab and boot.txt? (y/n) " x
fi
if [ "$x" = "y" ]
then
	raspi-config --expand-rootfs
	echo -e "tmpfs\t/var/tmp\ttmpfs\tdefaults,noatime,nosuid,size=200m\t0\t0" >> /etc/fstab
	echo -e "tmpfs\t/var/log\ttmpfs\tdefaults,noatime,nosuid,size=100m\t0\t0" >> /etc/fstab
	mount -a
	grep -q -F 'arm_freq=1000' /boot/config.txt || echo 'arm_freq=1000' >> /boot/config.txt
	grep -q -F 'core_freq=450' /boot/config.txt || echo 'core_freq=450' >> /boot/config.txt
	grep -q -F 'sdram_freq=450' /boot/config.txt || echo 'sdram_freq=450' >> /boot/config.txt
	grep -q -F 'gpu_mem=16' /boot/config.txt || echo 'gpu_mem=16' >> /boot/config.txt
	grep -q -F 'device_tree=' /boot/config.txt || echo 'device_tree=' >> /boot/config.txt
	echo "     /etc/fstab and boot.txt modified"
fi


# ============================================================
# Cleanup obsolete packages and install required ones
# ============================================================
if [ "$FULL" = "yes" ]; then
	x="y"
else
	read -p "prepare OS? (y/n) " x
fi
if [ "$x" = "y" ]
then
	echo -e "deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi" >>/etc/apt/sources.list
	echo -e "Package: *\nPin: release n=jessie\nPin-Priority: 600" >/etc/apt/preferences
	echo "     apt: source list patched for PHP7"


	apt-get ${APTOPTION} update && apt-get ${APTOPTION} dist-upgrade && apt-get ${APTOPTION} autoremove
	echo "     apt: removed obsolete packages"
	
	echo mysql-server mysql-server/root_password password root | sudo debconf-set-selections
	echo mysql-server mysql-server/root_password_again password root | sudo debconf-set-selections
	
	apt-get ${APTOPTION} install nginx-full mysql-server samba samba-common-bin smbclient rpi-update
	echo "     apt: installed nginx & Samba"

	apt-get ${APTOPTION} install -t stretch php7.0 php7.0-curl php7.0-gd php7.0-fpm php7.0-cli php7.0-opcache php7.0-mbstring php7.0-xml php7.0-zip php7.0-mysql php-apcu php-apcu-bc
	echo "     apt: installed php7"
		
	apt-get ${APTOPTION} autoremove
	apt-get ${APTOPTION} clean
	echo "     apt: clean-ed"

		sed -i 's/weekly/daily/g' /etc/logrotate.d/nginx
		sed -i 's/rotate 52/rotate 31/g' /etc/logrotate.d/nginx
		sed -i 's/nginx rotate/nginx reload/g' /etc/logrotate.d/nginx
		rm -r /home/pi/*
	
		sed -i 's/^max_execution_time.*/max_execution_time = 600/g' /etc/php/7.0/fpm/php.ini
		sed -i 's/^max_input_time.*/max_input_time = 600/g' /etc/php/7.0/fpm/php.ini
		sed -i 's/^memory_limit.*/memory_limit = 256M/g' /etc/php/7.0/fpm/php.ini
		sed -i 's/^post_max_size.*/post_max_size = 1024M/g' /etc/php/7.0/fpm/php.ini
		sed -i 's/^upload_max_filesize.*/upload_max_filesize = 1024M/g' /etc/php/7.0/fpm/php.ini
		sed -i 's#;upload_tmp_dir =#upload_tmp_dir = /var/tmp#g' /etc/php/7.0/fpm/php.ini
		sed -i 's#;env\[#env\[#g' /etc/php/7.0/fpm/pool.d/www.conf
		echo -e "apc.enabled = 1\napc.enable_cli = 1" >>/etc/php/7.0/cli/php.ini
		echo -e "apc.enabled = 1\napc.include_once_override = 0\napc.shm_size = 256M" >>/etc/php/7.0/fpm/php.ini
		sed -i 's/#   security = user/   security = user/g' /etc/samba/smb.conf
		echo -e "[www]\npath = /var/www\nwriteable = yes\nguest ok  = no" >>/etc/samba/smb.conf
	echo "     modified system files from php and samba"
fi

# ============================================================
# Set OS and Samba user "admin"
# ============================================================
if [ "$FULL" = "yes" ]; then
	x="y"
else
	read -p "create -admin- users for OS and Samba? (y/n) " x
fi
if [ "$x" = "y" ]
then
	echo "     creating admin users"
	useradd -ou 0 -g 0 $LOGIN
	echo -ne "$PASS\n$PASS" | (sudo passwd $LOGIN)
	echo -ne "$PASS\n$PASS" | smbpasswd -as $LOGIN
fi

# ============================================================
# Done! Reboot!
# ============================================================
if [ "$FULL" = "yes" ]; then
	x="y"
else
	read -p "reboot? (y/n) " x
fi
if [ "$x" = "y" ]
then
	reboot -h now
fi
