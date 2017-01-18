#!/bin/bash
#
# modify by hiyang @ 2016-12-19

clear
echo "${CBLUE}               Init CentOS${CEND}"
# closed Unnecessary services and remove obsolete rpm package
echo "STEP 1: ${CMSG}closed Unnecessary services and remove obsolete rpm package${CEND}"
[ "${CentOS_RHEL_version}" == '7' ] && [ "$(systemctl is-active NetworkManager.service)" == 'active' ] && NM_flag=1
[ "${NM_flag}" == '1' ] && systemctl enable NetworkManager.service
for Service in sshd network crond iptables messagebus irqbalance syslog rsyslog;do
  chkconfig --level 3 ${Service} on 2> /dev/null
done

for Service in $(chkconfig --list | grep 3:on | awk '{print $1}' | grep -vE 'nginx|httpd|tomcat|mysqld|php-fpm|pureftpd|redis-server|memcached|supervisord|aegis|NetworkManager');do
  chkconfig --level 3 ${Service} off 2> /dev/null
done
echo -e "${CMSG}Step 1 is successfully!${CEND}\n"

# Close SELINUX
echo "STEP 2: ${CMSG}Close SELINUX${CEND}"
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
echo -e "${CMSG}Step 2 is successfully!${CEND}\n"

# Custom profile
echo "STEP 3: ${CMSG}Custom profile${CEND}"
cat > /etc/profile.d/oneinstack.sh << EOF
HISTSIZE=3000
PROMPT_COMMAND="history -a"
HISTTIMEFORMAT="%F %T \$(whoami) "
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\\\$ "

alias l='ls -AFhlt'
alias lh='l | head'
alias vi=vim
alias rz='rz -be'

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF

[ -z "$(grep ^'PROMPT_COMMAND=' /etc/bashrc)" ] && cat >> /etc/bashrc << EOF
PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });logger "[euid=\$(whoami)]":\$(who am i):[\`pwd\`]"\$msg"; }'
EOF
echo -e "${CMSG}Step 3 is successfully!${CEND}\n"

# /etc/security/limits.conf
echo "STEP 4: ${CMSG}Modify limits.conf${CEND}"
[ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
sed -i '/^# End of file/,$d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
# End of file
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
echo -e "${CMSG}Step 4 is successfully!${CEND}\n"

# /etc/hosts
echo "STEP 4: ${CMSG}Modify hosts and timezone and update time${CEND}"
[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@127.0.0.1.*localhost@&\n127.0.0.1 $(hostname)@g" /etc/hosts

# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Update time
ntpdate pool.ntp.org
[ ! -e "/var/spool/cron/root" -o -z "$(grep 'ntpdate' /var/spool/cron/root)" ] && { echo "*/20 * * * * $(which ntpdate) pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/root;chmod 600 /var/spool/cron/root; }
echo -e "${CMSG}Step 4 is successfully!${CEND}\n"

# Set DNS
#cat > /etc/resolv.conf << EOF
#nameserver 114.114.114.114
#nameserver 8.8.8.8
#EOF

# ip_conntrack table full dropping packets
[ ! -e "/etc/sysconfig/modules/iptables.modules" ] && { echo modprobe ip_conntrack > /etc/sysconfig/modules/iptables.modules; chmod +x /etc/sysconfig/modules/iptables.modules; }
modprobe ip_conntrack
echo options nf_conntrack hashsize=131072 > /etc/modprobe.d/nf_conntrack.conf

# /etc/sysctl.conf
echo "STEP 5: ${CMSG}Modify sysctl.conf${CEND}"
[ ! -e "/etc/sysctl.conf_bk" ] && /bin/mv /etc/sysctl.conf{,_bk}
cat > /etc/sysctl.conf << EOF
fs.file-max=65535
net.ipv4.tcp_max_tw_buckets = 60000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.ipv4.tcp_max_syn_backlog = 65536
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
#net.ipv4.tcp_tw_len = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65000
net.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
EOF

# ipv6 is forbidden
[ "${CentOS_RHEL_version}" == '7' ] && cat >> /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
sysctl -p
echo -e "${CMSG}Step 5 is successfully!${CEND}\n"

# iptables
echo "STEP 6: ${CMSG}Modify iptables${CEND}"
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
echo -e "${CMSG}Step 6 is successfully!${CEND}\n"

if [ "${CentOS_RHEL_version}" == '5' ]; then
  sed -i 's@^[3-6]:2345:respawn@#&@g' /etc/inittab
  sed -i 's@^ca::ctrlaltdel@#&@' /etc/inittab
  sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/sysconfig/i18n
elif [ "${CentOS_RHEL_version}" == '6' ]; then
  sed -i 's@^ACTIVE_CONSOLES.*@ACTIVE_CONSOLES=/dev/tty[1-2]@' /etc/sysconfig/init
  sed -i 's@^start@#start@' /etc/init/control-alt-delete.conf
  sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/sysconfig/i18n
elif [ "${CentOS_RHEL_version}" == '7' ]; then
  sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/locale.conf
fi

. /etc/profile
