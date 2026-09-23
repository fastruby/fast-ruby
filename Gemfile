source 'https://rubygems.org'

gem 'benchmark-ips', '>= 2.0'

gem 'activesupport', '>= 2.2.1'
gem 'e2mmap'

# Needed on Ruby 4.0+, where ostruct is no longer a default gem (3.4 warns).
# Keep the `if`: older Rubies benchmark the ostruct they ship, and the gem
# does not even parse on Ruby 2.1.
gem 'ostruct' if RUBY_VERSION >= '3.4'

gem 'rake'
