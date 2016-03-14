# Dockerfile for a Rails application using Nginx and Puma

# Select ubuntu as the base image
FROM seapy/ruby:2.3.0

MAINTAINER Edgar Z <edgar@factico.com.mx>

# Update
RUN apt-get update -q

# Postgres
RUN apt-get install -qy --force-yes libpq-dev

# for a JS runtime
RUN apt-get install -qy nodejs

RUN apt-get install -qy curl

# for nokogiri
#RUN apt-get install -qy libxml2-dev libxslt1-dev

# for capybara-webkit
#RUN apt-get install -qy libqt4-webkit libqt4-dev xvfb

# exiftool
#RUN apt-get install -qy libimage-exiftool-perl

# NGINX
RUN apt-get install -qy nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

# Install foreman
RUN gem install bundler
RUN gem install foreman
RUN gem install rails

# Add configuration files in repository to filesystem
ADD config/container/nginx-sites.conf /etc/nginx/sites-enabled/default

#(required) Install Rails App
# Add rails project to project directory
ADD ./ /docker

# set WORKDIR
WORKDIR /docker

# bundle install
RUN bundle install --without development test

ENV RAILS_ENV production
ENV PORT 8080

#(required) nginx port number
EXPOSE 8080

# Startup commands
CMD bundle exec rake db:create db:migrate assets:precompile && foreman start -f Procfile