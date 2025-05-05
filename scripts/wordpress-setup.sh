#!/bin/bash

# Database connection variables
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASS="${DB_PASS}"
DB_HOST=$(echo "${DB_HOST}" | sed 's/:3306//')
ADMIN_EMAIL="${ADMIN_EMAIL}"

# WordPress directory
WEB_ROOT="/var/www/html"
LOG_FILE="/var/log/wordpress-setup.log"

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

# Install MariaDB client
echo "Installing MariaDB client..."
sudo yum install mariadb -y

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
echo "Configuring wp-config.php..."
sudo cp "$WEB_ROOT/wp-config-sample.php" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '$DB_NAME' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '$DB_USER' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '$DB_PASS' );/" "$WEB_ROOT/wp-config.php"
sudo sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '$DB_HOST' );/" "$WEB_ROOT/wp-config.php"

# Add debugging settings
sudo tee -a "$WEB_ROOT/wp-config.php" > /dev/null <<'EOL'
define( 'WP_DEBUG', false );
define( 'WP_AUTO_UPDATE_CORE', false );
EOL

# Bypass WordPress installation wizard
echo "Bypassing WordPress installation wizard..."
sudo -u apache php <<EOPHP
<?php
define('WP_INSTALLING', true);
require_once '$WEB_ROOT/wp-load.php';
require_once '$WEB_ROOT/wp-admin/includes/upgrade.php';

wp_install(
    'My WordPress Site',
    '$DB_USER',
    '$ADMIN_EMAIL',
    true,
    '',
    '$DB_PASSWORD'
);

update_option('siteurl', 'http://$DB_HOST');
update_option('home', 'http://$DB_HOST');
delete_transient('_wp_initial_setup_complete');
EOPHP

# Security hardening
echo "Applying security settings..."
sudo chmod 644 "$WEB_ROOT/wp-config.php"

# Configure PHP-FPM with Apache
echo "Configuring Apache for PHP-FPM..."
sudo tee /etc/httpd/conf.d/php-fpm.conf > /dev/null <<'EOL'
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
EOL

# Restart services
echo "Restarting services..."
sudo systemctl restart php-fpm httpd

# Verify installation
echo "Verifying WordPress site..."
curl -Is http://localhost | head -1 | grep -q "200 OK" || { echo "Apache not responding"; exit 1; }
sudo -u apache php -r "require '$WEB_ROOT/wp-config.php'; echo 'DB connection: ' . (defined('DB_NAME') ? 'OK' : 'FAILED') . PHP_EOL;" | tee -a "$LOG_FILE"

echo "$(date) - ✅ WordPress core installation completed"

# -----------------------
# Create and run extra PHP setup script
# -----------------------
echo "Creating post-installation script: wp-extra-setup.php"

cat << 'EOF' > "$WEB_ROOT/wp-extra-setup.php"
<?php
define('WP_USE_THEMES', false);
require_once '/var/www/html/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/upgrade.php';
require_once ABSPATH . 'wp-admin/includes/theme.php';
require_once ABSPATH . 'wp-admin/includes/plugin.php';
require_once ABSPATH . 'wp-admin/includes/file.php';

// Install and activate Astra theme
$theme = 'astra';
if (!wp_get_theme($theme)->exists()) {
    $theme_url = 'https://downloads.wordpress.org/theme/astra.latest-stable.zip';
    include_once ABSPATH . 'wp-admin/includes/class-wp-upgrader.php';
    $upgrader = new Theme_Upgrader();
    $upgrader->install($theme_url);
    switch_theme($theme);
}

// Install and activate WooCommerce
$plugin_slug = 'woocommerce';
$plugin_file = 'woocommerce/woocommerce.php';
if (!is_plugin_active($plugin_file)) {
    $plugin_url = 'https://downloads.wordpress.org/plugin/woocommerce.latest-stable.zip';
    $upgrader = new Plugin_Upgrader();
    $upgrader->install($plugin_url);
    activate_plugin($plugin_file);
}

// Add sample WooCommerce products
if (class_exists('WC_Product_Simple')) {
    for ($i = 1; $i <= 3; $i++) {
        $post_id = wp_insert_post([
            'post_title'   => "Sample Product $i",
            'post_content' => "This is the description for product $i.",
            'post_status'  => 'publish',
            'post_type'    => 'product',
        ]);

        if ($post_id) {
            $product = new WC_Product_Simple($post_id);
            $product->set_regular_price('19.99');
            $product->save();
        }
    }
}
echo "✅ Extra WordPress setup (theme + WooCommerce + products) completed.\n";
EOF

# Execute the PHP post-setup script
echo "Executing wp-extra-setup.php..."
sudo -u apache php "$WEB_ROOT/wp-extra-setup.php" >> /var/log/wp-extra-setup.log 2>&1

# Optional: Remove the setup script
rm -f "$WEB_ROOT/wp-extra-setup.php"

echo "$(date) - 🎉 WordPress extended setup completed successfully!"
