# encoding: utf-8
# frozen_string_literal: true

require_relative 'spec_helper'

control 'openvpn_okta' do
  impact 1.0
  title 'OpenVPN Okta: Plugin is installed and configured'
  desc 'The OpenVPN Okta plugin is installed and configured'

  describe apt(
    'https://packagecloud.io/socrata-platform/okta-openvpn/ubuntu'
  ) do
    it 'exists' do
      expect(subject).to exist
    end

    it 'is enabled' do
      expect(subject).to be_enabled
    end
  end

  describe package('okta-openvpn') do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  describe file('/etc/openvpn/server.conf') do
    it 'has the Okta plugin configured' do
      rs = [Regexp.new('^plugin /usr/lib/openvpn/plugins/okta/' \
                       'defer_simple\\.so ' \
                       '/usr/lib/openvpn/plugins/okta/okta_openvpn\.py$'),
            Regexp.new('^tmp-dir "/etc/openvpn/tmp"$')]
      rs.each { |r| expect(subject.content).to match(r) }
    end
  end

  describe file('/etc/openvpn/okta_openvpn.ini') do
    it 'is correctly configured' do
      rs = [/^Url: example\.com$/, /^Token: abc123$/]
      rs.each { |r| expect(subject.content).to match(r) }
    end
  end
end
