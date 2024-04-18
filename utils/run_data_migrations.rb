#!/usr/bin/env ruby
# File Location: utils/run_migrations.rb

require 'data_migrations'

DataMigrations.migrate!
