#!/bin/bash

dnf update -y

#install wget, apache server, php and efs utils
dnf install -y httpd wget php-fpm php-mysqli php-json php amazon-efs-utils

#create wp-content mountpoint
mkdir -p /var/www/html/wp-content
mount -t efs ${efs_id}:/ /var/www/html/wp-content

#install wordpress
cd /var/www
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
rm -f latest.tar.gz

#change wp-config with DB details
cp -rn wordpress/* /var/www/html/
sed -i "s/database_name_here/${db_name}/g" /var/www/html/wp-config.php
sed -i "s/username_here/${db_user}/g" /var/www/html/wp-config.php
sed -i "s/password_here/${db_password}/g" /var/www/html/wp-config.php
sed -i "s/localhost/${db_host}/g" /var/www/html/wp-config.php

#change httpd.conf file to allowoverride
#  enable .htaccess files in Apache config using sed command
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# create phpinfo file
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# Recursively change OWNER of directory /var/www and all its contents
chown -R apache:apache /var/www

systemctl restart httpd
systemctl enable httpd