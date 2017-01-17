#!/bin/bash
#
# modify by hiyang @ 2016-12-19
#

Download_src() {
  [ -s "${src_url##*/}" ] && echo "[${CMSG}${src_url##*/}${CEND}] found" || { wget --tries=6 -c --no-check-certificate $src_url; sleep 1; }
  if [ ! -e "${src_url##*/}" ]; then
    echo "${CFAILURE}${src_url##*/} download failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi
}
