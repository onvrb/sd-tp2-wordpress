FROM alpine:3.12 as wordpress-stage

# download wordpress
RUN apk add --no-cache \
    bash \
    curl \
    xz && \
    mkdir /wordpress && \
    curl -o /latest.tar.gz -L \
    https://wordpress.org/latest.tar.gz && \
    tar xf \
    /latest.tar.gz -C \
    /wordpress

# runtime stage
FROM ghcr.io/onvrb/sd-tp2-ubuntu-baseimage:master

# get wordpress from other stage
COPY --from=wordpress-stage /wordpress /defaults
RUN chown -R www-data /defaults/wordpress

# fix locales
RUN apt update
RUN apt install -y locales

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV LANGUAGE="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    TERM="xterm" \
    LC_CTYPE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8

# install apache/'wordpress dependencies'
RUN apt install -y \
    apache2 \
    ghostscript \
    libapache2-mod-php \
    mysql-server \
    php \
    php-bcmath \
    php-curl \
    php-imagick \
    php-intl \
    php-json \
    php-mbstring \
    php-mysql \
    php-xml \
    php-zip

# set apache user/group
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

# ports and volume
EXPOSE 80
VOLUME [ "/config" ]

# add local files
COPY root/ /

# setup apache
WORKDIR /app
RUN a2ensite wordpress && \
    a2enmod rewrite && \
    a2dissite 000-default && \
    echo 'ServerName localhost' >> \
        /etc/apache2/apache2.conf && \
    chmod +x init.sh

ENTRYPOINT ["./init.sh"]
