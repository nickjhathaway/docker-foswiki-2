#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget tree php5 emacs && \
  rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install -y apache2 
RUN apt-get install -y libjson-perl
RUN cd /var/www/html && wget https://sourceforge.net/projects/foswiki/files/latest/download -O foswiki_latest.tar.gz
RUN tar -zxvf /var/www/html/foswiki_latest.tar.gz -C /var/www/html/
RUN chown -R www-data:www-data /var/www/html/Foswiki*
#RUN cd /var/www/html/Foswiki*/tools && perl -I ../lib rewriteshebang.pl $(echo y)

# Add files.
#ADD root/.bashrc /root/.bashrc
#ADD root/.gitconfig /root/.gitconfig
#ADD root/.scripts /root/.scripts
RUN a2enmod rewrite
ADD  configFiles/foswiki.conf /etc/apache2/conf-available/foswiki.conf
RUN ln -s /etc/apache2/conf-available/foswiki.conf /etc/apache2/conf-enabled/foswiki.conf
RUN service apache2 restart 

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]


EXPOSE  80

