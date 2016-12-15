#!/bin/bash
# 
# modified by yang @ 2016-12-13.
#       https://github.com/lj2007331/oneinstack

installDepsCentOS() {
  clear
  sed -i 's@^exclude@#exclude@' /etc/yum.conf
  yum clean all
  echo "It will take a long time."
  yum makecache
  # Uninstall the conflicting packages
  echo "${CMSG}Removing the conflicting packages...${CEND}"
  if [ "${CentOS_RHEL_version}" == '7' ]; then
    yum -y groupremove "Basic Web Server" "MySQL Database server" "MySQL Database client" "File and Print Server"
    yum -y install iptables-services
    systemctl mask firewalld.service
    systemctl enable iptables.service
  elif [ "${CentOS_RHEL_version}" == '6' ]; then
    yum -y groupremove "FTP Server" "PostgreSQL Database client" "PostgreSQL Database server" "MySQL Database server" "MySQL Database client" "Web Server" "Office Suite and Productivity" "E-mail server" "Ruby Support" "Printing client" &> /dev/null && echo "${CMSG}Uninstall the conflicting packages successfully${CEND}"
  elif [ "${CentOS_RHEL_version}" == '5' ]; then
    yum -y groupremove "FTP Server" "Windows File Server" "PostgreSQL Database" "News Server" "MySQL Database" "DNS Name Server" "Web Server" "Dialup Networking Support" "Mail Server" "Ruby" "Office/Productivity" "Sound and Video" "Printing Support" "OpenFabrics Enterprise Distribution" &> /dev/null && echo "${CMSG}Uninstall the conflicting packages successfully${CEND}"
  fi

  echo "${CMSG}Installing dependencies packages...${CEND}"
  yum check-update
  # Install needed packages
  pkgList="deltarpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel zip unzip ntpdate sysstat patch bc expect rsync git lsof lrzsz wget"
  for Package in ${pkgList}; do
    yum -y install ${Package} &> /dev/null && echo "${CMSG}install packages [ ${Package} ] successfully${CEND}"
  done

  yum -y update bash openssl glibc &> /dev/null && echo "${CMSG}install packages [ bash openssl glibc ] successfully${CEND}"

  # use gcc-4.4
  if [ -n "$(gcc --version | head -n1 | grep '4\.1\.')" ]; then
    yum -y install gcc44 gcc44-c++ libstdc++44-devel &> /dev/null && echo "${CMSG}install packages [ gcc-4.4 ] successfully${CEND}" 
    export CC="gcc44" CXX="g++44"
  fi
}

installDepsBySrc() {
  pushd ${oneinstack_dir}/src

  if [ "${OS}" == "Ubuntu" ]; then
    if [[ "${Ubuntu_version}" =~ ^14$|^15$ ]]; then
      # Install bison on ubt 14.x 15.x
      tar xzf bison-${bison_version}.tar.gz
      pushd bison-${bison_version}
      ./configure
      make -j ${THREAD} && make install
      popd
      rm -rf bison-${bison_version}
    fi
  elif [ "${OS}" == "CentOS" ]; then
    # Install tmux
    if [ ! -e "$(which tmux)" ]; then
      # Install libevent first
      tar xzf libevent-${libevent_version}.tar.gz
      pushd libevent-${libevent_version}
      ./configure
      make -j ${THREAD} && make install
      popd
      rm -rf libevent-${libevent_version}

      tar xzf tmux-${tmux_version}.tar.gz
      pushd tmux-${tmux_version}
      CFLAGS="-I/usr/local/include" LDFLAGS="-L//usr/local/lib" ./configure
      make -j ${THREAD} && make install
      popd
      rm -rf tmux-${tmux_version}

      if [ "${OS_BIT}" == "64" ]; then
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
      else
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
      fi
    fi

    # install htop
    if [ ! -e "$(which htop)" ]; then
      tar xzf htop-${htop_version}.tar.gz
      pushd htop-${htop_version}
      ./configure
      make -j ${THREAD} && make install
      popd
      rm -rf htop-${htop_version}
    fi
  else
    echo "No need to install software from source packages."
  fi
  popd
}

