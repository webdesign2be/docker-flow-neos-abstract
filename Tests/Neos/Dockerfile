FROM webdesign2be/flow-neos-abstract:latest
MAINTAINER Christian Albrecht webdesign2be@gmail.com

# ENV: Repository for installed Neos distribution 
ENV T3APP_BUILD_REPO_URL git://git.typo3.org/Neos/Distributions/Base.git

# ENV: Install following Neos version
ENV T3APP_BUILD_BRANCH 1.2.0

# ENV: Import following site package
ENV T3APP_NEOS_SITE_PACKAGE TYPO3.NeosDemoTypo3Org

# Pre-install Neos into /tmp directory
RUN . /build-app/pre-install-app.sh
