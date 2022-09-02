#!/usr/bin/env bash

## Description: Sets up a Statamic Site for DDEV.
## Usage: configure-statamic-for-ddev
## Example: "ddev configure-statamic-for-ddev"

# Set variables pointing to different paths within the Docker container.
html_root="/var/www/html"
ddev_path="storage/ddev"

# Create a variable for the db name (based on the ddev site name)
DDEV_DB=${DDEV_SITENAME//-/_}

# Confirm our .env exists before trying to modify it
if [ -f "$html_root/.env" ]; then

    # Create a place for backups
    if [ ! -d $html_root/$ddev_path/backups ]; then
        mkdir $html_root/$ddev_path/backups
    fi
    
    # Backup the existing .env
    cp --backup=numbered $html_root/.env $html_root/$ddev_path/backups/.env.ddev-bak

    # Set the APP_URL to the DDEV_URL
    sed -i "/APP_URL=/c APP_URL=https://${DDEV_SITENAME}.ddev.site" $html_root/.env

    # Setup mailhog
    sed -i "/MAIL_HOST=/c MAIL_HOST=localhost" $html_root/.env
    sed -i "/MAIL_FROM_ADDRESS=/c MAIL_FROM_ADDRESS=test@${DDEV_HOSTNAME}" $html_root/.env

    # Setup our DB
    sed -i "/DB_DATABASE=/c DB_DATABASE=$DDEV_DB" $html_root/.env
    sed -i "/DB_USERNAME=/c DB_USERNAME=db" $html_root/.env
    sed -i "/DB_PASSWORD=/c DB_PASSWORD=db" $html_root/.env

else
    echo ""
    echo "Sorry, no file found at $html_root/.env"
fi

# Configure the web env for ddev in .ddev/config.yaml
sed -i '/web_environment: \[]/c web_environment: [\"VITE_APP_URL=\${DDEV_HOSTNAME}\"]' $html_root/.ddev/config.yaml

# Create a backup of the existing vite config if it exists, and copy the new default
if [ -f "$html_root/vite.config.js" ]; then
    mv --backup=numbered $html_root/vite.config.js $html_root/$ddev_path/backups/vite.config.js.ddev-bak
    curl <ADD LINK TO VITE CONFIG HERE> -o $html_root/vite.config.js //TODO
else
    echo "Sorry, no file found at $html_root/vite.config.js"
fi
