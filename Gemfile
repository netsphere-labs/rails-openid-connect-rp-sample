# -*- coding:utf-8; mode:ruby -*-

# OpenID Connect Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.


# $ rails _6.1.7.7_ new --skip-turbolinks --skip-bundle --webpack=stimulus --skip-active-storage OpenIdConnectRpSample

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7', '>= 6.1.7.7'

# Use sqlite3 as the database for Active Record
# v1.x系統でないといけない
gem 'sqlite3', '~> 1.4'

# Use Puma as the app server
#gem 'puma', '~> 5.0'

# Use SCSS for stylesheets
# 廃れた.
#gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# Webpacker は廃れた. 剥がす.
#gem 'webpacker', '~> 5.0'
gem 'jsbundling-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

if RUBY_VERSION != "3.3.1"
  # Reduces boot times through caching; required in config/boot.rb
  gem 'bootsnap', '>= 1.4.4', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger
  # console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem 'web-console', '>= 4.1.0'

  # Display performance information such as SQL time and flame graphs for each
  # request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.0'

  gem 'listen', '~> 3.3'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# OmniAuth は使わない。
gem 'openid_connect'

# 認証フレームワークは何でも構わない
gem 'sorcery'
