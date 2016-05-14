#!/bin/bash

#----------- CHECK -----------
if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi
#----------- CHOICE -----------
while [[ $choice != "1" || $choice != "2" ]]; do
	read -p "Welcome !
	Make a choice between :
	1) create the NAT router
	2) delete the NAT router" choice
done

case $choice in
		"1")
			sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
			sysctl -p
			iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
			/sbin/iptables-save > /etc/iptables_rules.save
			read -p "Enter your public ip : " $public_ip
			read -p "Enter the netmask of the eth0 (public) : " $public_netmask
			read -p "Enter the router's IP : " $routing
			read -p "Enter your private ip : " $private_ip
			read -p "Enter the netmask of eth1 (private) : " $private_netmask
			echo "auto eth0
			iface eth0 inet static
			address $public_ip
			netmask $public_netmask
			gateway $routing ##Ip privée du routeur physique
			post-up iptables-restore < /etc/iptables_rules.save

			auto eth1
			iface eth1 inet static
			address $private_ip
			netmask $private_netmask" > /etc/network/interfaces;
			systemctl restart networking || /etc/init.d/networking restart
			echo "Finished !"
			;;
		"2")
			sed -i 's|#net.ipv4.ip_forward=0|net.ipv4.ip_forward=0|' /etc/sysctl.conf;
			sysctl -p
			rm /etc/iptables_rules.save
			echo 'Finished !'
			;;
esac
echo "
You can exec the script again if you want modify something !";
exit 0;
