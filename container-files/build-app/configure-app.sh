#!/bin/sh

#
# Initialise/configure Neos/Flow app pre-installed during 'docker build'
# and located in /tmp/INSTALLED_PACKAGE_NAME.tgz (@see install_typo3_app() function)
#

set -e
set -u

source ./include-functions.sh
source ./include-variables.sh

# Internal variables - there is no need to change them
CWD=$(pwd) # Points to /build-app/ directory, where this script is located
WEB_SERVER_ROOT="/data/www"
APP_ROOT="${WEB_SERVER_ROOT}/${APP_NAME}"
INSTALLATION_TYPE="flow" # Default installation type, will be set later on if different one (e.g. Neos) is detected
SETTINGS_SOURCE_FILE="${CWD}/Settings.yaml"
VHOST_SOURCE_FILE="${CWD}/vhost.conf"
VHOST_FILE="/data/conf/nginx/hosts.d/${APP_NAME}.conf"
MYSQL_CMD_PARAMS="-u$APP_DB_USER -p$APP_DB_PASS -h $APP_DB_HOST -P $APP_DB_PORT"
CONTAINER_IP=$(ip -4 addr show eth0 | grep inet | cut -d/ -f1 | awk '{print $2}')
BASH_RC_FILE="$WEB_SERVER_ROOT/.bash_profile"
BASH_RC_SOURCE_FILE="$CWD/.bash_profile"



# Configure some environment aspects (PATH, /etc/hosts, 'www' user profile etc)
configure_env

#
# Neos/Flow app installation
#
install_typo3_app
cd $APP_ROOT
wait_for_db


# Detect real INSTALLATION_TYPE, based on what's found in composer.json
grep "typo3/neos" composer.json && INSTALLATION_TYPE="neos"
log && log "Detected installation type: ${INSTALLATION_TYPE^^}."


#
# Regular Neos/Flow app initialisation
# 
if [ "${APP_DO_INIT^^}" = TRUE ]; then
  log "Configuring Neos/Flow ${INSTALLATION_TYPE^^} app..." && log
  
  create_app_db $APP_DB_NAME
  create_settings_yaml "Configuration/Settings.yaml" $APP_DB_NAME
  
  # DB migration: where are we? Also export it so site build script can access to that info.
  executed_migrations=$(get_db_executed_migrations)
  export RUNTIME_EXECUTED_MIGRATIONS=$executed_migrations
  log "DB executed migrations: $executed_migrations"
  
  # Only proceed with doctrine:migration it is a fresh installation...
  if [[ $(./flow help | grep "database:setcharset") ]]; then
    ./flow database:setcharset # comatibility with Flow < 3.0
  fi
  if [[ $executed_migrations == 0 ]]; then
    log "Fresh ${INSTALLATION_TYPE^^} installation detected: making DB migration:"
    doctrine_update
  else
    log "Neos/Flow ${INSTALLATION_TYPE^^} app database already provisioned, skipping..."
  fi

  # Neos/Flow Neos steps only:
  if [[ $INSTALLATION_TYPE == "neos" ]]; then
    log "Continuing with Neos steps installation:"
    if [[ $executed_migrations == 0 ]]; then
      log "Fresh installation detected: creating admin user, importing site package:"
      create_admin_user
      neos_site_package_install $APP_NEOS_SITE_PACKAGE
    # Re-import the site, if requested
    elif [ "${APP_NEOS_SITE_PACKAGE_FORCE_REIMPORT^^}" = TRUE ]; then
      log "APP_NEOS_SITE_PACKAGE_FORCE_REIMPORT=${APP_NEOS_SITE_PACKAGE_FORCE_REIMPORT}, re-importing $APP_NEOS_SITE_PACKAGE site package."
      neos_site_package_prune
      neos_site_package_install $APP_NEOS_SITE_PACKAGE
    else
      log "Neos already set up, nothing to do."
    fi
  fi
  
  warmup_cache "Production" # Warm-up caches for Production context
fi
# Regular Neos/Flow app initialisation (END)


#
# Initialise Neos/Flow app for running test
# 
if [ "${APP_DO_INIT_TESTS^^}" = TRUE ]; then
  log && log "Configuring Neos/Flow ${INSTALLATION_TYPE^^} app for Behat testing:"
  
  # @TODO: is there anything to do here when Behat is not available? Not sure...
  # Functional tests can run without any extra configuration in Testing context
  # so it seems like special care is only needed for Behat testing.

  # Only proceed with Behat setup if it is available...
  if [[ $(./flow help | grep "behat:setup") ]]; then
    testing_db_name="${APP_DB_NAME}_test"
    create_app_db $testing_db_name
    
    # Find vhost name for Behat. That should be 'behat.dev.[BASE_DOMAIN_NAME]' in APP_VHOST_NAMES variable.
    # Exit if Behat host could not be determined.
    behat_vhost=$(behat_get_vhost)
    if [ -z $behat_vhost ]; then
      log "ERROR: Could not find vhost name for Behat!"
      log "Please provide *behat.dev.[BASE_DOMAIN]* to APP_VHOST_NAMES environment variable."
      exit 1
    else
      log "Detected virtual host used for Behat testing: $behat_vhost"
    fi

    # Configure FLOW_CONTEXTs for Behat
    create_settings_yaml "Configuration/Testing/Behat/Settings.yaml" $testing_db_name
    create_settings_yaml "Configuration/Development/Behat/Settings.yaml" $testing_db_name
    
    # Configure behat.yml files
    behat_configure_yml_files $behat_vhost
    # Install Behat dependencies
    ./flow behat:setup
    # Warm-up caches
    warmup_cache "Development/Behat"
  else
    log "NOTICE: package 'flowpack/behat' seems to be missing but it's required to set up Behat testing."
    log "Please add '\"flowpack/behat\": \"dev-master\"' to your composer.json and start the container again." && log
  fi
fi
# Initialise Neos/Flow app for running test (END)



set_permissions
create_vhost_conf $APP_VHOST_NAMES
user_build_script

log "Installation completed." && echo
