#!/bin/bash
#
# modify by hiyang @ 2016-12-19
#

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                 OneinStack odm for CentOS/RadHat 5+                 #
#######################################################################
"

# get pwd
sed -i "s@^oneinstack_dir.*@oneinstack_dir=$(pwd)@" ./options.conf

. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/memory.sh
. ./include/check_os.sh
. ./include/check_download.sh
. ./include/download.sh
. ./include/get_char.sh

if [ "${CentOS_RHEL_version}" == '7' ]; then
  yum -y install iptables-services
  systemctl mask firewalld.service
  systemctl enable iptables.service
fi

# iptables
echo "${CMSG}Modify iptables${CEND}"
if [ -e "/etc/sysconfig/iptables" ] && [ -n "$(grep '^:INPUT DROP' /etc/sysconfig/iptables)" -a -n "$(grep 'NEW -m tcp --dport 22 -j ACCEPT' /etc/sysconfig/iptables)" -a -n "$(grep 'NEW -m tcp --dport 80 -j ACCEPT' /etc/sysconfig/iptables)" ]; then
  IPTABLES_STATUS=yes
else
  IPTABLES_STATUS=no
fi

if [ "$IPTABLES_STATUS" == "no" ]; then
  [ -e "/etc/sysconfig/iptables" ] && /bin/mv /etc/sysconfig/iptables{,_bk}
  cat > /etc/sysconfig/iptables << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:syn-flood - [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/sec --limit-burst 10 -j ACCEPT
-A INPUT -f -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
-A syn-flood -j REJECT --reject-with icmp-port-unreachable
COMMIT
EOF
fi

FW_PORT_FLAG=$(grep -ow "dport ${SSH_PORT}" /etc/sysconfig/iptables)
[ -z "${FW_PORT_FLAG}" -a "${SSH_PORT}" != "22" ] && sed -i "s@dport 22 -j ACCEPT@&\n-A INPUT -p tcp -m state --state NEW -m tcp --dport ${SSH_PORT} -j ACCEPT@" /etc/sysconfig/iptables
service iptables restart
service sshd restart
echo -e "${CMSG}successfully!${CEND}\n"