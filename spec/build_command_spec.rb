require 'spec_helper'

set :backend, :ssh_su

describe Specinfra::Backend::Ssh do
  describe '#build_command' do
    context 'with root user' do
      before do
        RSpec.configure do |c|
          set :ssh_options, :user => 'root'
          c.ssh = double(:ssh, Specinfra.configuration.ssh_options)
        end
      end

      it 'should not prepend sudo' do
        expect(Specinfra.backend.build_command('test -f /etc/passwd')).to eq '/bin/sh -c test\ -f\ /etc/passwd'
      end

      it 'should escape special characters' do
        expect(Specinfra.backend.build_command('test ! -f /etc/selinux/config || (getenforce | grep -i -- disabled && grep -i -- ^SELINUX=disabled$ /etc/selinux/config)')).to eq '/bin/sh -c test\ \!\ -f\ /etc/selinux/config\ \|\|\ \(getenforce\ \|\ grep\ -i\ --\ disabled\ \&\&\ grep\ -i\ --\ \^SELINUX\=disabled\$\ /etc/selinux/config\)'
      end
    end

    context 'with non-root user' do
      before do
        RSpec.configure do |c|
          set :ssh_options, :user => 'foo'
          c.ssh = double(:ssh, Specinfra.configuration.ssh_options)
        end
      end

      it 'should prepend su' do
        expect(Specinfra.backend.build_command('test -f /etc/passwd')).to eq 'su - root -c /bin/sh\\ -c\\ test\\\\\\ -f\\\\\\ /etc/passwd'
      end

      it 'should escape special characters' do
        expect(Specinfra.backend.build_command('test ! -f /etc/selinux/config || (getenforce | grep -i -- disabled && grep -i -- ^SELINUX=disabled$ /etc/selinux/config)')).to eq 'su - root -c /bin/sh\\ -c\\ test\\\\\\ \\\\\\!\\\\\\ -f\\\\\\ /etc/selinux/config\\\\\\ \\\\\\|\\\\\\|\\\\\\ \\\\\\(getenforce\\\\\\ \\\\\\|\\\\\\ grep\\\\\\ -i\\\\\\ --\\\\\\ disabled\\\\\\ \\\\\\&\\\\\\&\\\\\\ grep\\\\\\ -i\\\\\\ --\\\\\\ \\\\\\^SELINUX\\\\\\=disabled\\\\\\$\\\\\\ /etc/selinux/config\\\\\\)'
      end
    end

    context 'with custom su user' do before do
        RSpec.configure do |c|
          set :ssh_options, :user => 'foo'
          c.ssh = double(:ssh, Specinfra.configuration.ssh_options)
          c.su_user = 'bar'
        end
      end

      after do
        RSpec.configure do |c|
          c.su_user = nil
        end
      end

      it 'command pattern 1a' do
        expect(Specinfra.backend.build_command('test -f /etc/passwd')).to eq 'su - bar -c /bin/sh\\ -c\\ test\\\\\\ -f\\\\\\ /etc/passwd'
      end

      it 'command pattern 2a' do
        expect(Specinfra.backend.build_command('test ! -f /etc/selinux/config || (getenforce | grep -i -- disabled && grep -i -- ^SELINUX=disabled$ /etc/selinux/config)')).to eq 'su - bar -c /bin/sh\\ -c\\ test\\\\\\ \\\\\\!\\\\\\ -f\\\\\\ /etc/selinux/config\\\\\\ \\\\\\|\\\\\\|\\\\\\ \\\\\\(getenforce\\\\\\ \\\\\\|\\\\\\ grep\\\\\\ -i\\\\\\ --\\\\\\ disabled\\\\\\ \\\\\\&\\\\\\&\\\\\\ grep\\\\\\ -i\\\\\\ --\\\\\\ \\\\\\^SELINUX\\\\\\=disabled\\\\\\$\\\\\\ /etc/selinux/config\\\\\\)'
      end
    end

    context 'with custom su path' do before do
        RSpec.configure do |c|
          set :ssh_options, :user => 'foo'
          c.ssh = double(:ssh, Specinfra.configuration.ssh_options)
          c.su_path = '/usr/local/bin'
        end
      end

      after do
        RSpec.configure do |c|
          c.sudo_path = nil
        end
      end

      it 'command pattern 1a' do
        expect(Specinfra.backend.build_command('test -f /etc/passwd')).to eq '/usr/local/bin/su - root -c /bin/sh\\ -c\\ test\\\\\\ -f\\\\\\ /etc/passwd'
      end

      it 'command pattern 2a' do
        expect(Specinfra.backend.build_command('test ! -f /etc/selinux/config || (getenforce | grep -i -- disabled && grep -i -- ^SELINUX=disabled$ /etc/selinux/config)')).to eq '/usr/local/bin/su - root -c /bin/sh\\ -c\\ test\\\\\\ \\\\\\!\\\\\\ -f\\\\\\ /etc/selinux/config\\\\\\ \\\\\\|\\\\\\|\\\\\\ \\\\\\(getenforce\\\\\\ \\\\\\|\\\\\\ grep\\\\\\ -i\\\\\\ --\\\\\\ disabled\\\\\\ \\\\\\&\\\\\\&\\\\\\ grep\\\\\\ -i\\\\\\ --\\\\\\ \\\\\\^SELINUX\\\\\\=disabled\\\\\\$\\\\\\ /etc/selinux/config\\\\\\)'
      end
    end

    context 'without su' do
      before do
        RSpec.configure do |c|
          set :ssh_options, :user => 'foo'
          c.ssh = double(:ssh, Specinfra.configuration.ssh_options)
          c.disable_su = true
        end
      end

      after do
        RSpec.configure do |c|
          c.disable_su = false
        end
      end

      it 'command pattern 1b' do
        expect(Specinfra.backend.build_command('test -f /etc/passwd')).to eq '/bin/sh -c test\ -f\ /etc/passwd'
      end

      it 'command pattern 2b' do
        expect(Specinfra.backend.build_command('test ! -f /etc/selinux/config || (getenforce | grep -i -- disabled && grep -i -- ^SELINUX=disabled$ /etc/selinux/config)')).to eq '/bin/sh -c test\ \!\ -f\ /etc/selinux/config\ \|\|\ \(getenforce\ \|\ grep\ -i\ --\ disabled\ \&\&\ grep\ -i\ --\ \^SELINUX\=disabled\$\ /etc/selinux/config\)'
      end
    end
  end
end
