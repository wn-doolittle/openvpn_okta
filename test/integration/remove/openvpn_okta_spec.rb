# encoding: utf-8
# frozen_string_literal: true

require_relative 'spec_helper'

control 'openvpn_okta_app' do
  impact 1.0
  title 'OpenVPN Okta: Plugin is uninstalled'
  desc 'The OpenVPN Okta plugin is uninstalled'

  describe apt(
    'https://packagecloud.io/socrata-platform/duo-openvpn/ubuntu'
  ) do
    it 'does not exist' do
      expect(subject).to_not exist
    end
  end

  describe package('okta-openvpn') do
    it 'is not installed' do
      expect(subject).to_not be_installed
    end
  end

  describe file('/etc/openvpn/server.conf') do
    it 'does not have the Okta plugin configured' do
      rs = [Regexp.new('^plugin /usr/lib/openvpn/plugins/defer_simple\\.so ' \
                       '/usr/lib/openvpn/plugins/okta_openvpn\.py$'),
            Regexp.new('^tmp-dir "/etc/openvpn/tmp"$')]
      rs.each { |r| expect(subject.content).to_not match(r) }
    end
  end

  describe file('/etc/openvpn/okta_openvpn.ini') do
    it 'does not exist' do
      expect(subject).to_not exist
    end
  end
end
