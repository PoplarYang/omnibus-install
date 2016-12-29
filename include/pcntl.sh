#!/bin/bash
#
# modify by hiyang @ 2016-12-19
#

Install_pcntl() {
  cd ${oneinstack_dir}/src
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  tar xzf php-$php54_version.tar.gz
  cd php-${php54_version}/ext/pcntl
# get php info
  ${php_install_dir}/bin/phpize
  ./configure --with-php-config=${php_install_dir}/bin/php-config
  make -j ${THREAD} && make install
  if [ -f "${phpExtensionDir}/pcntl.so" ]; then
    cat > ${php_install_dir}/etc/php.d/ext-pcntl.ini << EOF
[pcntl]
extension=${phpExtensionDir}/pcntl.so
EOF
    echo "${CSUCCESS}Pcntl module installed successfully! ${CEND}"
    rm -rf php-${php54_version}
  else
    echo "${CFAILURE}pcntl module install failed, Please contact the author! ${CEND}"
  fi
}
