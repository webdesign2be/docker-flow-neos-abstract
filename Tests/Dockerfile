#
# This file is just for development purposes.
# Might be useful during development of this image.
# It leverages Docker caching to speed up image building
# while you develop e.g. configure-app.sh script.
#
FROM million12/php-app:latest

ADD container-files/config /
ADD container-files/etc /
ADD container-files/build-app/include-variables.sh /build-app/include-variables.sh
ADD container-files/build-app/pre-install-app.sh /build-app/pre-install-app.sh

ENV T3APP_BUILD_REPO_URL git://git.typo3.org/Neos/Distributions/Base.git
ENV T3APP_BUILD_BRANCH 1.1.2
ENV T3APP_NEOS_SITE_PACKAGE TYPO3.NeosDemoTypo3Org

RUN . /build-app/pre-install-app.sh

ADD container-files /
