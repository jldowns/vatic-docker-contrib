#!/bin/bash -e

# Post-install for Docker builds.
#
# This is mostly a copy-paste from the vatic-install.sh INSTALL_WITH_EXAMPLE_DATA
# section, except that it fixes some permission and file structure issues
# that come with a Docker container.

export MYSQL_PASSWORD=${MYSQL_PASSWORD:-hail_ukraine}
export SERVER_NAME=${SERVER_NAME:-localhost}

cd $HOME

# set some mysql password so we can proceed without interactive prompt for it
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"

# Configure apache
sudo cp /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled
service mysql start
mysql -u root -p$MYSQL_PASSWORD -e 'create database vatic;'

sudo bash -c "cat > /etc/apache2/sites-enabled/000-default" <<EOF
WSGIDaemonProcess www-data
WSGIProcessGroup www-data

<VirtualHost *:80>
    ServerName $SERVER_NAME
    DocumentRoot /home/vagrant/vatic/public

    WSGIScriptAlias /server /home/vagrant/vatic/server.py
    ErrorLog /var/log/apache2/error-vatic.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>

EOF

cat /etc/apache2/sites-enabled/000-default > /etc/apache2/sites-enabled/000-default.conf

# Give apache appropriate permissions
sed -i '1i ServerName localhost' /etc/apache2/apache2.conf
    cat <<EOF >> /etc/apache2/apache2.conf
        <Directory /home/vagrant/vatic/>
            Options Indexes FollowSymLinks
            AllowOverride None
            Require all granted
        </Directory>
EOF

# Link the egg cache to where the server expects to see it
ln -s /home/vagrant/.python-eggs /var/www/.python-eggs

# And then restart the server
sudo service apache2 restart

# Set up VATIC
sudo cp $HOME/vatic/config.py-example $HOME/vatic/config.py
sudo sed -ibak "s/root@localhost/root:$MYSQL_PASSWORD@localhost/g" vatic/config.py

sudo apache2ctl graceful

cd $HOME/vatic
turkic setup --database
turkic setup --public-symlink
turkic status --verify

# turkic extract /home/vagrant/vagrant_data/USCGsideview.mp4 /home/vagrant/vagrant_data/uscg/
# turkic load example_id /home/vagrant/vagrant_data/uscg/ example_label1 example_label2 example_label3 --offline

wget -qO- "http://localhost:80/?id=1&hitId=offline" > /dev/null \
    && echo "We are rather done. Go to http://localhost:8080/?id=1&hitId=offline and see how this thing works" \
    || echo "Something went rather wrong and now you'll have to troubleshoot"


# Start the services
/home/vagrant/start_services.sh
