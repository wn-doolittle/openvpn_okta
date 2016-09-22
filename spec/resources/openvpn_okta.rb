# encoding: utf-8
# frozen_string_literal: true

require_relative '../resources'

shared_context 'resources::openvpn_okta' do
  include_context 'resources'

  %i(url token username_suffix allow_untrusted_users user group).each do |p|
    let(p) { nil }
  end
  let(:resource) { 'openvpn_okta' }
  let(:properties) do
    {
      url: url,
      token: token,
      username_suffix: username_suffix,
      allow_untrusted_users: allow_untrusted_users,
      user: user,
      group: group
    }
  end
  let(:name) { 'default' }

  shared_context 'the default action (:install, :enable)' do
    let(:url) { 'example.com' }
    let(:token) { 'abc123' }
  end

  shared_context 'the :install action' do
    let(:action) { :install }
  end

  shared_context 'the :remove action' do
    let(:action) { :remove }
  end

  shared_context 'the :enable action' do
    let(:action) { :enable }
    let(:url) { 'example.com' }
    let(:token) { 'abc123' }
  end

  shared_context 'the :disable action' do
    let(:action) { :disable }
  end

  shared_examples_for 'any platform' do
    context 'the default action (:install, :enable)' do
      include_context description

      it 'installs the okta-openvpn package' do
        expect(chef_run).to install_package('okta-openvpn')
      end

      it 'includes the openvpn cookbook' do
        expect(chef_run).to include_recipe('openvpn')
      end

      it 'creates the OpenVPN temp dir' do
        expect(chef_run).to create_directory('/etc/openvpn/tmp')
          .with(user: 'nobody', group: 'nogroup')
      end

      it 'creates the OpenVPN ini file' do
        expected = <<-EOH.gsub(/^ +/, '').strip
          # This file is managed by Chef.
          # Any manual changes will be overwritten.
          [OktaAPI]
          Url: example.com
          Token: abc123
        EOH
        expect(chef_run).to create_file('/etc/openvpn/okta_openvpn.ini')
          .with(content: expected)
      end

      it 'adds the Okta plugin to the OpenVPN config' do
        expect(chef_run.openvpn_conf('server')).to do_nothing
        expect(chef_run.openvpn_conf('server').plugins).to eq(
          [
            '/usr/lib/openvpn/plugins/okta/defer_simple.so ' \
            "/usr/lib/openvpn/plugins/okta/okta_openvpn.py\n" \
            'tmp-dir "/etc/openvpn/tmp"'
          ]
        )
        expect(chef_run).to write_log(
          'Generate the OpenVPN config with Okta enabled'
        )
        expect(chef_run.log('Generate the OpenVPN config with Okta enabled'))
          .to notify('openvpn_conf[server]').to(:create)
      end
    end

    context 'the :install action' do
      include_context description

      it 'installs the okta-openvpn package' do
        expect(chef_run).to install_package('okta-openvpn')
      end
    end

    context 'the :enable action' do
      include_context description

      shared_examples_for 'any valid property set' do
        it 'includes the openvpn cookbook' do
          expect(chef_run).to include_recipe('openvpn')
        end

        it 'creates the OpenVPN temp dir' do
          expect(chef_run).to create_directory('/etc/openvpn/tmp')
            .with(user: user || 'nobody', group: group || 'nogroup')
        end

        it 'creates the OpenVPN ini file' do
          lines = [
            '# This file is managed by Chef.',
            '# Any manual changes will be overwritten.',
            '[OktaAPI]',
            'Url: example.com',
            'Token: abc123'
          ]
          lines << "UsernameSuffix: #{username_suffix}" if username_suffix
          lines << 'AllowUntrustedUsers: True' if allow_untrusted_users

          expect(chef_run).to create_file('/etc/openvpn/okta_openvpn.ini')
            .with(content: lines.join("\n"))
        end

        it 'adds the Okta plugin to the OpenVPN config' do
          expect(chef_run.openvpn_conf('server')).to do_nothing
          expect(chef_run.openvpn_conf('server').plugins).to eq(
            [
              '/usr/lib/openvpn/plugins/okta/defer_simple.so ' \
              "/usr/lib/openvpn/plugins/okta/okta_openvpn.py\n" \
              'tmp-dir "/etc/openvpn/tmp"'
            ]
          )
          expect(chef_run).to write_log(
            'Generate the OpenVPN config with Okta enabled'
          )
          expect(chef_run.log('Generate the OpenVPN config with Okta enabled'))
            .to notify('openvpn_conf[server]').to(:create)
        end
      end

      context 'all required properties set' do
        it_behaves_like 'any valid property set'
      end

      context 'an overridden username_suffix property' do
        let(:username_suffix) { 'example.com' }

        it_behaves_like 'any valid property set'
      end

      context 'an overridden allow_untrusted_users property' do
        let(:allow_untrusted_users) { true }

        it_behaves_like 'any valid property set'
      end

      context 'an overridden user property' do
        let(:user) { 'me' }

        it_behaves_like 'any valid property set'
      end

      context 'an overridden group property' do
        let(:group) { 'us' }

        it_behaves_like 'any valid property set'
      end

      context 'a missing url property' do
        let(:url) { nil }

        it 'raises an error' do
          expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end

      context 'a missing token property' do
        let(:token) { nil }

        it 'raises an error' do
          expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end
    end

    context 'the :disable action' do
      include_context description

      it 'does not add the Okta plugin to the OpenVPN config' do
        expect(chef_run.openvpn_conf('server')).to do_nothing
        expect(chef_run.openvpn_conf('server').plugins).to eq([])
        expect(chef_run).to write_log(
          'Generate the OpenVPN config with Okta disabled'
        )
        expect(chef_run.log('Generate the OpenVPN config with Okta disabled'))
          .to notify('openvpn_conf[server]').to(:create)
      end

      it 'deletes the OpenVPN ini file' do
        expect(chef_run).to delete_file('/etc/openvpn/okta_openvpn.ini')
      end

      it 'deletes the OpenVPN temp directory' do
        expect(chef_run).to delete_directory('/etc/openvpn/tmp')
          .with(recursive: true)
      end
    end
  end
end
