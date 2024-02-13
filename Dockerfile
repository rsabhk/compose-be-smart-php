FROM php:7.4-fpm

LABEL Maintainer="Anca Yuliansyah <anca@rsabhk.co.id>" \
      Description="Nginx, PHP-FM and Laravel for SMART v1"

# Get frequently used tools

#COPY ./${DOC_ROOT}/composer.lock ./${DOC_ROOT}/composer.json /var/www/

RUN apt-get update && apt-get install -y \
    build-essential \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    locales \
    zip \
    unzip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    git \
    curl \
    wget \
    libpq-dev

RUN docker-php-ext-configure zip

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

RUN docker-php-ext-install \
        bcmath \
        mbstring \
        pcntl \
        intl \
        zip \
	opcache \
        pdo \
        pdo_pgsql \
        pgsql 
       
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy existing app directory
#COPY ./${DOC_ROOT}/PHP /var/www
WORKDIR /var/www/smart


# Configure non-root user.
ARG PUID=1024
ENV PUID ${PUID}
ARG PGID=100
ENV PGID ${PGID}
ARG DOC_ROOT

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

#RUN groupadd -g 1000 www
#RUN useradd -u 1000 -ms /bin/bash -g www www

#RUN chown -R www-data:www /var/www

# Copy and run composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


COPY --chown=www-data:www-data ./${DOC_ROOT} /var/www/smart/

COPY --chown=www-data:www-data ./${DOC_ROOT}/bootstrap/cache/config.php.docker.prod /var/www/smart/bootstrap/cache/config.php
COPY --chown=www-data:www-data ./${DOC_ROOT}/.env.prod /var/www/smart/.env

#for Development
#COPY --chown=www-data:www-data ./${DOC_ROOT}/bootstrap/cache/config.php.docker.dev /var/www/bootstrap/cache/config.php
#COPY --chown=www-data:www-data ./${DOC_ROOT}/.env_dev /var/www/.env

#COPY --from=composer:2.1 /usr/bin/composer /usr/local/bin/composer

RUN composer install --no-interaction



# For Laravel Installations

#RUN php artisan key:generate
RUN php artisan config:cache
RUN chown -R www-data:www-data .
RUN chmod -R 755 ./storage

USER www-data

EXPOSE 9000

CMD ["php-fpm"]
