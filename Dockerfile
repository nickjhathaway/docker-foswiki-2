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
                                 byobu curl git htop man unzip vim wget tree graphviz imagemagick\
                                 ghostscript libmagickcore-dev perlmagick libjson-perl rcs sendmail
# install mail 
# install mailer
RUN DEBIAN_FRONTEND=noninteractive apt-get -qy install opensmtpd; \
	ln -sf /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem

# install web server stuff (apache2, php5, etc.)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y php5 php5-common php5-cli php5-fpm apache2 apache2-utils libapache2-mod-php5

#install various perl modules
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --install-suggests libfile-copy-recursive-perl \
		libcgi-pm-perl libdigest-md5-perl libcgi-session-perl libcrypt-passwdmd5-perl libio-stringy-perl \
		libhtml-parser-perl libwww-perl libarchive-tar-perl libnet-ldap-perl libdb-file-lock-perl


# download, install, and set up the foswiki 
RUN cd /var/www/html && wget http://iweb.dl.sourceforge.net/project/foswiki/foswiki/2.0.0/Foswiki-2.0.0.tgz && \
        tar -zxvf /var/www/html/Foswiki-2.0.0.tgz -C /var/www/html/ && \
        chown -R www-data:www-data /var/www/html/Foswiki-2.0.0 && \
        cd /var/www/html/Foswiki-2.0.0/tools && echo \\ny\\n | perl -I ../lib rewriteshebang.pl


# Add files (foswiki apache config file, rc.locl, etc...)
ADD /files/ /

#RUN tar -zxvf /var/www/html/Foswiki-2.0.0.tar.gz -C /var/www/html/ && \
#        chown -R www-data:www-data /var/www/html/Foswiki* && \
#        cd /var/www/html/Foswiki*/tools && echo \\ny\\n | perl -I ../lib rewriteshebang.pl

#make sure rc.local and copyfs.sh is executable         
RUN /bin/chmod 755 /etc/rc.local
RUN /bin/chmod 755 /root/copyfs.sh

#enable the foswiki conf file by ln -s to conf-enabled and enable other apache2 configurations 
RUN ln -s /etc/apache2/conf-available/foswiki.conf /etc/apache2/conf-enabled/foswiki.conf && \
     a2enmod rewrite && ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/   && \
     service apache2 restart 

# Set environment variables.
ENV HOME /root

