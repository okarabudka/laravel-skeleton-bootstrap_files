FROM php:8.4-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip git libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libzip-dev libxml2-dev libcurl4-openssl-dev \
    libicu-dev libsqlite3-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_sqlite gd intl opcache zip bcmath \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer/composer:2-bin /composer /usr/local/bin/composer

WORKDIR /var/www

CMD ["php-fpm"]
