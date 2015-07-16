# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.16

# global env
ENV HOME=/root TERM=xterm

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# set proper timezone
RUN echo America/New_York > /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata

# Install Essentials.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential software-properties-common\
                                 byobu curl git htop man unzip vim wget tree libjson-perl 

# install web server stuff (apache2, php5, etc.)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y php5 php5-common php5-cli php5-fpm apache2 apache2-utils libapache2-mod-php5

# download, install, and set up the foswiki 
RUN cd /var/www/html && wget https://sourceforge.net/projects/foswiki/files/latest/download -O foswiki_latest.tar.gz && \
        tar -zxvf /var/www/html/foswiki_latest.tar.gz -C /var/www/html/ && \
        chown -R www-data:www-data /var/www/html/Foswiki* && \
        cd /var/www/html/Foswiki*/tools && echo \\ny\\n | perl -I ../lib rewriteshebang.pl

# Add files (foswiki apache config file, rc.locl, etc...)
ADD /files/ /
RUN ln -s /etc/apache2/conf-available/foswiki.conf /etc/apache2/conf-enabled/foswiki.conf && \
     a2enmod rewrite && ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/   && \
     service apache2 restart 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libfile-copy-recursive-perl
# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root


