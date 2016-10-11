# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'openvpn_okta::default' do
  %i(url token username_suffix allow_untrusted_users).each do |a|
    let(a) { nil }
  end
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %i(url token username_suffix allow_untrusted_users).each do |a|
        node.normal['openvpn_okta'][a] = send(a) unless send(a).nil?
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  shared_examples_for 'any attribute set' do
    it 'includes the openvpn cookbook' do
      expect(chef_run).to include_recipe('openvpn')
    end

    it 'modifies the openvpn service resource' do
      expect(chef_run.service('openvpn')).to do_nothing
    end

    it 'uses a log resource to notify the openvpn service' do
      l = 'Perform OpenVPN service actions delayed by openvpn_okta'
      expect(chef_run).to write_log(l)
      expect(chef_run.log(l)).to notify('service[openvpn]').to(:enable)
      expect(chef_run.log(l)).to notify('service[openvpn]').to(:start)
    end
  end

  context 'all required attributes' do
    let(:url) { 'example.com' }
    let(:token) { 'abc123' }

    it 'installs the OpenVPN Okta plugin' do
      expect(chef_run).to install_openvpn_okta('default')
        .with(url: url, token: token)
    end

    it 'enables the OpenVPN Okta plugin' do
      expect(chef_run).to enable_openvpn_okta('default')
        .with(url: url, token: token)
    end
  end

  context 'additional optional attributes' do
    let(:url) { 'example.com' }
    let(:token) { 'abc123' }
    let(:username_suffix) { 'example.com' }
    let(:allow_untrusted_users) { true }

    it 'installs the OpenVPN Okta plugin' do
      expect(chef_run).to install_openvpn_okta('default')
        .with(url: url,
              token: token,
              username_suffix: username_suffix,
              allow_untrusted_users: allow_untrusted_users)
    end

    it 'enables the OpenVPN Okta plugin' do
      expect(chef_run).to enable_openvpn_okta('default')
        .with(url: url,
              token: token,
              username_suffix: username_suffix,
              allow_untrusted_users: allow_untrusted_users)
    end
  end
end
