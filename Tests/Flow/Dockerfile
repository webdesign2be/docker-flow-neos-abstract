FROM webdesign2be/flow-neos-abstract:latest
MAINTAINER Christian Albrecht webdesign2be@gmail.com

# ENV: Repository for installed Flow distribution 
ENV APP_BUILD_REPO_URL git://git.typo3.org/Flow/Distributions/Base.git

# ENV: Install following Neos version
ENV APP_BUILD_BRANCH 2.3.0

# Pre-install Flow into /tmp directory
RUN . /build-app/pre-install-app.sh
