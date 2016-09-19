# encoding: utf-8
# frozen_string_literal: true

require_relative 'spec_helper'

control 'openvpn_okta_app' do
  impact 1.0
  title 'OpenVPN Okta: Plugin is installed'
  desc 'The OpenVPN Okta plugin is installed'

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
end
