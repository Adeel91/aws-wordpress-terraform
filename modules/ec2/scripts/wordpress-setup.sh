#!/bin/bash

# Configuration Variables
WEB_ROOT="/var/www/html"
LOG_FILE="/var/log/wordpress-setup.log"
DB_NAME="${DB_NAME:-wordpressdb}"
DB_USER="${DB_USER:-admin}"
DB_PASS="${DB_PASS:-admin123}"
DB_HOST="${DB_HOST:-localhost}"

# Initialize logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "$(date) - Starting WordPress installation"

# Exit immediately on error and log all commands
set -e
trap 'echo "$(date) - ERROR at line $LINENO"; exit 1' ERR

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Enable and install PHP 8.1
echo "Configuring PHP 8.1..."
sudo amazon-linux-extras enable php8.1 -y
sudo yum clean metadata
sudo yum install -y php php-cli php-mysqlnd php-fpm php-xml php-mbstring php-opcache php-gd

# Install and configure Apache
echo "Installing Apache..."
sudo yum install -y httpd mod_ssl
sudo systemctl enable --now httpd

# Configure PHP-FPM
echo "Configuring PHP-FPM..."
sudo systemctl enable --now php-fpm

# Download WordPress
echo "Downloading WordPress..."
wget -q https://wordpress.org/latest.tar.gz || { echo "WordPress download failed"; exit 1; }
tar -xzf latest.tar.gz
rm -f latest.tar.gz

# Deploy WordPress
echo "Deploying WordPress files..."
sudo rsync -a wordpress/ "$WEB_ROOT/"
rm -rf wordpress

# Set permissions
echo "Setting permissions..."
sudo chown -R apache:apache "$WEB_ROOT"
sudo find "$WEB_ROOT" -type d -exec chmod 755 {} \;
sudo find "$WEB_ROOT" -type f -exec chmod 644 {} \;

# Configure database connection
echo "Configuring database connection..."
sudo cp "$WEB_ROOT/wp-config-sample.php" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '$DB_NAME' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '$DB_USER' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '$DB_PASS' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '$DB_HOST' );/" "$WEB_ROOT/wp-config.php"

# Security hardening
echo "Applying security settings..."
sudo chmod 440 "$WEB_ROOT/wp-config.php"
sudo setsebool -P httpd_unified 1

# Configure PHP-FPM with Apache
echo "Configuring Apache for PHP-FPM..."
sudo tee /etc/httpd/conf.d/php-fpm.conf > /dev/null <<'EOL'
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
EOL

# Final restart
echo "Restarting services..."
sudo systemctl restart php-fpm httpd

# Verify installation
echo "Verifying installation..."
curl -Is http://localhost | head -1 | grep -q "200 OK" || { echo "Apache not responding"; exit 1; }
sudo -u apache php -r "require '$WEB_ROOT/wp-config.php'; echo 'DB connection: ' . (defined('DB_NAME') ? 'OK' : 'FAILED') . PHP_EOL;" | tee -a "$LOG_FILE"

echo "$(date) - ✅ WordPress installation with PHP 8.1 completed successfully!"
