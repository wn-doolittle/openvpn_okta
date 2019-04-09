# frozen_string_literal: true

apt_update 'default' if platform_family?('debian')
directory '/etc/openvpn'
include_recipe 'openvpn_okta'

openvpn_okta 'remove' do
  action %i[disable remove]
end
