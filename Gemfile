source 'https://rubygems.org'

gem 'jruby-openssl', :platforms => :jruby
gem 'rake'
gem 'yard'

group :development do
  gem 'guard-rspec'
  gem 'kramdown'
  gem 'pry'
  gem 'pry-debugger', :platforms => :mri_19
end

group :test do
  gem 'mockingbird', '>= 0.2'
  gem 'rspec', '>= 2.11'
  gem 'simplecov', :require => false
end

gemspec
