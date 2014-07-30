source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Bourbon sass mixins (vendor prefixes)
gem 'bourbon'


# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# uploader / image handling
gem 'rmagick'
gem 'carrierwave', '0.9.0'
gem 'exifr'

# CRC32
gem 'digest-crc'

# FFmpeg
gem 'streamio-ffmpeg'

# Pagination
gem 'bootstrap-will_paginate'

# Wiki parser
gem 'RedCloth'

#  bitflags to Active Records
gem 'flag_shih_tzu'

# Running jobs asynchronously
gem 'delayed_job_active_record'
gem 'daemons'

# Replace home-brew Authorization
gem 'cancan'

# ActiveRecord Session Store
gem 'activerecord-session_store'

# Stores changes to the DB
gem 'paper_trail', '~> 3.0.1'

# zip (download)
gem 'rubyzip'

# full text search
gem 'acts_as_indexed' # simple / old
gem 'sunspot_rails'   # powerful / new

gem 'cinch'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin]

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end

group :development, :test do
  # profiling, only for development
  gem 'rack-mini-profiler'

  # pre-packaged Solr distribution for use in development
  gem 'sunspot_solr'

  #optimize queries
  # gem 'bullet'
end

group :production do
  # mysql backend
  gem 'mysql2'

  # memcache caching backend
  gem 'dalli'
end