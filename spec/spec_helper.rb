require 'specinfra'
require 'specinfra/backend/extension/ssh_su'
require 'rspec/mocks/standalone'
require 'rspec/its'
require 'specinfra/helper/set'
include Specinfra::Helper::Set

set :backend, :ssh_su

module Specinfra
  module Backend
    class Ssh
      def run_command(cmd, opts={})
        CommandResult.new :stdout => nil, :exit_status => 0
      end
    end
  end
end

RSpec.configure do |c|
  c.add_setting :su_user,    :deafult => nil
  c.add_setting :su_path,    :deafult => nil
  c.add_setting :disable_su, :deafult => false
end
