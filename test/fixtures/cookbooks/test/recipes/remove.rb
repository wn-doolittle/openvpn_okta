# frozen_string_literal: true

include_recipe cookbook_name.to_s

openvpn_okta 'default' do
  action %i[disable remove]
end
