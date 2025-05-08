#!/bin/bash

# -----------------------
# Configuration Variables
# -----------------------
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASS="${DB_PASS}"
DB_HOST=$(echo "${DB_HOST}" | sed 's/:3306//')
ADMIN_EMAIL="${ADMIN_EMAIL}"
WEB_HOST="${WEB_URL}"
SITE_NAME="${SITE_NAME}"

WEB_ROOT="/var/www/html"
LOG_FILE="/var/log/wordpress-setup.log"

# -----------------------
# Logging Setup
# -----------------------
exec > >(sudo tee -a "$LOG_FILE") 2>&1
echo "$(date) - Starting WordPress installation"
set -e
trap 'echo "$(date) - ERROR at line $LINENO"; exit 1' ERR

# -----------------------
# System Update & Package Install
# -----------------------
echo "Updating system packages..."
sudo yum update -y

echo "Installing PHP 8.1..."
sudo amazon-linux-extras enable php8.1 -y
sudo yum clean metadata
sudo yum install -y php php-cli php-mysqlnd php-fpm php-xml php-mbstring php-opcache php-gd

echo "Installing MariaDB client..."
sudo yum install -y mariadb

echo "Installing Apache..."
sudo yum install -y httpd mod_ssl
sudo systemctl enable --now httpd

echo "Configuring PHP-FPM..."
sudo systemctl enable --now php-fpm

# -----------------------
# Install Git and Clone Repository
# -----------------------
echo "Installing Git..."
sudo yum install -y git

echo "Cloning WooCommerce website repository..."
sudo git clone https://github.com/Adeel91/woocommerce-website "$WEB_ROOT"

# -----------------------
# Update wp-config.php with the configuration variables
# -----------------------
echo "Updating wp-config.php with database configuration..."
WP_CONFIG="/var/www/html/wp-config.php"

sudo sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '$DB_NAME' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '$DB_USER' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '$DB_PASS' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '$DB_HOST' );/" "$WEB_ROOT/wp-config.php"

sudo tee -a "$WEB_ROOT/wp-config.php" > /dev/null <<'EOL'
define( 'WP_DEBUG', false );
define( 'WP_AUTO_UPDATE_CORE', false );
EOL

echo "$(date) - ✅ Core packages installation completed"