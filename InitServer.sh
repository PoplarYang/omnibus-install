#!/bin/bash
#
# modify by hiyang @ 2016-12-29
# for initial server system only

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                 OneinStack for CentOS/RadHat 5+                     #
# for initial server system sshd/iptables/selinux/network/packages    #
#######################################################################
"

# get pwd
sed -i "s@^oneinstack_dir.*@oneinstack_dir=`pwd`@" ./options.conf

. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

# Use default SSH port 22. If you use another SSH port on your server
. /include/init_sshd.sh
InitSshd

#+++++++++++++++++++++++++++++++++++  End of Function  ++++++++++++++++++++++++++++++++++++++

# get the IP information
IPADDR=`./include/get_ipaddr.py`
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
IPADDR_COUNTRY_ISP=`./include/get_ipaddr_state.py $PUBLIC_IPADDR`
IPADDR_COUNTRY=`echo $IPADDR_COUNTRY_ISP | awk '{print $1}'`
[ "`echo $IPADDR_COUNTRY_ISP | awk '{print $2}'`"x == '1000323'x ] && IPADDR_ISP=aliyun

#----------------------------------  Start of Function  -------------------------------------
# Check binary dependencies packages
. ./include/InstallPackages.sh
InstallPackages
#+++++++++++++++++++++++++++++++++++  End of Function  ++++++++++++++++++++++++++++++++++++++

#----------------------------------  Start of Function  -------------------------------------
# init
. ./include/CustomizeOS.sh
CustomizeOS
#+++++++++++++++++++++++++++++++++++  End of Function  ++++++++++++++++++++++++++++++++++++++

#----------------------------------  Start of Function  -------------------------------------
# whether to restart OS
. ./include/Reboot.sh
Reboot
#+++++++++++++++++++++++++++++++++++  End of Function  ++++++++++++++++++++++++++++++++++++++