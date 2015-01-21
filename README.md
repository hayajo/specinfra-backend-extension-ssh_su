# Specinfra::Backend::Extension::SshSu

SSH + su backend for specinfra.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'specinfra-backend-extension-ssh_su'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install specinfra-backend-extension-ssh_su

## Usage

```ruby
require 'specinfra'
require 'specinfra/helper/set'
require 'specinfra/backend/extension/ssh_su'
require 'highline/import'

include Specinfra::Helper::Set
include Specinfra::Helper::Os

host = ARGV[0]

set :host, host
set :backend, :ssh_su

options = Net::SSH::Config.for(host)
options[:user] = ask("Enter ssh user: ")
options[:password] = ask("Enter ssh password: ") { |q| q.echo = false }
set :ssh_options, options

set :su_password, ask("Enter su password: ") { |q| q.echo = false }

puts Specinfra::Runner::run_command('whoami').stdout
puts Specinfra::Runner::run_command('cat /etc/passwd | grep `whoami`').stdout

set :os, os
if Specinfra.configuration.os[:family] == 'redhat'
  puts Specinfra::Runner::install_package('epel-release').stdout
end

puts Specinfra::Runner::install_package('nginx').stdout
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/specinfra-backend-extension-ssh_su/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
