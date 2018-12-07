# frozen_string_literal: true

apt_update 'default' if platform_family?('debian')

include_recipe 'openvpn_okta'

if platform_family?('rhel') && node['platform_version'].to_i >= 7
  edit_resource! :service, 'openvpn' do
    service_name 'openvpn@server'
  end
end
