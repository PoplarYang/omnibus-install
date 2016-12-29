#!/bin/bash
#
# modify by hiyang @ 2016-12-29
# for JDK and Tomcat

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                 OneinStack for CentOS/RadHat 5+                     #
# for initial server system sshd/iptables/selinux/network/packages     #
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

# choose version
  while :; do echo
    echo 'Please select tomcat server:'
    echo -e "\t${CMSG}1${CEND}. Install Tomcat-8"
    echo -e "\t${CMSG}2${CEND}. Install Tomcat-7"
    echo -e "\t${CMSG}3${CEND}. Install Tomcat-6"
    echo -e "\t${CMSG}4${CEND}. Do not install"
    read -p "Please input a number:(Default 4 press Enter) " Tomcat_version
    [ -z "$Tomcat_version" ] && Tomcat_version=4
    if [[ ! $Tomcat_version =~ ^[1-4]$ ]]; then
      echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
    else
      [ "$Tomcat_version" != '4' -a -e "$tomcat_install_dir/conf/server.xml" ] && { echo "${CWARNING}Tomcat already installed! ${CEND}" ; Tomcat_version=Other; }
      if [ "$Tomcat_version" == '1' ]; then
        while :; do echo
          echo 'Please select JDK version:'
          echo -e "\t${CMSG}1${CEND}. Install JDK-1.8"
          echo -e "\t${CMSG}2${CEND}. Install JDK-1.7"
          read -p "Please input a number:(Default 2 press Enter) " JDK_version
          [ -z "$JDK_version" ] && JDK_version=2
          if [[ ! $JDK_version =~ ^[1-2]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1,2${CEND}"
          else
            break
          fi
        done
      elif [ "$Tomcat_version" == '2' ]; then
        while :; do echo
          echo 'Please select JDK version:'
          echo -e "\t${CMSG}1${CEND}. Install JDK-1.8"
          echo -e "\t${CMSG}2${CEND}. Install JDK-1.7"
          echo -e "\t${CMSG}3${CEND}. Install JDK-1.6"
          read -p "Please input a number:(Default 2 press Enter) " JDK_version
          [ -z "$JDK_version" ] && JDK_version=2
          if [[ ! $JDK_version =~ ^[1-3]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
          else
            break
          fi
        done
      elif [ "$Tomcat_version" == '3' ]; then
        while :; do echo
          echo 'Please select JDK version:'
          echo -e "\t${CMSG}2${CEND}. Install JDK-1.7"
          echo -e "\t${CMSG}3${CEND}. Install JDK-1.6"
          read -p "Please input a number:(Default 2 press Enter) " JDK_version
          [ -z "$JDK_version" ] && JDK_version=2
          if [[ ! $JDK_version =~ ^[2-3]$ ]]; then
            echo "${CWARNING}input error! Please only input number 2,3${CEND}"
          else
            break
          fi
        done
      fi
      break
    fi
  done

case "${JDK_version}" in
  1)
    . include/jdk-1.8.sh
    Install-JDK18 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/jdk-1.7.sh
    Install-JDK17 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/jdk-1.6.sh
    Install-JDK16 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac

case "${Tomcat_version}" in
  1)
    . include/tomcat-8.sh
    Install_Tomcat8 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/tomcat-7.sh
    Install_Tomcat7 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/tomcat-6.sh
    Install_Tomcat6 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac