#!/bin/sh
#This is my personal installation script for when setting up my asus ac87u router with merlinwrt

{
    echo ""
    echo -n "Press Enter to continue"
    read
    clear
}

#Install menu
selection=
until [ "$selection" = "e" ]; do
    echo ""
    echo "PROGRAM MENU"
    echo "1 - Install Entware-ng"
    echo "2 - Install ab-solution"
    echo "3 - install DNSCrypt"
    echo "4 - install Scheduled led control"
    echo "5 - install mail notification from router"
    echo ""
    echo "e - exit program"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
    
	#Installs Entware
        1 ) cd /tmp
	wget -c -O entware-ngu-setup.sh http://goo.gl/hshQkA
	chmod +x ./entware-ngu-setup.sh
	./entware-ngu-setup.sh ;;

	#Installs AB-Solutions adblocker and takes care of the post-mount script
        2 ) curl -O www.ab-solution.info/releases/latest/ab-solution.sh
        cp /jffs/scripts/post-mount /jffs/scripts/post-mount-backup
        rm /jffs/scripts/post-mount
	sh ab-solution.sh
{
    echo ""
    echo -n "Press Enter to continue"
    read
}
	sed '1d' /jffs/scripts/post-mount
	cat /jffs/scripts/post-mount-backup /jffs/scripts/post-mount >> /jffs/scripts/post-mount-tmp
	rm /jffs/scripts/post-mount
	mv /jffs/scripts/post-mount-tmp /jffs/scripts/post-mount
	chmod a+rx /jffs/scripts/*;;

	#Installs dns-crypt on the router
	3 ) opkg install dnscrypt-proxy fake-hwclock
	echo "no-resolv" > /jffs/configs/dnsmasq.conf.add
	echo "server=127.0.0.1#65053" >> /jffs/configs/dnsmasq.conf.add
	echo "/opt/etc/init.d/S09dnscrypt-proxy start" >> /jffs/scripts/services-start
	service restart_dnsmasq
	/opt/etc/init.d/S09dnscrypt-proxy start;;

	#Installs the lightsoff option and sets off at 22 and on at 06
	4 ) echo 'cru a lightsoff "0 22 * * * /jffs/scripts/ledsoff.sh"' >> /jffs/scripts/services-start
	echo 'cru a lightson "0 6 * * * /jffs/scripts/ledson.sh"' >> /jffs/scripts/services-start
	chmod a+rx /jffs/scripts/services-start

	echo "#!/bin/sh" > /jffs/scripts/ledsoff.sh
	echo "nvram set led_disable=1" >> /jffs/scripts/ledsoff.sh
	echo "service restart_leds" >> /jffs/scripts/ledsoff.sh

	echo "#!/bin/sh" > /jffs/scripts/ledson.sh
	echo "nvram set led_disable=0" >> /jffs/scripts/ledson.sh
	echo "service restart_leds" >> /jffs/scripts/ledson.sh;;

	#Installs email notifier with extended version working with gmail
	5 ) wget -c -O /jffs/configs/Equifax_Secure_Certificate_Authority.pem http://www.geotrust.com/resources/root_certificates/certificates/Equifax_Secure_Certificate_Authority.pem --no-check-certificate
	rm /jffs/scripts/wlan-start
	wget -c -O /jffs/scripts/wlan-start http://github.com/rallegade/Install-script-asus-ac87u/releases/download/v1/wan-start --no-check-certificate

	echo ""
	echo -n "Enter the mail the router uses"
	echo ""
	read router_email
	sed -i "s/your-gmail-address/${router_email}/g" /jffs/scripts/wlan-start

        echo ""
        echo -n "Enter the the username for the mail the router uses"
        echo ""
        read router_username
	sed -i "s/your-gmail-username/${router_username}/g" /jffs/scripts/wlan-start

        echo ""
        echo -n "Enter the password for the mail the router uses"
        echo ""
        read router_pass
	sed -i "s/your-gmail-password/${router_pass}/g" /jffs/scripts/wlan-start

        echo ""
        echo -n "Enter the mail you want to recieve these mails on"
        echo ""
        read your_email
	sed -i "s/your-email-address/${your_email}/g" /jffs/scripts/wlan-start;;

        e ) exit ;;
        * ) echo "Please enter 1, 2, 3, 4, 5, or e"; press_enter
    esac
done
