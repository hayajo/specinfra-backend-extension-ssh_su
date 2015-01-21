require "specinfra/backend/extension/ssh_su/version"
require "specinfra/backend/ssh"

module Specinfra
  module Backend
    module Extension
      module SshSu
      end
    end

    class SshSu < Ssh
      def initialize
        Specinfra.configuration.disable_sudo = true
      end

      def run_command(cmd, opt={})
        cmd = build_command(cmd)
        res = super(cmd)

        if su?
          stdout = res.instance_variable_get(:@stdout).gsub!(/\A\n/, "")

          if @example
            @example.metadata[:stdout] = stdout
          end
        end

        res
      end

      def build_command(cmd)
        cmd = super(cmd)
        if su?
          su_user = Specinfra.configuration.su_user || 'root'
          cmd = "#{su} #{su_user} -c #{cmd}"
        end
        cmd
      end

      private
      def prompt
        Specinfra.configuration.su_prompt || 'Password: '
      end

      def ssh_exec!(command)
        stdout_data = ''
        stderr_data = ''
        exit_status = nil
        exit_signal = nil

        if Specinfra.configuration.ssh.nil?
          Specinfra.configuration.ssh = create_ssh
        end

        ssh = Specinfra.configuration.ssh
        ssh.open_channel do |channel|
          if Specinfra.configuration.su_password or Specinfra.configuration.request_pty
            channel.request_pty do |ch, success|
              abort "Could not obtain pty " if !success
            end
          end
          channel.exec("#{command}") do |ch, success|
            abort "FAILED: couldn't execute command (ssh.channel.exec)" if !success
            channel.on_data do |ch, data|
              if data.match /^#{prompt}/
                channel.send_data "#{Specinfra.configuration.su_password}\n"
              else
                stdout_data += data
              end
            end

            channel.on_extended_data do |ch, type, data|
              if data.match /(standard in must be a tty|must be run from a terminal)/
                abort 'Please write "set :request_pty, true" in your spec_helper.rb or other appropriate file.'
              end

              stderr_data += data
            end

            channel.on_request("exit-status") do |ch, data|
              exit_status = data.read_long
            end

            channel.on_request("exit-signal") do |ch, data|
              exit_signal = data.read_long
            end
          end
        end
        ssh.loop
        { :stdout => stdout_data, :stderr => stderr_data, :exit_status => exit_status, :exit_signal => exit_signal }
      end

      def su
        if su_path = Specinfra.configuration.su_path
          su_path += '/su'
        else
          su_path = 'su'
        end

        su_options = Specinfra.configuration.su_options
        if su_options
          su_options = su_options.shelljoin if su_options.is_a?(Array)
          su_options = ' ' + su_options
        end

        "#{su_path.shellescape}#{su_options}"
      end

      def su?
        user = Specinfra.configuration.ssh_options[:user]
        disable_su = Specinfra.configuration.disable_su
        user != 'root' && !disable_su
      end
    end

  end
end
