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
# Configure Apache to allow .htaccess
# -----------------------
echo "Updating Apache config to allow .htaccess..."
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd

# -----------------------
# Install Git and Clone Repository
# -----------------------
echo "Installing Git..."
sudo yum install -y git

echo "Cloning WooCommerce website repository..."
sudo git clone https://github.com/Adeel91/woocommerce-website "$WEB_ROOT"

echo "$(date) - ✅ Core packages installation completed"

# -----------------------
# Create .htaccess for WordPress permalinks
# -----------------------
echo "Creating .htaccess file for WordPress..."
sudo cat <<'EOF' | sudo tee "$WEB_ROOT/.htaccess" > /dev/null
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %%{REQUEST_FILENAME} !-f
RewriteCond %%{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

sudo chown apache:apache "$WEB_ROOT/.htaccess"

echo "$(date) - ✅ Core packages installation completed"

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

echo "$(date) - ✅ Updated wp-config.php with database information"

# -----------------------
# Replace localhost:8000 with AWS host in wordpressdb.sql
# -----------------------
echo "Replacing 'localhost:8000' with AWS host in the SQL dump file..."

sed -i "s/localhost:8000/$WEB_HOST/g" "$WEB_ROOT/wordpressdb.sql"

echo "$(date) - ✅ Replaced 'localhost:8000' with AWS host in the SQL dump"

# -----------------------
# Check if the SQL dump file exists
# -----------------------
if [ ! -f "$WEB_ROOT/wordpressdb.sql" ]; then
    echo "$(date) - ERROR: SQL dump file does not exist at $WEB_ROOT/wordpressdb.sql"
    exit 1
fi

# -----------------------
# Import WordPress SQL Dump into RDS
# -----------------------
# Only import if 'wp_options' table has fewer than N rows
ROWS=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT COUNT(*) FROM ${DB_NAME}.wp_options;" 2>/dev/null | tail -n1)

if [[ "$ROWS" -lt 5 ]]; then
  echo "Importing database dump since it appears empty..."
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" --default-character-set=utf8mb4 "$DB_NAME" < "$WEB_ROOT/wordpressdb.sql"
  echo "$(date) - ✅ Database imported successfully"
else
  echo "$(date) - ℹ️ Database already populated, skipping import"
fi

echo "$(date) - ✅ Complete woocommerce with sample store installed"