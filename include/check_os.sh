#!/bin/bash
#
# modify by hiyang @ 2016-12-19
#

if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ]; then
  OS=CentOS
  [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
  [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
  [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ]; then
  OS=CentOS
  CentOS_RHEL_version=6
else
  echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
  kill -9 $$
fi

if [ "$(getconf WORD_BIT)" == "32" ] && [ "$(getconf LONG_BIT)" == "64" ]; then
  OS_BIT=64
  SYS_BIG_FLAG=x64 #jdk
  SYS_BIT_a=x86_64;SYS_BIT_b=x86_64; #mariadb
else
  OS_BIT=32
  SYS_BIG_FLAG=i586
  SYS_BIT_a=x86;SYS_BIT_b=i686;
fi

LIBC_YN=$(awk -v A=$(getconf -a | grep GNU_LIBC_VERSION | awk '{print $NF}') -v B=2.14 'BEGIN{print(A>=B)?"0":"1"}')
[ $LIBC_YN == '0' ] && GLIBC_FLAG=linux-glibc_214 || GLIBC_FLAG=linux

if uname -m | grep -Eqi "arm"; then
  armPlatform="y"
  if uname -m | grep -Eqi "armv7"; then
    TARGET_ARCH="armv7"
  elif uname -m | grep -Eqi "armv8"; then
    TARGET_ARCH="arm64"
  else
    TARGET_ARCH="unknown"
  fi
fi

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
