#!/bin/bash

InstallPackages(){
  echo
  while :; do
    read -t 15 -p "Whether to install dependencies packages?(Default n press Enter) [y/n] " PACKAGES_yn
    [ -z $PACKAGES_yn ] && PACKAGES_yn=n
    if [[ ! $PACKAGES_yn =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      if [ "$PACKAGES_yn" == 'y' ]; then
          . ./include/check_sw.sh
          if [ "${OS}" == "CentOS" ]; then
              installDepsCentOS 2>&1 | tee ${oneinstack_dir}/install.log
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