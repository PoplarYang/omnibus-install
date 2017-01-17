#!/bin/bash

CustomizeOS(){
    echo
    while :; do
      read -t 15 -p "Do you want to init server? (Default n press Enter) [y/n]: " init_yn
      [ -z $init_yn ] && init_yn=n
      if [[ ! $init_yn =~ ^[y,n]$ ]]; then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
      else
        if [ "$init_yn" == 'y' ]; then
            . ./include/memory.sh
            if [ "${OS}" == "CentOS" ]; then
                . include/init_CentOS.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
                [ -n "$(gcc --version | head -n1 | grep '4\.1\.')" ] && export CC="gcc44" CXX="g++44"
            else
                echo "${CWARNING}Unkown system operation!!!${CEND}"
            fi
        else
            break
        fi
        break
      fi
    done
    echo
}