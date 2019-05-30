# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_paybright/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_paybright'
  s.version     = SolidusPaybright::VERSION
  s.summary     = 'Solidus extension for the Paybright payment method'
  s.description = 'This extension provides the Paybright payment option for your Solidus storefront'
  s.license     = 'BSD-3-Clause'

  s.author    = 'Alessandro Lepore'
  s.email     = 'alessandro@stembolt.com'
  s.homepage  = 'https://stembolt.com/'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_frontend', '>= 1.4.0'
  s.add_dependency 'solidus_support'
  s.add_dependency 'typhoeus'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg', '~> 0.21'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '>= 0.38'
  s.add_development_dependency 'rubocop-rspec', '1.4.0'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
