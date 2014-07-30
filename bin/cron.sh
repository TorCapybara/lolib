#!/usr/bin/env bash

# Make sure rake can find nodejs
PATH=$PATH:/usr/local/bin

# load rvm enviroment
# get local enviroment with: rvm env --path
# or for a specific rvm version: rvm env --path -- ruby-version[@gemset-name]
source /home/user/.rvm/environments/ruby-2.1.1

# Goto the base dir of the lolIB application and run the rake task(s)
cd /var/rails_apps/lolib/ && rake links:check_links RAILS_ENV=production
