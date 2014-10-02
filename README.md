# TYPO3 Neos | Abstract Docker image

This is a Docker image which is designed to easily create images with standard or customised [TYPO3 Neos](http://neos.typo3.org/) installation, either from the default "base" distribution or your own, perhaps private, repository. It is available in Docker Hub as [million12/typo3-neos-abstract](https://registry.hub.docker.com/u/million12/typo3-neos-abstract).

For an example of working TYPO3 Neos image built on top of this one, see [million12/typo3-neos](https://registry.hub.docker.com/u/million12/typo3-neos) repository.

The image is designed that as a result, after running a container from it, you'll get working TYPO3 Neos in a matter of seconds. When the image is being built, it pre-installs requested version of TYPO3 Neos. Later on, when container is launched, it will initialise and configure that pre-installed package - and the process is very quick as the TYPO3 Neos source code is already in place. During that process Nginx vhost(s) will be set, Settings.yaml will be updated with database credentials (linked db container), initial Neos admin user will be created and specified site package will be imported. Read below about available ENV variables to customise your setup.

## Usage

As it's shown in [million12/typo3-neos](https://github.com/million12/docker-typo3-neos), you can build your own TYPO3 Neos image with following Dockerfile:

```
FROM million12/typo3-neos-abstract:latest

# ENV: Install following TYPO3 Neos version
ENV TYPO3_NEOS_VERSION 1.1.2

# ENV: Repository for installed TYPO3 Neos distribution 
#ENV TYPO3_NEOS_REPO_URL git://git.typo3.org/Neos/Distributions/Base.git

# ENV: Optional composer install parameters
#ENV TYPO3_NEOS_COMPOSER_PARAMS --dev --prefer-source

#
# Pre-install TYPO3 Neos into /tmp/typo3-neos.tgz
#
RUN . /build-typo3-neos/pre-install-typo3-neos.sh
```

This will pre-install default TYPO3 Neos distribution, version 1.1.2. Uncomment and provide custom `ENV TYPO3_NEOS_REPO_URL` to install your own distribution.

See [README.md](https://github.com/million12/docker-typo3-neos/README.md) from [million12/typo3-neos](https://github.com/million12/docker-typo3-neos) for more information about how to run all required containers (e.g. MariaDB) and have working instance of TYPO3 Neos.


## How does it work

You start with creating new Docker image based on **million12/typo3-neos-abstract**, using `FROM million12/typo3-neos-abstract:latest` in your Dockerfile. During *build process* of your image, TYPO3 Neos will be pre-installed using `composer install` and embedded inside the image as a tar achive. Using ENV variables (listed below) you can customise pre-install process: provide custom distribution (e.g. from GitHub repo) or specify different version of TYPO3 Neos. See [pre-install-typo3-neos.sh](container-files/build-typo3-neos/pre-install-typo3-neos.sh) for details. 

When you start that prepared container, it will do all necessary steps to make TYPO3 Neos up & running. Script [configure-typo3-neos.sh](container-files/build-typo3-neos/configure-typo3-neos.sh) will set up Nginx vhost config, supply Settings.yaml with database credentials (using linked DB container), and - if it's an empty database - do doctrine migration, set admin user and import specified site package. You can fully customise all details via ENV variables.

## Customise your image

### Dockerfile

In Dockerfile you can customise what and from where is pre-installed during build stage:   
```
FROM million12/typo3-neos-abstract:latest

# ENV: Install custom Neos version
# Default: master
ENV TYPO3_NEOS_VERSION 1.1.2

# ENV: Repository for installed TYPO3 Neos distribution
# Default: git://git.typo3.org/Neos/Distributions/Base.git
ENV TYPO3_NEOS_REPO_URL https://github.com/you/your-typo3-neos-distro.git

# ENV: Custom composer install params
# Default: --dev --prefer-source
ENV TYPO3_NEOS_COMPOSER_PARAMS --no-dev --prefer-dist --optimize-autoloader

# Run pre-install script
RUN . /build-typo3-neos/pre-install-typo3-neos.sh
```

Note the last line with RUN action, which needs to be added by you.

##### Accessing private repositories example

To access private repositories, generate a new SSH key set and add the key as deployment key to your private repository. Then you need to embed them inside your image (via `ADD` instruction in the Dockerfile) and configure SSH that they will be used during *git clone*. Your Dockerfile could look as following:
 
```
FROM million12/typo3-neos-abstract:latest

ENV TYPO3_NEOS_REPO_URL git@github.com:company/your-private-repo.git

ADD gh-repo-key /
RUN \
  chmod 600 /gh-repo-key && \
  echo "IdentityFile /gh-repo-key" >> /etc/ssh/ssh_config && \
  . /build-typo3-neos/pre-install-typo3-neos.sh
```

### Runtime variables

Following is the list of available ENV variables which can be overridden when container is launched (via --env). You can also embed them in your Dockerfile. See [configure-typo3-neos.sh](container-files/build-typo3-neos/configure-typo3-neos.sh) where they are defined with their default values. 

**NEOS_APP_NAME**  
Default: `NEOS_APP_NAME=${NEOS_APP_NAME:="neos"}`  
Used internally as a folder name in /data/www/NEOS_APP_NAME where Neos will be installed and it's used in default vhost name.

**NEOS_APP_DB_NAME**  
Default: `NEOS_APP_DB_NAME=${NEOS_APP_DB_NAME:="typo3_neos"}`  
Database name, which will be used for TYPO3 Neos. It will be created and migrated, if it doesn't exist.

**NEOS_APP_USER_NAME**  
**NEOS_APP_USER_PASS**  
**NEOS_APP_USER_FNAME**  
**NEOS_APP_USER_LNAME**  
Default: `NEOS_APP_USER_NAME=${NEOS_APP_USER_NAME:="admin"}`  
Default: `NEOS_APP_USER_PASS=${NEOS_APP_USER_PASS:="password"}`  
Default: `NEOS_APP_USER_FNAME=${NEOS_APP_USER_FNAME:="Admin"}`  
Default: `NEOS_APP_USER_LNAME=${NEOS_APP_USER_LNAME:="User"}`  
If this is fresh installation, admin user will be created with above details.

**NEOS_APP_VHOST_NAMES**  
Default: `NEOS_APP_VHOST_NAMES=${NEOS_APP_VHOST_NAMES:="${NEOS_APP_NAME} dev.${NEOS_APP_NAME} test.${NEOS_APP_NAME}"}`  
Hostname(s) to configure in Nginx. Nginx is configured that it will set `FLOW_CONTEXT` to *Development* if it contains *dev* in its name, *Testing* if it contains *test*.

**NEOS_APP_SITE_PACKAGE**  
Default: `NEOS_APP_SITE_PACKAGE=${NEOS_APP_SITE_PACKAGE:="TYPO3.NeosDemoTypo3Org"}`  
If you pre-installed custom TYPO3 Neos distribution, you'll probably want to replace this with your own site package available there. This site package will be installed and its content imported, if it's fresh install.

**NEOS_APP_FORCE_SITE_REIMPORT**  
Default: `NEOS_APP_FORCE_SITE_REIMPORT=false`  
Set to true to prune (`./flow site:prune`) and re-import ('./flow site:import ...`) site content each time container starts. Useful if you keep your Sites.xml versioned and in sync.

**NEOS_APP_FORCE_PULL**  
Default: `NEOS_APP_FORCE_PULL=true`  
By default, when container starts, `git pull` (preceded by git clean/reset to avoid any potential conflicts) command will be executed inside TYPO3 Neos root directory. This is to enforce always fresh/latest codebase of your app, even if the pre-installed version is a bit outdated. Set to *false* to switch off this behaviour.


### Custom build steps

You might want to add extra steps to the standard ones provided by [configure-typo3-neos.sh](container-files/build-typo3-neos/configure-typo3-neos.sh) script. There are two ways to do that:

1. Configure script will run ./build.sh from project's root directory. Make it executable and it will be run at the end of the process.
2. If you need something bigger, more customised, you can use for that custom scripts added to `/config/init/*.sh`. The base image is designed that it runs all scripts from there. For example, script which configures TYPO3 Neos is run from [/config/init/20-init-typo3-neos-app](config/init/20-init-typo3-neos-app). Using this, you can easily add extra tasks before and/or after it.


## Authors

Author: Marcin Ryzycki (<marcin@m12.io>)  
