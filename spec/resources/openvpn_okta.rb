# encoding: utf-8
# frozen_string_literal: true

require_relative '../resources'

shared_context 'resources::openvpn_okta' do
  include_context 'resources'

  let(:resource) { 'openvpn_okta' }
  let(:properties) { {} }
  let(:name) { 'default' }

  shared_examples_for 'any platform' do
    context 'the default action (:install)' do
      it 'installs the okta-openvpn package' do
        expect(chef_run).to install_package('okta-openvpn')
      end
    end
  end
end
