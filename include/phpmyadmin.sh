#!/bin/bash
#
# modify by hiyang @ 2016-12-19
#

Install_phpMyAdmin() {
  pushd ${oneinstack_dir}/src
  tar xzf phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz
  /bin/mv phpMyAdmin-${phpMyAdmin_version}-all-languages ${wwwroot_dir}/default/phpMyAdmin
  /bin/cp ${wwwroot_dir}/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
  mkdir ${wwwroot_dir}/default/phpMyAdmin/{upload,save}
  sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
  sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
  sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'$(cat /dev/urandom | head -1 | base64 | head -c 45)\';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
  chown -R ${run_user}.$run_user ${wwwroot_dir}/default/phpMyAdmin
  popd
}
