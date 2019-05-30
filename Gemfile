# frozen_string_literal: true

source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'v2.2')
gem 'solidus', github: 'solidusio/solidus', branch: branch
# Provides basic authentication functionality for testing parts of your engine
gem 'solidus_auth_devise'
gem 'deface'

if branch == 'master' || branch >= 'v2.3'
  gem 'rails', '~> 5.1.0' # HACK: broken bundler dependency resolution
  gem 'rails-controller-testing', group: :test
elsif branch >= 'v2.0'
  gem 'rails', '~> 5.0.3' # HACK: broken bundler dependency resolution
  gem 'rails-controller-testing', group: :test
else
  gem 'rails', '~> 4.2.0' # HACK: broken bundler dependency resolution
  gem 'rails_test_params_backport', group: :test
end

gemspec
