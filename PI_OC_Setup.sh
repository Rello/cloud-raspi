#!/bin/bash
#

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
