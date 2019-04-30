# frozen_string_literal: true

unless respond_to? :resolve_gem
  def resolve_gem(*opts)
    gem(*opts)
  end
end

source 'https://rubygems.org' do
  resolve_gem 'activerecord'
  resolve_gem 'psych', '~> 3.1'
  resolve_gem 'r18n-core'
  resolve_gem 'r18n-rails-api'
  resolve_gem 'rake'
  resolve_gem 'roo'
  resolve_gem 'roo-xls'
  resolve_gem 'telegram-bot-ruby'
  resolve_gem 'tzinfo'
  resolve_gem 'unicode'
  resolve_gem 'will_paginate'

  group :test do
    resolve_gem 'database_cleaner'
    resolve_gem 'factory_bot'
    resolve_gem 'rspec'
    resolve_gem 'rubocop'
    resolve_gem 'simplecov'
    resolve_gem 'sqlite3', '~> 1.3.0'
    resolve_gem 'timecop'
  end
end
