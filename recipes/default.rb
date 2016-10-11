# encoding: utf-8
# frozen_string_literal: true
#
# Cookbook Name:: openvpn_okta
# Recipe:: default
#
# Copyright 2016, Socrata, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

attrs = node['openvpn_okta']

include_recipe 'openvpn'

edit_resource :service, 'openvpn' do
  action :nothing
end

log "Perform OpenVPN service actions delayed by #{cookbook_name}" do
  notifies :enable, 'service[openvpn]'
  notifies :start, 'service[openvpn]'
end

openvpn_okta 'default' do
  url attrs['url'] unless attrs['url'].nil?
  token attrs['token'] unless attrs['token'].nil?
  username_suffix attrs['username_suffix'] unless attrs['username_suffix'].nil?
  unless attrs['allow_untrusted_users'].nil?
    allow_untrusted_users attrs['allow_untrusted_users']
  end
end
