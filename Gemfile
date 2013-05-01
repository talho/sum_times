#ruby=2.0.0-p0
#ruby-gemset=sumtimes


source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'devise'

gem 'parallel588-bootstrap-timepicker-rails', :require => 'bootstrap-timepicker-rails'
gem 'bootstrap-datepicker-rails'
gem 'week_of_month'
gem 'dynamic_form'
gem "actionmailer-with-request", "~> 0.4.0"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
group :production do
  gem 'unicorn'
end

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano-unicorn'
  gem "debugger"
end

group :test, :development do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'faker'
  gem 'shoulda'
end
