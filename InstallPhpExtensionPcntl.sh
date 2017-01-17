#!/bin/bash
#
# modify by hiyang @ 2016-12-19
# Intend for installing extension pcntl for nyjc after php installed.

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                 OneinStack for CentOS/RadHat 5+                     #
#             Only Pcntl for php install and Other Extension          #
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
        echo 'Please select a version of the PHP that you have installed:'
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

          # ZendGuardLoader
          if [ "$PHP_version" != '5' -a "$PHP_cache" != '1' -a "${armPlatform}" != "y" ]; then
            while :; do echo
              read -p "Do you want to install ZendGuardLoader? [y/n]: " ZendGuardLoader_yn
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
              read -p "Do you want to install ionCube? [y/n]: " ionCube_yn
              if [[ ! $ionCube_yn =~ ^[y,n]$ ]]; then
                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
              else
                break
              fi
            done
          fi

          # ImageMagick or GraphicsMagick
          while :; do echo
            read -p "Do you want to install ImageMagick or GraphicsMagick? [y/n]: " Magick_yn
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
esac

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

# ionCube
if [ "$ionCube_yn" == 'y' ]; then
  . include/ioncube.sh
  Install_ionCube 2>&1 | tee -a $oneinstack_dir/install.log
fi

# ZendGuardLoader (php <= 5.6)
if [ "$ZendGuardLoader_yn" == 'y' ]; then
  . include/ZendGuardLoader.sh
  Install_ZendGuardLoader 2>&1 | tee -a $oneinstack_dir/install.log
fi

# for pcntl extension
. include/pcntl.sh
Install_pcntl 2>&1 | tee -a $oneinstack_dir/install.log