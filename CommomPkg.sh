#!/bin/bash
#
# modify by hiyang @ 2016-12-29
# for some common packages install

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                 OneinStack for CentOS/RadHat 5+                     #
# for initial server system sshd/iptables/selinux/network/packages    #
#######################################################################
"

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

YumList="coreutils ccze dstat elinks htop iptraf-ng lsof lrzsz lynx mtr man nmon nmap ncdu nload screen saidar strace tree telnet tcpdump vim-enhanced procps-ng zip unzip"

for PackageName in $YumList; do
    if rpm -q $PackageName &> /dev/null; then
        echo "$PackageName is installed"
    else
        yum install -y $PackageName &> /dev/null && echo "$PackageName is installed" || echo "$PackageName isnot installed"
    fi
done