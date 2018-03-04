ARG USER=www-data
ARG PHPV=7
FROM liammartens/alpine
LABEL maintainer="Liam Martens <hi@liammartens.com>"

# @env Set PHP version
ENV PHPV=${PHPV:-7}

# @user Switch back to root user
USER root

# @run Install PHP
RUN apk add --update --no-cache \
    fcgi \
    php${PHPV}-mcrypt \
    php${PHPV}-soap \
    php${PHPV}-openssl \
    php${PHPV}-gmp \
    php${PHPV}-pdo_odbc \
    php${PHPV}-json \
    php${PHPV}-dom \
    php${PHPV}-pdo \
    php${PHPV}-zip \
    php${PHPV}-mysqli \
    php${PHPV}-sqlite3 \
    php${PHPV}-pdo_pgsql \
    php${PHPV}-bcmath \
    php${PHPV}-opcache \
    php${PHPV}-intl \
    php${PHPV}-mbstring \
    php${PHPV}-sockets \
    php${PHPV}-zlib \
    php${PHPV}-xml \
    php${PHPV}-session \
    php${PHPV}-pcntl \
    php${PHPV}-gd \
    php${PHPV}-odbc \
    php${PHPV}-pdo_mysql \
    php${PHPV}-pdo_sqlite \
    php${PHPV}-gettext \
    php${PHPV}-xmlreader \
    php${PHPV}-xmlrpc \
    php${PHPV}-bz2 \
    php${PHPV}-iconv \
    php${PHPV}-pdo_dblib \
    php${PHPV}-curl \
    php${PHPV}-ctype \
    php${PHPV}-pear \
    php${PHPV}-fpm \
    php${PHPV}-common \
    php${PHPV}-phar \
    php${PHPV}-xmlwriter \
    php${PHPV}-tokenizer \
    php${PHPV}-fileinfo \
    php${PHPV}-posix \
    php${PHPV}-imagick

# @run Install yaml extension
RUN apk add php${PHPV}-dev autoconf yaml-dev yaml alpine-sdk && \
    perl -pi -e "s/-C -n -q/-C -q/" $(which pecl) && \
    pecl install yaml-2.0.0

# @run Install php-redis extension
RUN git clone https://github.com/phpredis/phpredis && \
    cd phpredis && phpize && ./configure && make && make install && \
    cd ../ && rm -rf phpredis

# @run Remove the build packages
RUN apk del php${PHPV}-dev autoconf yaml-dev alpine-sdk

# @run Install composer globally
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# @run Create php and web directories
RUN rm -rf /etc/php${PHPV} && mkdir -p /etc/php${PHPV} /usr/lib/php${PHPV} /var/www

# @copy Copy default config files
COPY conf/ /etc/php${PHPV}/

# @run chown
RUN chown -R ${USER}:${USER} /etc/php${PHPV} /usr/lib/php${PHPV} /var/www

# @workdir change workdir
WORKDIR /home/${USER}

# @run Add global composer bin to profile
RUN mkdir .composer && \
    echo 'export PATH=~/.composer/vendor/bin:$PATH' >> .profile &&\
    echo '. ~/.profile' >> .bashrc

# @run chown directory
RUN chown -R ${USER}:${USER} ../${USER}

# @copy Copy additional run files
COPY .docker ${DOCKER_DIR}

# @run Make the file(s) executable
RUN chmod -R +x ${DOCKER_DIR}

# @run symlink php-fpm specific version
RUN ln -s $(which php-fpm${PHPV}) /usr/local/bin/php-fpm

# @user Set user back to non-root
USER ${USER}

# @healthcheck Simple container healthcheck
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=2 CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

# @cmd Set command to start php-fpm
CMD [ "-i", "-c", "php-fpm" ]