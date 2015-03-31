#!/bin/sh

###############################################
# ENV variables used during image build phase
###############################################
APP_BUILD_REPO_URL=${APP_BUILD_REPO_URL:="git://git.typo3.org/Flow/Distributions/Base.git"}
APP_BUILD_BRANCH=${APP_BUILD_BRANCH:="master"}
APP_BUILD_COMPOSER_PARAMS=${APP_BUILD_COMPOSER_PARAMS:="--prefer-source"}



###############################################
# ENV variables used during container runtime
###############################################

APP_DO_INIT=${APP_DO_INIT:=true}
APP_DO_INIT_TESTS=${APP_DO_INIT_TESTS:=false}
APP_NAME=${APP_NAME:="typo3-app"}
APP_USER_NAME=${APP_USER_NAME:="admin"}
APP_USER_PASS=${APP_USER_PASS:="password"}
APP_USER_FNAME=${APP_USER_FNAME:="Admin"}
APP_USER_LNAME=${APP_USER_LNAME:="User"}
APP_VHOST_NAMES=${APP_VHOST_NAMES:="${APP_NAME} dev.${APP_NAME} behat.dev.${APP_NAME}"}
APP_NEOS_SITE_PACKAGE=${APP_NEOS_SITE_PACKAGE:=false}
APP_NEOS_SITE_PACKAGE_FORCE_REIMPORT=${APP_NEOS_SITE_PACKAGE_FORCE_REIMPORT:=false}
APP_ALWAYS_DO_PULL=${APP_ALWAYS_DO_PULL:=false}
APP_FORCE_VHOST_CONF_UPDATE=${APP_FORCE_VHOST_CONF_UPDATE:=true}
APP_PREINSTALL=${APP_PREINSTALL:=true}

# Database ENV variables
# Note: all DB_* variables are created by Docker when linking this container with MariaDB container (e.g. tutum/mariadb, million12/mariadb) with --link=mariadb-container-id:db option. 
APP_DB_HOST=${APP_DB_HOST:=${DB_PORT_3306_TCP_ADDR:="db"}}      # 1st take APP_DB_HOST, then DB_PORT_3306_TCP_ADDR (linked db container), then fallback to 'db' host
APP_DB_PORT=${APP_DB_PORT:=${DB_PORT_3306_TCP_PORT:="3306"}}    # 1st take APP_DB_PORT, then DB_PORT_3306_TCP_PORT (linked db container), then fallback to the default '3306' port
APP_DB_USER=${APP_DB_USER:=${DB_ENV_MARIADB_USER:="admin"}}     # 1st take APP_DB_USER, then DB_ENV_MARIADB_USER (linked db container), then fallback to the default 'admin' user
APP_DB_PASS=${APP_DB_PASS:=${DB_ENV_MARIADB_PASS:="password"}}  # 1st take APP_DB_PASS, then DB_ENV_MARIADB_PASS (linked db container), then fallback to dummy pass
APP_DB_NAME=${APP_DB_NAME:=${APP_NAME//[^a-zA-Z0-9]/_}}       # DB name: Fallback to APP_NAME if not provided. Replace all non-allowed in DB identifiers with '_' char

# Script relative to $APP_ROOT directory - if found there and it's executable,
# will be called at the end of the setup process.
APP_USER_BUILD_SCRIPT=${APP_USER_BUILD_SCRIPT:="./build.sh"}



########################################################
# Internal variables - there is no need to change them
# We put here only these internal variables, which
# needs to be shared between pre-install-app.sh 
# and configure-app.sh scripts.
########################################################
INSTALLED_PACKAGE_NAME="typo3-app-package" # Pre-installed /tmp/INSTALLED_PACKAGE_NAME.tgz
