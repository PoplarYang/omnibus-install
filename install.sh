#!/bin/bash
#
# modify by hiyang @ 2016-12-19

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                 OneinStack for CentOS/RadHat 5+                     #
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


### Section One: Choose what you want to install
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

mkdir -p $wwwroot_dir/default $wwwlogs_dir
[ -d /data ] && chmod 755 /data

# Use default SSH port 22. If you use another SSH port on your server
. ./include/init_sshd.sh
InitSshd

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# choose Web server
while :; do echo
  read -t 15 -p "Do you want to install Web server? (Default n press Enter) [y/n]: " Web_yn
  [ -z $Web_yn ] && Web_yn=n
  if [[ ! $Web_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    if [ "$Web_yn" == 'y' ]; then
      # choose web server
      while :; do echo
        echo 'Please select Web Server:'
        echo -e "\t${CMSG}1${CEND}. Nginx Server(Nginx/Tengine/OpenResty)"
        echo -e "\t${CMSG}2${CEND}. Apache Server"
        echo -e "\t${CMSG}3${CEND}. Tomcat Server"
        echo -e "\t${CMSG}4${CEND}. Do not install"
        read -p "Please input a number:(Default 4 press Enter) " web_version
        [ -z "$web_version" ] && web_version=4
        if [[ ! $web_version =~ ^[1-4]$ ]]; then
          echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
        else
          case $web_version in
            1)
              # Nginx/Tegine/OpenResty
              while :; do echo
                echo 'Please select Nginx server:'
                echo -e "\t${CMSG}1${CEND}. Install Nginx"
                echo -e "\t${CMSG}2${CEND}. Install Tengine"
                echo -e "\t${CMSG}3${CEND}. Install OpenResty"
                echo -e "\t${CMSG}4${CEND}. Do not install"
                read -p "Please input a number:(Default 4 press Enter) " Nginx_version
                [ -z "$Nginx_version" ] && Nginx_version=4
                if [[ ! $Nginx_version =~ ^[1-4]$ ]]; then
                  echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
                else
                  [ "$Nginx_version" != '4' -a -e "$nginx_install_dir/sbin/nginx" ] && { echo "${CWARNING}Nginx already installed! ${CEND}"; Nginx_version=Other; }
                  [ "$Nginx_version" != '4' -a -e "$tengine_install_dir/sbin/nginx" ] && { echo "${CWARNING}Tengine already installed! ${CEND}"; Nginx_version=Other; }
                  [ "$Nginx_version" != '4' -a -e "$openresty_install_dir/nginx/sbin/nginx" ] && { echo "${CWARNING}OpenResty already installed! ${CEND}"; Nginx_version=Other; }
                  break
                fi
              done
              ;;
            2)
              # Apache
              while :; do echo
                echo 'Please select Apache server:'
                echo -e "\t${CMSG}1${CEND}. Install Apache-2.4"
                echo -e "\t${CMSG}2${CEND}. Install Apache-2.2"
                echo -e "\t${CMSG}3${CEND}. Do not install"
                read -p "Please input a number:(Default 3 press Enter) " Apache_version
                [ -z "$Apache_version" ] && Apache_version=3
                if [[ ! $Apache_version =~ ^[1-3]$ ]]; then
                  echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
                else
                  [ "$Apache_version" != '3' -a -e "$apache_install_dir/conf/httpd.conf" ] && { echo "${CWARNING}Aapche already installed! ${CEND}"; Apache_version=Other; }
                  break
                fi
              done
              ;;
            3)
              # Tomcat
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
              ;;
            4)
              break
              ;;
          esac
        fi
        break
      done
    fi
    break
  fi
done
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# choose database
while :; do echo
  read -t 15 -p "Do you want to install Database? (Default n press Enter) [y/n]: " DB_yn
  [ -z $DB_yn ] && DB_yn=n
  if [[ ! $DB_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    if [ "$DB_yn" == 'y' ]; then
      [ -d "$db_install_dir/support-files" ] && { echo "${CWARNING}Database already installed! ${CEND}"; DB_yn=Other; break; }
      while :; do echo
        echo 'Please select a version of the Database:'
        echo -e "\t${CMSG} 1${CEND}. Install MySQL-5.7"
        echo -e "\t${CMSG} 2${CEND}. Install MySQL-5.6"
        echo -e "\t${CMSG} 3${CEND}. Install MySQL-5.5"
        echo -e "\t${CMSG} 4${CEND}. Install MariaDB-10.1"
        echo -e "\t${CMSG} 5${CEND}. Install MariaDB-10.0"
        echo -e "\t${CMSG} 6${CEND}. Install MariaDB-5.5"
        echo -e "\t${CMSG} 7${CEND}. Install Percona-5.7"
        echo -e "\t${CMSG} 8${CEND}. Install Percona-5.6"
        echo -e "\t${CMSG} 9${CEND}. Install Percona-5.5"
        echo -e "\t${CMSG}10${CEND}. Install AliSQL-5.6"
        read -p "Please input a number:(Default 2 press Enter) " DB_version
        [ -z "$DB_version" ] && DB_version=2
        if [ ${DB_version} -ge 1 >/dev/null 2>&1 -a ${DB_version} -le 10 >/dev/null 2>&1 ]; then
          while :; do
            read -p "Please input the root password of database: " dbrootpwd
            [ -n "`echo $dbrootpwd | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and & ${CEND}"; continue; }
            (( ${#dbrootpwd} >= 5 )) && sed -i "s+^dbrootpwd.*+dbrootpwd='$dbrootpwd'+" ./options.conf && break || echo "${CWARNING}database root password least 5 characters! ${CEND}"
          done
          # choose install methods
          if [[ $DB_version =~ ^[1-9]$ ]]; then
            while :; do echo
              echo "Please choose installation of the database:"
              echo -e "\t${CMSG}1${CEND}. Install database from binary package."
              echo -e "\t${CMSG}2${CEND}. Install database from source package."
              read -p "Please input a number:(Default 1 press Enter) " dbInstallMethods
              [ -z "$dbInstallMethods" ] && dbInstallMethods=1
              if [[ ! $dbInstallMethods =~ ^[1-2]$ ]]; then
                echo "${CWARNING}input error! Please only input number 1,2${CEND}"
              else
                break
              fi
            done
          fi
          break
        else
          echo "${CWARNING}input error! Please only input number 1,2,3,4,5,6,7,8,9,10${CEND}"
        fi
      done
    fi
    break
  fi
done
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# check PHP
while :; do echo
  read -t 15 -p "Do you want to install PHP? (Default n press Enter) [y/n]: " PHP_yn
  [ -z $PHP_yn ] && PHP_yn=n
  if [[ ! $PHP_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    if [ "$PHP_yn" == 'y' ]; then
      [ -e "$php_install_dir/bin/phpize" ] && { echo "${CWARNING}PHP already installed! ${CEND}"; PHP_yn=Other; break; }
      while :; do echo
        echo 'Please select a version of the PHP:'
        echo -e "\t${CMSG}1${CEND}. Install php-5.3"
        echo -e "\t${CMSG}2${CEND}. Install php-5.4"
        echo -e "\t${CMSG}3${CEND}. Install php-5.5"
        echo -e "\t${CMSG}4${CEND}. Install php-5.6"
        echo -e "\t${CMSG}5${CEND}. Install php-7.0"
        echo -e "\t${CMSG}6${CEND}. Install php-7.1"
        read -p "Please input a number:(Default 4 press Enter) " PHP_version
        [ -z "$PHP_version" ] && PHP_version=4
        if [[ ! $PHP_version =~ ^[1-6]$ ]]; then
          echo "${CWARNING}input error! Please only input number 1,2,3,4,5,6${CEND}"
        else
          while :; do echo
            read -p "Do you want to install opcode cache of the PHP? [y/n]: " PHP_cache_yn
            if [[ ! $PHP_cache_yn =~ ^[y,n]$ ]]; then
                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
            else
              if [ "$PHP_cache_yn" == 'y' ]; then
                if [ $PHP_version == 1 ]; then
                  while :; do
                    echo 'Please select a opcode cache of the PHP:'
                    echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                    echo -e "\t${CMSG}2${CEND}. Install XCache"
                    echo -e "\t${CMSG}3${CEND}. Install APCU"
                    echo -e "\t${CMSG}4${CEND}. Install eAccelerator-0.9"
                    read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                    [ -z "$PHP_cache" ] && PHP_cache=1
                    if [[ ! $PHP_cache =~ ^[1-4]$ ]]; then
                      echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
                    else
                      break
                    fi
                  done
                fi
                if [ $PHP_version == 2 ]; then
                  while :; do
                    echo 'Please select a opcode cache of the PHP:'
                    echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                    echo -e "\t${CMSG}2${CEND}. Install XCache"
                    echo -e "\t${CMSG}3${CEND}. Install APCU"
                    echo -e "\t${CMSG}4${CEND}. Install eAccelerator-1.0-dev"
                    read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                    [ -z "$PHP_cache" ] && PHP_cache=1
                    if [[ ! $PHP_cache =~ ^[1-4]$ ]]; then
                      echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
                    else
                      break
                    fi
                  done
                fi
                if [ $PHP_version == 3 ]; then
                  while :; do
                    echo 'Please select a opcode cache of the PHP:'
                    echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                    echo -e "\t${CMSG}2${CEND}. Install XCache"
                    echo -e "\t${CMSG}3${CEND}. Install APCU"
                    read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                    [ -z "$PHP_cache" ] && PHP_cache=1
                    if [[ ! $PHP_cache =~ ^[1-3]$ ]]; then
                      echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
                    else
                      break
                    fi
                  done
                fi
                if [ $PHP_version == 4 ]; then
                  while :; do
                    echo 'Please select a opcode cache of the PHP:'
                    echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                    echo -e "\t${CMSG}2${CEND}. Install XCache"
                    echo -e "\t${CMSG}3${CEND}. Install APCU"
                    read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                    [ -z "$PHP_cache" ] && PHP_cache=1
                    if [[ ! $PHP_cache =~ ^[1-3]$ ]]; then
                      echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
                    else
                      break
                    fi
                  done
                fi
                if [[ $PHP_version =~ ^[5-6]$ ]]; then
                  while :; do
                    echo 'Please select a opcode cache of the PHP:'
                    echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                    echo -e "\t${CMSG}3${CEND}. Install APCU"
                    read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                    [ -z "$PHP_cache" ] && PHP_cache=1
                    if [[ ! $PHP_cache =~ ^[1,3]$ ]]; then
                      echo "${CWARNING}input error! Please only input number 1,3${CEND}"
                    else
                      break
                    fi
                  done
                fi
              fi
              break
            fi
          done

          if [ "$PHP_cache" == '2' ]; then
            while :; do
              read -p "Please input xcache admin password: " xcache_admin_pass
              (( ${#xcache_admin_pass} >= 5 )) && { xcache_admin_md5_pass=`echo -n "$xcache_admin_pass" | md5sum | awk '{print $1}'` ; break ; } || echo "${CFAILURE}xcache admin password least 5 characters! ${CEND}"
            done
          fi

          if [ "$PHP_version" != '5' -a "$PHP_cache" != '1' -a "${armPlatform}" != "y" ]; then
            while :; do echo
              read -p "Do you want to install ZendGuardLoader(Default n press Enter)? [y/n]: " ZendGuardLoader_yn
              [ -z "$ZendGuardLoader_yn" ] && ZendGuardLoader_yn=n
              if [[ ! $ZendGuardLoader_yn =~ ^[y,n]$ ]]; then
                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
              else
                break
              fi
            done
          fi

          # ionCube
          if [ "${TARGET_ARCH}" != "arm64" ]; then
            while :; do echo
              read -p "Do you want to install ionCube?(Default n press Enter) [y/n]: " ionCube_yn
              [ -z "$ionCube_yn" ] && ionCube_yn=n
              if [[ ! $ionCube_yn =~ ^[y,n]$ ]]; then
                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
              else
                break
              fi
            done
          fi

          # ImageMagick or GraphicsMagick
          while :; do echo
            read -p "Do you want to install ImageMagick or GraphicsMagick?(Default n press Enter) [y/n]: " Magick_yn
            [ -z "$Magick_yn" ] && Magick_yn=n
            if [[ ! $Magick_yn =~ ^[y,n]$ ]]; then
              echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
            else
              break
            fi
          done

          if [ "$Magick_yn" == 'y' ]; then
            while :; do
              echo 'Please select ImageMagick or GraphicsMagick:'
              echo -e "\t${CMSG}1${CEND}. Install ImageMagick"
              echo -e "\t${CMSG}2${CEND}. Install GraphicsMagick"
              read -p "Please input a number:(Default 1 press Enter) " Magick
              [ -z "$Magick" ] && Magick=1
              if [[ ! $Magick =~ ^[1-2]$ ]]; then
                echo "${CWARNING}input error! Please only input number 1,2${CEND}"
              else
                break
              fi
            done
          fi
          break
        fi
      done
    fi
    break
  fi
done
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# check phpMyAdmin
if [[ $PHP_version =~ ^[1-6]$ ]] || [ -e "$php_install_dir/bin/phpize" ]; then
  while :; do echo
    read -t 15 -p "Do you want to install phpMyAdmin? (Default n press Enter) [y/n]: " phpMyAdmin_yn
    [ -z $phpMyAdmin_yn ] && phpMyAdmin_yn=n
    if [[ ! $phpMyAdmin_yn =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      [ "$phpMyAdmin_yn" == 'y' -a -d "$wwwroot_dir/default/phpMyAdmin" ] && { echo "${CWARNING}phpMyAdmin already installed! ${CEND}"; phpMyAdmin_yn=Other; }
      break
    fi
  done
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# check Pureftpd
while :; do echo
  read -t 15 -p "Do you want to install Pure-FTPd? (Default n press Enter) [y/n]: " FTP_yn
  [ -z $FTP_yn ] && FTP_yn=n
  if [[ ! $FTP_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    [ "$FTP_yn" == 'y' -a -e "$pureftpd_install_dir/sbin/pure-ftpwho" ] && { echo "${CWARNING}Pure-FTPd already installed! ${CEND}"; FTP_yn=Other; }
    break
  fi
done
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# check redis
while :; do echo
  read -t 15 -p "Do you want to install redis? (Default n press Enter) [y/n]: " redis_yn
  [ -z $redis_yn ] && redis_yn=n
  if [[ ! $redis_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    break
  fi
done
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# check memcached
while :; do echo
  read -t 15 -p "Do you want to install memcached? (Default n press Enter) [y/n]: " memcached_yn
  [ -z $memcached_yn ] && memcached_yn=n
  if [[ ! $memcached_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    break
  fi
done
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# HHVM
while :; do echo
  read -t 15 -p "Do you want to install HHVM? (Default n press Enter) [y/n]: " HHVM_yn
  [ -z $HHVM_yn ] && HHVM_yn=n
  if [[ ! $HHVM_yn =~ ^[y,n]$ ]]; then
    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
  else
    if [ "$HHVM_yn" == 'y' ]; then
      [ -e "/usr/bin/hhvm" ] && { echo "${CWARNING}HHVM already installed! ${CEND}"; HHVM_yn=Other; break; }
      if [ "$OS" == 'CentOS' -a "$OS_BIT" == '64' ] && [ -n "`grep -E ' 7\.| 6\.[5-9]' /etc/redhat-release`" ]; then
        break
      else
        echo
        echo "${CWARNING}HHVM only support CentOS6.5+ 64bit, CentOS7 64bit! ${CEND}"
        echo "Press Ctrl+c to cancel or Press any key to continue..."
        char=`get_char`
        HHVM_yn=Other
      fi
    fi
    break
  fi
done
#------------------------------------  End  ---------------------------------------


### Section two: Install what you select, what you need do is wait.
#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# get the IP information
IPADDR=`./include/get_ipaddr.py`
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
IPADDR_COUNTRY_ISP=`./include/get_ipaddr_state.py $PUBLIC_IPADDR`
IPADDR_COUNTRY=`echo $IPADDR_COUNTRY_ISP | awk '{print $1}'`
[ "`echo $IPADDR_COUNTRY_ISP | awk '{print $2}'`"x == '1000323'x ] && IPADDR_ISP=aliyun

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# Check binary dependencies packages
. ./include/InstallPackages.sh
InstallPackages
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# CustomizeOS
. ./include/CustomizeOS.sh
CustomizeOS
#------------------------------------  End  ---------------------------------------

# Check download source packages
. ./include/check_download.sh
downloadDepsSrc=1
checkDownload 2>&1 | tee -a ${oneinstack_dir}/install.log

# Install dependencies from source package
. ./include/check_sw.sh
installDepsBySrc 2>&1 | tee -a ${oneinstack_dir}/install.log

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# jemalloc
if [[ $Nginx_version =~ ^[1-3]$ ]] || [ "$DB_yn" == 'y' -a "$DB_version" != '10' ]; then
  if [ ! -e "/usr/local/lib/libjemalloc.so" ]; then
    . include/jemalloc.sh
    Install_Jemalloc | tee -a $oneinstack_dir/install.log
  fi
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# Database
case "${DB_version}" in
  1)
    if [ "${dbInstallMethods}" == "2" ]; then
      . include/boost.sh
      installBoost 2>&1 | tee -a ${oneinstack_dir}/install.log
    fi
    . include/mysql-5.7.sh
    Install_MySQL57 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/mysql-5.6.sh
    Install_MySQL56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/mysql-5.5.sh
    Install_MySQL55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    if [ "${dbInstallMethods}" == "2" ]; then
      . include/boost.sh
      installBoost 2>&1 | tee -a ${oneinstack_dir}/install.log
    fi
    . include/mariadb-10.1.sh
    Install_MariaDB101 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  5)
    . include/mariadb-10.0.sh
    Install_MariaDB100 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  6)
    . include/mariadb-5.5.sh
    Install_MariaDB55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  7)
    if [ "${dbInstallMethods}" == "2" ]; then
      . include/boost.sh
      installBoost 2>&1 | tee -a ${oneinstack_dir}/install.log
    fi
    . include/percona-5.7.sh
    Install_Percona57 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  8)
    . include/percona-5.6.sh
    Install_Percona56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  9)
    . include/percona-5.5.sh
    Install_Percona55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  10)
    . include/alisql-5.6.sh
    Install_AliSQL56 2>&1 | tee -a $oneinstack_dir/install.log
    ;;
esac
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# Apache
if [ "$Apache_version" == '1' ]; then
  . include/apache-2.4.sh
  Install_Apache24 2>&1 | tee -a $oneinstack_dir/install.log
# add test file
  cp -rf test/full/* $wwwroot_dir/default/oka
elif [ "$Apache_version" == '2' ]; then
  . include/apache-2.2.sh
  Install_Apache22 2>&1 | tee -a $oneinstack_dir/install.log
# add test file
  cp -rf test/full/* $wwwroot_dir/default/oka
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# PHP
case "${PHP_version}" in
  1)
    . include/php-5.3.sh
    Install_PHP53 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/php-5.4.sh
    Install_PHP54 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/php-5.5.sh
    Install_PHP55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    . include/php-5.6.sh
    Install_PHP56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  5)
    . include/php-7.0.sh
    Install_PHP70 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  6)
    . include/php-7.1.sh
    Install_PHP71 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# PHP opcode cache
case "${PHP_cache}" in
  1)
    if [[ "${PHP_version}" =~ ^[1,2]$ ]]; then
      . include/zendopcache.sh
      Install_ZendOPcache 2>&1 | tee -a ${oneinstack_dir}/install.log
    fi
    ;;
  2)
    . include/xcache.sh
    Install_XCache 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/apcu.sh
    Install_APCU 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    if [[ "${PHP_version}" =~ ^[1,2]$ ]]; then
      . include/eaccelerator.sh
      Install_eAccelerator 2>&1 | tee -a ${oneinstack_dir}/install.log
    fi
    ;;
esac
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# ZendGuardLoader (php <= 5.6)
if [ "$ZendGuardLoader_yn" == 'y' ]; then
  . include/ZendGuardLoader.sh
  Install_ZendGuardLoader 2>&1 | tee -a $oneinstack_dir/install.log
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# ImageMagick or GraphicsMagick
if [ "$Magick" == '1' ]; then
  . include/ImageMagick.sh
  [ ! -d "/usr/local/imagemagick" ] && Install_ImageMagick 2>&1 | tee -a $oneinstack_dir/install.log
  [ ! -e "`$php_install_dir/bin/php-config --extension-dir`/imagick.so" ] && Install_php-imagick 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$Magick" == '2' ]; then
  . include/GraphicsMagick.sh
  [ ! -d "/usr/local/graphicsmagick" ] && Install_GraphicsMagick 2>&1 | tee -a $oneinstack_dir/install.log
  [ ! -e "`$php_install_dir/bin/php-config --extension-dir`/gmagick.so" ] && Install_php-gmagick 2>&1 | tee -a $oneinstack_dir/install.log
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# ionCube
if [ "$ionCube_yn" == 'y' ]; then
  . include/ioncube.sh
  Install_ionCube 2>&1 | tee -a $oneinstack_dir/install.log
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# Nginx server
case "${Nginx_version}" in
  1)
    . include/nginx.sh
    Install_Nginx 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/tengine.sh
    Install_Tengine 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/openresty.sh
    Install_OpenResty 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# JDK
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

# Tomcat
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
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# Pure-FTPd
if [ "${FTP_yn}" == 'y' ]; then
  . include/pureftpd.sh
  Install_PureFTPd 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# phpMyAdmin
if [ "${phpMyAdmin_yn}" == 'y' ]; then
  . include/phpmyadmin.sh
  Install_phpMyAdmin 2>&1 | tee -a ${oneinstack_dir}/install.log
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# redis
if [ "${redis_yn}" == 'y' ]; then
  . include/redis.sh
  [ ! -d "${redis_install_dir}" ] && Install_redis-server 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ -e "${php_install_dir}/bin/phpize" ] && [ ! -e "$(${php_install_dir}/bin/php-config --extension-dir)/redis.so" ] && Install_php-redis 2>&1 | tee -a ${oneinstack_dir}/install.log
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# memcached
if [ "${memcached_yn}" == 'y' ]; then
  . include/memcached.sh
  [ ! -d "${memcached_install_dir}/include/memcached" ] && Install_memcached 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ -e "${php_install_dir}/bin/phpize" ] && [ ! -e "$(${php_install_dir}/bin/php-config --extension-dir)/memcache.so" ] && Install_php-memcache 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ -e "${php_install_dir}/bin/phpize" ] && [ ! -e "$(${php_install_dir}/bin/php-config --extension-dir)/memcached.so" ] && Install_php-memcached 2>&1 | tee -a ${oneinstack_dir}/install.log
fi
#------------------------------------  End  ---------------------------------------

#+++++++++++++++++++++++++++++++++++  Start  ++++++++++++++++++++++++++++++++++++++
# index example
if [ ! -e "${wwwroot_dir}/default/index.html" -a "${Web_yn}" == 'y' ]; then
  . include/demo.sh
  DEMO 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# get web_install_dir and db_install_dir
. include/check_dir.sh

# HHVM
if [ "${HHVM_yn}" == 'y' ]; then
  . include/hhvm_CentOS.sh
  Install_hhvm_CentOS 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# Starting DB
[ -d "/etc/mysql" ] && /bin/mv /etc/mysql{,_bk}
[ -d "${db_install_dir}/support-files" -a -z "$(ps -ef | grep -v grep | grep mysql)" ] && /etc/init.d/mysqld start

echo "####################  Congratulations  ########################"
[ "${Web_yn}" == 'y' -a "${Nginx_version}" != '4' -a "${Apache_version}" == '3' ] && echo -e "\n$(printf "%-32s" "Nginx install dir":)${CMSG}${web_install_dir}${CEND}"
[ "${Web_yn}" == 'y' -a "${Nginx_version}" != '4' -a "${Apache_version}" != '3' ] && echo -e "\n$(printf "%-32s" "Nginx install dir":)${CMSG}${web_install_dir}${CEND}\n$(printf "%-32s" "Apache install  dir":)${CMSG}${apache_install_dir}${CEND}"
[ "${Web_yn}" == 'y' -a "${Nginx_version}" == '4' -a "${Apache_version}" != '3' ] && echo -e "\n$(printf "%-32s" "Apache install dir":)${CMSG}${apache_install_dir}${CEND}"
[[ "${Tomcat_version}" =~ ^[1,2]$ ]] && echo -e "\n$(printf "%-32s" "Tomcat install dir":)${CMSG}${tomcat_install_dir}${CEND}"
[ "${DB_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "Database install dir:")${CMSG}${db_install_dir}${CEND}"
[ "${DB_yn}" == 'y' ] && echo "$(printf "%-32s" "Database data dir:")${CMSG}${db_data_dir}${CEND}"
[ "${DB_yn}" == 'y' ] && echo "$(printf "%-32s" "Database user:")${CMSG}root${CEND}"
[ "${DB_yn}" == 'y' ] && echo "$(printf "%-32s" "Database password:")${CMSG}${dbrootpwd}${CEND}"
[ "${PHP_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "PHP install dir:")${CMSG}${php_install_dir}${CEND}"
[ "${PHP_cache}" == '1' ] && echo "$(printf "%-32s" "Opcache Control Panel url:")${CMSG}http://${IPADDR}/ocp.php${CEND}"
[ "${PHP_cache}" == '2' ] && echo "$(printf "%-32s" "xcache Control Panel url:")${CMSG}http://${IPADDR}/xcache${CEND}"
[ "${PHP_cache}" == '2' ] && echo "$(printf "%-32s" "xcache user:")${CMSG}admin${CEND}"
[ "${PHP_cache}" == '2' ] && echo "$(printf "%-32s" "xcache password:")${CMSG}${xcache_admin_pass}${CEND}"
[ "${PHP_cache}" == '3' ] && echo "$(printf "%-32s" "APC Control Panel url:")${CMSG}http://${IPADDR}/apc.php${CEND}"
[ "${PHP_cache}" == '4' ] && echo "$(printf "%-32s" "eAccelerator Control Panel url:")${CMSG}http://${IPADDR}/control.php${CEND}"
[ "${PHP_cache}" == '4' ] && echo "$(printf "%-32s" "eAccelerator user:")${CMSG}admin${CEND}"
[ "${PHP_cache}" == '4' ] && echo "$(printf "%-32s" "eAccelerator password:")${CMSG}eAccelerator${CEND}"
[ "${FTP_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "Pure-FTPd install dir:")${CMSG}${pureftpd_install_dir}${CEND}"
[ "${FTP_yn}" == 'y' ] && echo "$(printf "%-32s" "Create FTP virtual script:")${CMSG}./pureftpd_vhost.sh${CEND}"
[ "${phpMyAdmin_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "phpMyAdmin dir:")${CMSG}${wwwroot_dir}/default/phpMyAdmin${CEND}"
[ "${phpMyAdmin_yn}" == 'y' ] && echo "$(printf "%-32s" "phpMyAdmin Control Panel url:")${CMSG}http://${IPADDR}/phpMyAdmin${CEND}"
[ "${redis_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "redis install dir:")${CMSG}${redis_install_dir}${CEND}"
[ "${memcached_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "memcached install dir:")${CMSG}${memcached_install_dir}${CEND}"
[ "${Web_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "index url:")${CMSG}http://${IPADDR}/${CEND}"

# whether to restart OS
. ./include/Reboot.sh
Reboot