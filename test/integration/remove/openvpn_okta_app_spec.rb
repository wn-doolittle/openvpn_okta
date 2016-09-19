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
      expect(subject).to_no be_installed
    end
  end
end
