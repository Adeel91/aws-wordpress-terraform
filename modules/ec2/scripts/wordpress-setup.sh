#!/bin/bash

# Exit the script if any command fails
set -e

# Update system packages
sudo yum update -y

# Install EPEL and Remi repositories to get the latest PHP versions
sudo yum install -y epel-release
sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Enable the Remi PHP repository and install PHP 8.0
sudo yum install -y yum-utils
sudo yum module reset php
sudo yum module enable php:remi-8.0  # Enabling PHP 8.0
sudo yum install -y php php-cli php-fpm php-mysqlnd php-xml php-mbstring wget unzip

# Start and enable Apache web server
sudo systemctl start httpd
sudo systemctl enable httpd

# Start and enable PHP-FPM
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress/* /var/www/html/

# Clean up the tar file
rm -f latest.tar.gz

# Set proper ownership and permissions
# Ensure Apache can read/write to the WordPress directory
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

# Secure wp-config.php by setting appropriate permissions
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php

# Automate wp-config.php with database credentials using define() method
sudo sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'wordpressdb' );/" wp-config.php
sudo sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'admin' );/" wp-config.php
sudo sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', 'admin12345' );/" wp-config.php
sudo sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'wordpress-mariadb.csjbpamc4jwr.us-west-2.rds.amazonaws.com' );/" wp-config.php

# Secure wp-config.php
sudo chmod 640 wp-config.php

# Configure Apache to use PHP-FPM (Ensure PHP-FPM is installed and running)
echo '<IfModule mod_proxy_fcgi.c>
  <FilesMatch \.php$>
    SetHandler proxy:fcgi://127.0.0.1:9000
  </FilesMatch>
</IfModule>' | sudo tee /etc/httpd/conf.d/php-fpm.conf

# Restart Apache to apply changes
sudo systemctl restart httpd

# Check for any errors
sudo systemctl status httpd
sudo systemctl status php-fpm

# Final message
echo "✅ WordPress is configured and connected to RDS MariaDB!"
