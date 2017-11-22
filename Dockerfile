FROM alpine:3.6
MAINTAINER Liam Martens (hi@liammartens.com)

# set default shell
ENV SHELL=/bin/bash
ENV OWN_DIRS='/var/www /etc/php7 /var/log/php7'

# add www-data user
RUN adduser -D www-data

# run updates
RUN apk update && apk upgrade

# add packages
RUN apk add tzdata perl curl bash git

# install php 7
ENV PHPV=7
RUN apk add --update --no-cache \
    php$PHPV-mcrypt \
    php$PHPV-soap \
    php$PHPV-openssl \
    php$PHPV-gmp \
    php$PHPV-pdo_odbc \
    php$PHPV-json \
    php$PHPV-dom \
    php$PHPV-pdo \
    php$PHPV-zip \
    php$PHPV-mysqli \
    php$PHPV-sqlite3 \
    php$PHPV-pdo_pgsql \
    php$PHPV-bcmath \
    php$PHPV-opcache \
    php$PHPV-intl \
    php$PHPV-mbstring \
    php$PHPV-sockets \
    php$PHPV-zlib \
    php$PHPV-xml \
    php$PHPV-session \
    php$PHPV-pcntl \
    php$PHPV-gd \
    php$PHPV-odbc \
    php$PHPV-pdo_mysql \
    php$PHPV-pdo_sqlite \
    php$PHPV-gettext \
    php$PHPV-xmlreader \
    php$PHPV-xmlrpc \
    php$PHPV-bz2 \
    php$PHPV-iconv \
    php$PHPV-pdo_dblib \
    php$PHPV-curl \
    php$PHPV-ctype \
    php$PHPV-pear \
    php$PHPV-fpm \
    php$PHPV-common \
    php$PHPV-phar \
    php$PHPV-xmlwriter \
    php$PHPV-tokenizer \
    php$PHPV-fileinfo \
    php$PHPV-posix \
    php$PHPV-imagick

# install yaml 2.0.0 extension
RUN apk add php$PHPV-dev autoconf yaml-dev yaml alpine-sdk
RUN perl -pi -e "s/-C -n -q/-C -q/" `which pecl` && pecl install yaml-2.0.0
# install php-redis extension
RUN git clone https://github.com/phpredis/phpredis
RUN cd phpredis && phpize && ./configure && make && make install
RUN rm -rf phpredis
RUN apk del php$PHPV-dev autoconf yaml-dev alpine-sdk

# install composer globally
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \ 
    php composer-setup.php && php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# create php directory
RUN mkdir -p /etc/php7 /var/log/php7 /usr/lib/php7 /var/www && \
    chown -R www-data:www-data /etc/php7 /var/log/php7 /usr/lib/php7 /var/www

# chown timezone files
RUN touch /etc/timezone /etc/localtime && \
    chown www-data:www-data /etc/localtime /etc/timezone

# copy /etc/profile to .profile
RUN cp /etc/profile /home/www-data/.profile
RUN chown www-data:www-data /home/www-data/.profile

# set volume
VOLUME ["/etc/php7", "/var/log/php7", "/var/www"]

# copy run file
COPY scripts/run.sh /home/www-data/run.sh
RUN chmod +x /home/www-data/run.sh
COPY scripts/continue.sh /home/www-data/continue.sh
RUN chmod +x /home/www-data/continue.sh

ENTRYPOINT ["/home/www-data/run.sh", "su", "-m", "www-data", "-c", "/home/www-data/continue.sh"]