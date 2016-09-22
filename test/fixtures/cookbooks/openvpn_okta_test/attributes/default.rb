# encoding: utf-8
# frozen_string_literal: true

default['openvpn_okta'].tap do |o|
  o['url'] = 'example.com'
  o['token'] = 'abc123'
end
