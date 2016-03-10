# Dockerfile for a Rails application using Nginx and Unicorn

# Select ubuntu as the base image
FROM ruby:2.2.3

# Install nginx, nodejs and curl
RUN apt-get update -qq && apt-get install -y build-essential

# POSTGRES
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

# Add rails project to project directory
ADD ./ /rails

# set WORKDIR
WORKDIR /rails

ENV RAILS_ENV production
ENV PORT 8080

# bundle install
RUN bundle install --without development test

# Publish port 8080
EXPOSE 8080

# Startup commands
CMD bundle exec rake db:create db:migrate assets:precompile && foreman start -f Procfile