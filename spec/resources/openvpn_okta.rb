# frozen_string_literal: true

require_relative '../spec_helper'

shared_context 'openvpn_okta' do
  step_into :openvpn_okta

  default_attributes['test'] = {}

  recipe do
    openvpn_okta 'default' do
      node['test'].each { |k, v| send(k, v) }
    end
  end

  shared_examples_for 'any platform' do
    context 'the default action' do
      default_attributes['test']['url'] = 'example.com'
      default_attributes['test']['token'] = 'abc123'

      it { is_expected.to install_openvpn_okta('default') }
      it { is_expected.to enable_openvpn_okta('default') }
    end

    context 'the :install action' do
      default_attributes['test']['action'] = :install

      it { is_expected.to install_package('okta-openvpn') }
    end

    context 'the :enable action' do
      default_attributes['test']['action'] = :enable

      shared_examples_for 'any valid property set' do
        it { is_expected.to include_recipe('openvpn') }

        it do
          expect(chef_run.openvpn_conf('server').plugins).to eq(
            [
              '/usr/lib/openvpn/plugins/okta/defer_simple.so ' \
              "/usr/lib/openvpn/plugins/okta/okta_openvpn.py\n" \
              'tmp-dir "/etc/openvpn/tmp"'
            ]
          )
        end
      end

      context 'all required properties' do
        default_attributes['test']['url'] = 'example.com'
        default_attributes['test']['token'] = 'abc123'

        it_behaves_like 'any valid property set'

        it do
          is_expected.to create_directory('/etc/openvpn/tmp')
            .with(user: 'nobody', group: 'nobody')
        end

        it do
          exp = <<-EXP.gsub(/^ +/, '')
            # This file is managed by Chef.
            # Any manual changes will be overwritten.
            [OktaAPI]
            Url: example.com
            Token: abc123
          EXP
          is_expected.to create_file('/etc/openvpn/okta_openvpn.ini')
            .with(content: exp)
        end
      end

      context 'an overridden username_suffix property' do
        default_attributes['test']['url'] = 'example.com'
        default_attributes['test']['token'] = 'abc123'
        default_attributes['test']['username_suffix'] = 'example.com'

        it_behaves_like 'any valid property set'

        it do
          is_expected.to create_directory('/etc/openvpn/tmp')
            .with(user: 'nobody', group: 'nobody')
        end

        it do
          exp = <<-EXP.gsub(/^ +/, '')
            # This file is managed by Chef.
            # Any manual changes will be overwritten.
            [OktaAPI]
            Url: example.com
            Token: abc123
            UsernameSuffix: example.com
          EXP
          is_expected.to create_file('/etc/openvpn/okta_openvpn.ini')
            .with(content: exp)
        end
      end

      context 'an overridden allow_untrusted_users property' do
        default_attributes['test']['url'] = 'example.com'
        default_attributes['test']['token'] = 'abc123'
        default_attributes['test']['allow_untrusted_users'] = true

        it_behaves_like 'any valid property set'

        it do
          is_expected.to create_directory('/etc/openvpn/tmp')
            .with(user: 'nobody', group: 'nobody')
        end

        it do
          exp = <<-EXP.gsub(/^ +/, '')
            # This file is managed by Chef.
            # Any manual changes will be overwritten.
            [OktaAPI]
            Url: example.com
            Token: abc123
            AllowUntrustedUsers: True
          EXP
          is_expected.to create_file('/etc/openvpn/okta_openvpn.ini')
            .with(content: exp)
        end
      end

      context 'an overridden user property' do
        default_attributes['test']['url'] = 'example.com'
        default_attributes['test']['token'] = 'abc123'
        default_attributes['test']['user'] = 'me'

        it_behaves_like 'any valid property set'

        it do
          is_expected.to create_directory('/etc/openvpn/tmp')
            .with(user: 'me', group: 'nobody')
        end

        it do
          exp = <<-EXP.gsub(/^ +/, '')
            # This file is managed by Chef.
            # Any manual changes will be overwritten.
            [OktaAPI]
            Url: example.com
            Token: abc123
          EXP
          is_expected.to create_file('/etc/openvpn/okta_openvpn.ini')
            .with(content: exp)
        end
      end

      context 'an overridden group property' do
        default_attributes['test']['url'] = 'example.com'
        default_attributes['test']['token'] = 'abc123'
        default_attributes['test']['group'] = 'us'

        it_behaves_like 'any valid property set'

        it do
          is_expected.to create_directory('/etc/openvpn/tmp')
            .with(user: 'nobody', group: 'us')
        end

        it do
          exp = <<-EXP.gsub(/^ +/, '')
            # This file is managed by Chef.
            # Any manual changes will be overwritten.
            [OktaAPI]
            Url: example.com
            Token: abc123
          EXP
          is_expected.to create_file('/etc/openvpn/okta_openvpn.ini')
            .with(content: exp)
        end
      end

      context 'a missing url property' do
        default_attributes['test']['token'] = 'abc123'

        it do
          expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end

      context 'a missing token property' do
        default_attributes['test']['url'] = 'example.com'

        it do
          expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end
    end

    context 'the :disable action' do
      default_attributes['test']['action'] = :disable

      it { is_expected.to include_recipe('openvpn') }
      it { expect(chef_run.openvpn_conf('server').plugins).to eq([]) }
      it { is_expected.to delete_file('/etc/openvpn/okta_openvpn.ini') }

      it do
        is_expected.to delete_directory('/etc/openvpn/tmp')
          .with(recursive: true)
      end
    end
  end
end
