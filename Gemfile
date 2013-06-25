source 'http://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rake'
gem 'rails', "~> 4.0.0.rc2"
gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'mysql2'
gem "delayed_job", github: "collectiveidea/delayed_job"
gem "delayed_job_active_record", github: "collectiveidea/delayed_job_active_record"
gem 'jquery-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '0.8.0'
gem 'govspeak', '~> 1.2.3'
gem 'kramdown', '~> 0.13.8'
gem 'validates_email_format_of'
gem 'friendly_id', github: 'FriendlyId/friendly_id', branch: 'rails4'
gem 'babosa'
gem 'nokogiri'
gem 'slimmer', '3.17.0'
gem 'plek', '1.1.0'
gem 'isbn_validation'
gem 'gds-sso', '3.0.4'
gem 'rummageable', '0.6.2'
gem 'addressable'
gem 'exception_notification', "4.0.0.rc1", require: 'exception_notifier'
gem 'rabl'
gem 'aws-ses', require: 'aws/ses'
gem 'newrelic_rpm'
gem 'lograge'
gem 'unicorn', '4.6.3'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'gds-api-adapters', '7.2.0'
gem 'whenever', '0.8.2', require: false
gem 'mini_magick'
gem 'shared_mustache', '~> 0.0.2'
gem 'rails-i18n'
gem 'globalize3', github: 'svenfuchs/globalize3', branch: 'rails4'
# for globalize3
gem 'paper_trail', github: 'airblade/paper_trail', branch: 'rails4'
gem 'link_header'
gem 'diffy'

group :transition do
  gem 'actionpack-page_caching'
  gem 'actionpack-action_caching'
end

group :assets do
  gem 'govuk_frontend_toolkit', '0.30.0'
  gem 'sass', '3.2.8'
  gem 'sass-rails', "~> 4.0.0.rc2"
  gem 'uglifier', '>= 1.3.0'
end

group :development, :test do
  gem 'thin', '1.5.1'
  gem 'quiet_assets'
  gem 'parallel_tests'
  gem 'bullet'
  gem 'test-queue'
  gem 'pry-rails'
end

group :test do
  # NOTE: keep until https://github.com/brynary/rack-test/pull/69 is merged
  gem 'rack-test', github: 'alphagov/rack-test'
  gem 'factory_girl'
  gem 'hash_syntax'
  gem 'mocha', '0.14.0', require: false
  gem 'test_track', github: 'episko/test_track'
  gem 'timecop'
  gem 'webmock', require: false
  gem 'ci_reporter'
  gem 'database_cleaner', '1.0.1'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber do
  gem 'cucumber'
  gem 'cucumber-rails', github: "cucumber/cucumber-rails", branch: "master_rails4_test" , require: false
  gem 'launchy', '~> 2.3.0'
  gem 'capybara', '~> 2.1.0'
  gem 'poltergeist', '~> 1.3.0'
end

group :router do
  gem 'router-client', '~> 3.0.1', require: 'router'
end
