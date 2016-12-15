#!/bin/bash
# modified by hiyang @ 2016-12-14

Install_Apache24() {
  pushd ${oneinstack_dir}/src
# install pcre
  tar xzf pcre-$pcre_version.tar.gz
  pushd pcre-$pcre_version
  ./configure
  make -j ${THREAD} && make install
  popd
  id -u $run_user >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user

# install apache
  tar xzf httpd-$apache24_version.tar.gz
## copy apr and apr-util
  tar xzf apr-$apr_version.tar.gz
  tar xzf apr-util-$apr_util_version.tar.gz
  pushd httpd-$apache24_version
  [ ! -d "$apache_install_dir" ] && mkdir -p $apache_install_dir
  /bin/cp -R ../apr-$apr_version ./srclib/apr
  /bin/cp -R ../apr-util-$apr_util_version ./srclib/apr-util
## Compile apache
  LDFLAGS=-ldl ./configure --prefix=$apache_install_dir --with-mpm=prefork --with-included-apr --enable-headers --enable-deflate --enable-so --enable-dav --enable-rewrite --enable-ssl --with-ssl --enable-expires --enable-static-support --enable-suexec --enable-modules=all --enable-mods-shared=all
  make -j ${THREAD} && make install
  unset LDFLAGS
  if [ -e "$apache_install_dir/conf/httpd.conf" ]; then
    echo "${CSUCCESS}Apache installed successfully! ${CEND}"
    popd
    rm -rf httpd-$apache24_version
  else
    rm -rf $apache_install_dir
    echo "${CFAILURE}Apache install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi

# export PATH
  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$apache_install_dir/bin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $apache_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$apache_install_dir/bin:\1@" /etc/profile
  . /etc/profile

# start shell
  /bin/cp $apache_install_dir/bin/apachectl /etc/init.d/httpd
  sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
  sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
  chmod +x /etc/init.d/httpd
  [ "$OS" == 'CentOS' ] && { chkconfig --add httpd; chkconfig httpd on; }

# modify configuration
## modify user and group
  sed -i "s@^User daemon@User $run_user@" $apache_install_dir/conf/httpd.conf
  sed -i "s@^Group daemon@Group $run_user@" $apache_install_dir/conf/httpd.conf
## modify ServerName
  if [ "$Nginx_version" == '4' -a ! -e "$web_install_dir/sbin/nginx" ]; then
    sed -i 's/^#ServerName www.example.com:80/ServerName test.com:80/' $apache_install_dir/conf/httpd.conf
    TMP_PORT=80
  elif [[ $Nginx_version =~ ^[1-3]$ ]] || [ -e "$web_install_dir/sbin/nginx" ]; then
    sed -i 's/^#ServerName www.example.com:80/ServerName test.com:88/' $apache_install_dir/conf/httpd.conf
    sed -i 's@^Listen.*@Listen 127.0.0.1:88@' $apache_install_dir/conf/httpd.conf
    TMP_PORT=88
  fi
## modify addtype
  sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" $apache_install_dir/conf/httpd.conf
  sed -i "s@#AddHandler cgi-script .cgi@AddHandler cgi-script .cgi .pl@" $apache_install_dir/conf/httpd.conf

## uncomment
  sed -ri 's@^#(.*mod_suexec.so)@\1@' $apache_install_dir/conf/httpd.conf
  sed -ri 's@^#(.*mod_vhost_alias.so)@\1@' $apache_install_dir/conf/httpd.conf
  sed -ri 's@^#(.*mod_rewrite.so)@\1@' $apache_install_dir/conf/httpd.conf
  sed -ri 's@^#(.*mod_deflate.so)@\1@' $apache_install_dir/conf/httpd.conf
  sed -ri 's@^#(.*mod_expires.so)@\1@' $apache_install_dir/conf/httpd.conf
  sed -ri 's@^#(.*mod_ssl.so)@\1@' $apache_install_dir/conf/httpd.conf
  sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' $apache_install_dir/conf/httpd.conf
  sed -i "s@^DocumentRoot.*@#DocumentRoot \"$wwwroot_dir/default\"@" $apache_install_dir/conf/httpd.conf
  sed -i "s@^<Directory \"$apache_install_dir/htdocs\">@<Directory \"$wwwroot_dir/default\">@" $apache_install_dir/conf/httpd.conf
  sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" $apache_install_dir/conf/httpd.conf

# logrotate apache log
  cat > /etc/logrotate.d/apache << EOF
$wwwlogs_dir/*apache.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -f $apache_install_dir/logs/httpd.pid ] && kill -USR1 \`cat $apache_install_dir/logs/httpd.pid\`
  endscript
}
EOF

  mkdir $apache_install_dir/conf/vhost
  cat > $apache_install_dir/conf/vhost/default.conf << EOF
<VirtualHost *:$TMP_PORT>
#	ServerAdmin admin@hiyang.com
	DocumentRoot "$wwwroot_dir/default"
	ServerName test.com
	<Directory "$wwwroot_dir/default">
		SetOutputFilter DEFLATE
		Options FollowSymLinks ExecCGI
		Require all granted
		AllowOverride All
		Order allow,deny
		Allow from all
		DirectoryIndex index.html index.php
	</Directory>
	ErrorLog "$wwwlogs_dir/error_apache.log"
	CustomLog "$wwwlogs_dir/access_apache.log" common
#	<Location /server-status>
#		SetHandler server-status
#		Order Deny,Allow
#		Deny from all
#		Allow from 127.0.0.1
#	</Location>
</VirtualHost>
EOF

cat >> $apache_install_dir/conf/httpd.conf <<EOF
<IfModule mod_headers.c>
	AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
	<FilesMatch "\.(js|css|html|htm|png|jpg|swf|pdf|shtml|xml|flv|gif|ico|jpeg)\$">
		RequestHeader edit "If-None-Match" "^(.*)-gzip(.*)\$" "\$1\$2"
		Header edit "ETag" "^(.*)-gzip(.*)\$" "\$1\$2"
	</FilesMatch>
	DeflateCompressionLevel 6
	SetOutputFilter DEFLATE
</IfModule>

ServerTokens ProductOnly
ServerSignature Off
Include conf/vhost/*.conf
EOF

if [ "$Nginx_version" != '4' -o -e "$web_install_dir/sbin/nginx" ]; then
    cat > $apache_install_dir/conf/extra/httpd-remoteip.conf << EOF
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 127.0.0.1
EOF
    sed -i "s@Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf\nInclude conf/extra/httpd-remoteip.conf@" $apache_install_dir/conf/httpd.conf
    sed -i "s@LogFormat \"%h %l@LogFormat \"%h %a %l@g" $apache_install_dir/conf/httpd.conf
  fi
  ldconfig
  service httpd start
  popd
}
