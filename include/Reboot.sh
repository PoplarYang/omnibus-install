#!/bin/bash

Reboot(){
    while :; do echo
      echo "${CMSG}Please restart the server and see if the services start up fine.${CEND}"
      read -t 15 -p "Do you want to restart OS ? (Default n press Enter) [y/n]: " restart_yn
      [ -z $restart_yn ] && restart_yn=n
      if [[ ! "${restart_yn}" =~ ^[y,n]$ ]]; then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
      else
        break
      fi
    done
    echo

    [ "${restart_yn}" == 'y' ] && reboot
}