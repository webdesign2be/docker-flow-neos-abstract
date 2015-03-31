#!/bin/sh

APP_NAME="%APP_NAME%"
APP_BUILD_BRANCH="%APP_BUILD_BRANCH%"
APP_VHOST_NAMES="%APP_VHOST_NAMES%"
APP_ROOT="%APP_ROOT%"
CONTAINER_IP="%CONTAINER_IP%"


# Add app's bin/ directory to PATH. It contains project's binaries, i.e. Drush, Phing, phpunit...
export PATH="%APP_ROOT%/bin:$PATH"
export PS1='[\u@\h : \w]\$ '

# Remove old vhost entries and add one line with the new one.
sed -r "/${APP_VHOST_NAMES// /|}/d" /etc/hosts > .hosts.tmp && sudo cp .hosts.tmp /etc/hosts; rm -f .hosts.tmp
echo "$CONTAINER_IP ${APP_VHOST_NAMES}" | sudo tee -a /etc/hosts > /dev/null

echo
echo " ======================================================================="
echo " == ${APP_NAME^^} / ${APP_BUILD_BRANCH^^} branch"
echo " == WEB CONTAINER IP:  $CONTAINER_IP"
echo " == VHOSTS: ${APP_VHOST_NAMES}"
echo " ======================================================================="
echo

cd $APP_ROOT
