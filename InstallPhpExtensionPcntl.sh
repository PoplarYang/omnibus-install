#!/bin/bash
#
# modify by hiyang @ 2016-12-19
# Intend for installing extension pcntl.

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                 OneinStack for CentOS/RadHat 5+                     #
#                    Only Pcntl for php install                       #
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

echo 'Please select a version of the Apache that you have installed:'
echo -e "\t${CMSG}1${CEND}. apache 2.2"
echo -e "\t${CMSG}2${CEND}. apache 2.4"
read -p "Please input a number:(Default 2 press Enter) " Apache_version
[ -z "$Apache_version" ] && Apache_version=2

while :; do echo
  read -t 15 -p "Do you want to install PHP extended pcntl (Default n press Enter) [y/n]: " PHP_yn
  [ -z $PHP_yn ] && PHP_yn=n
  if [[ ! $PHP_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    if [ "$PHP_yn" == 'y' ]; then
      [ -e "$php_install_dir/bin/phpize" ] && { echo "${CWARNING}PHP is already installed! ${CEND}"; PHP_yn=Other; break; }
      while :; do echo
        echo 'Please select a version of the PHP that you fell like to install:'
        echo -e "\t${CMSG}1${CEND}. install php-5.3"
        echo -e "\t${CMSG}2${CEND}. install php-5.4"
        echo -e "\t${CMSG}3${CEND}. install php-5.5"
        echo -e "\t${CMSG}4${CEND}. install php-5.6"
        echo -e "\t${CMSG}5${CEND}. install php-7.0"
        echo -e "\t${CMSG}6${CEND}. install php-7.1"
        read -p "Please input a number:(Default 4 press Enter) " PHP_version
        [ -z "$PHP_version" ] && PHP_version=4
        if [[ ! $PHP_version =~ ^[1-6]$ ]]; then
          echo "${CWARNING}input error! Please only input number 1,2,3,4,5,6${CEND}"
        else
          break
        fi
      done
    fi
    break
  fi
done

# get memory limit
. include/memory.sh

# PHP
case "${PHP_version}" in
  1)
    . include/php-5.3-pcntl.sh
    Install_PHP53 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/php-5.4-pcntl.sh
    Install_PHP54 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/php-5.5-pcntl.sh
    Install_PHP55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    . include/php-5.6-pcntl.sh
    Install_PHP56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  5)
    . include/php-7.0-pcntl.sh
    Install_PHP70 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  6)
    . include/php-7.1-pcntl.sh
    Install_PHP71 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac

# for pcntl extension
. include/pcntl.sh
Install_pcntl 2>&1 | tee -a $oneinstack_dir/install.log