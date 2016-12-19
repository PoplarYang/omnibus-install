#!/bin/bash
#
# modify by hiyang @ 2016-12-19
#

installBoost() {
  pushd ${oneinstack_dir}/src
  if [ ! -e "/usr/local/lib/libboost_system.so" ]; then
    boostVersion2=$(echo ${boost_version} | awk -F. '{print $1}')_$(echo ${boost_version} | awk -F. '{print $2}')_$(echo ${boost_version} | awk -F. '{print $3}')
    tar xvf boost_${boostVersion2}.tar.gz
    pushd boost_${boostVersion2}
    ./bootstrap.sh
    ./bjam --prefix=/usr/local
    ./b2 install
    popd
  fi
  if [ -e "/usr/local/lib/libboost_system.so" ]; then
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
    echo "${CSUCCESS}Boost installed successfully! ${CEND}"
    rm -rf boost_${boostVersion2}
  else
    echo "${CFAILURE}Boost installed failed, Please contact the author! ${CEND}"
  fi
  popd
}
