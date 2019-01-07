# frozen_string_literal: true

require_relative '../spec_helper'

describe 'openvpn_okta::default' do
  platform 'ubuntu'

  context 'all required attributes' do
    default_attributes['openvpn_okta']['url'] = 'example.com'
    default_attributes['openvpn_okta']['token'] = 'abc123'

    it do
      is_expected.to install_openvpn_okta('default')
        .with(url: 'example.com', token: 'abc123')
    end

    it do
      is_expected.to enable_openvpn_okta('default')
        .with(url: 'example.com', token: 'abc123')
    end
  end

  context 'additional optional attributes' do
    default_attributes['openvpn_okta']['url'] = 'example.com'
    default_attributes['openvpn_okta']['token'] = 'abc123'
    default_attributes['openvpn_okta']['username_suffix'] = 'example.com'
    default_attributes['openvpn_okta']['allow_untrusted_users'] = true

    it do
      is_expected.to install_openvpn_okta('default')
        .with(url: 'example.com',
              token: 'abc123',
              username_suffix: 'example.com',
              allow_untrusted_users: true)
    end

    it do
      is_expected.to enable_openvpn_okta('default')
        .with(url: 'example.com',
              token: 'abc123',
              username_suffix: 'example.com',
              allow_untrusted_users: true)
    end
  end
end
