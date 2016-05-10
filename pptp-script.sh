#!/bin/bash

#########################################################
# This script will create and configure a pptpd server  #
#                                                       #
#                        Created by                     #
#                       Dumitru Vulpe                   #
#                         22/2/2016                     #
#########################################################

echo "What username do you want?"
read uname
echo "What password do you want?"
read passw


echo "Intalling the pptpd server"
apt-get install pptpd

echo "Adding the ip ranges"
echo "localip 10.0.0.1" >> /etc/pptpd.conf
echo "remoteip 10.0.0.100-200" >> /etc/pptpd.conf


echo "Setting up the chap-secrets file"
echo "$uname        pptpd   $passw   *" >> /etc/ppp/chap-secrets

echo "Adding the dns name options"
#I'm using open dns for this
echo "ms-dns 208.67.222.222" >> /etc/ppp/pptpd-options
echo "ms-dns 208.67.220.220" >> /etc/ppp/pptpd-options

echo "Setting up forwarding"
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

echo "Setting up NAT"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && iptables-save

echo "#!/bin/sh -e" > /etc/rc.local
echo "iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE" >> /etc/rc.local
echo "iptables -I INPUT -s 10.0.0.0/8 -i ppp0 -j ACCEPT" >> /etc/rc.local
echo "iptables --append FORWARD --in-interface eth0 -j ACCEPT" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

echo "Restarting the pptpd server"
/etc/init.d/pptpd restart

sysctl -p

echo "Everything done"
echo "A system restart might be needed"
