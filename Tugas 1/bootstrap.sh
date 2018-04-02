#!/usr/bin/env bash

# add a user
useradd -m -s /bin/bash awan
echo -e "buayakecil\nbuayakecil" | passwd awan

# phoenix
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb
apt-get update
apt-get install -y esl-erlang
apt-get install -y elixir
mix local.hex --force
mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez
apt-get install -y nodejs
apt-get install -y postgresql postgresql-contrib
apt-get install -y inotify-tools

# php
apt-get install -y php

# mysql
debconf-set-selections <<< 'mysql-server mysql-server/root_password password 123'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 123'
apt-get install -y mysql-server

# composer, nginx
apt-get install -y composer
apt-get install -y nginx

# laravel
apt-get install -y php7.0-zip
composer global require "laravel/installer"
export PATH="$PATH:~/.composer/vendor/bin"
source ~/.bashrc

# squid, bind9
apt-get install -y squid
apt-get install -y bind9
