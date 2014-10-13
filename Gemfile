source 'https://rubygems.org'

gem 'sequel', '~> 4.14'
gem 'sqlite3', '~> 1.3'
gem 'ibm_db', '~> 2.5'
gem 'yard', '~> 0.8'

group :development do
  gem 'guard-rspec'
  gem 'pry'
  platforms :ruby_19, :ruby_20 do
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
  end
end

group :test do
  gem 'childlabor'
  gem 'coveralls', '>= 0.5.7'
  gem 'fakeweb', '>= 1.3'
  gem 'cupsffi', '~> 0.1'
  gem 'logger-better'
  gem 'tnt'
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rspec', '>= 3'
  gem 'rspec-mocks', '>= 3'
  gem 'rubocop', '>= 0.19', :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'simplecov', '>= 0.9'
  gem 'rest-client', '~> 1.6.0', :platforms => [:jruby, :ruby_18]
end

gemspec
