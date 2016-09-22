# encoding: utf-8
# frozen_string_literal: true
#
# Cookbook Name:: openvpn_okta
# Library:: resource_openvpn_okta
#
# Copyright 2016, Socrata, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource'

class Chef
  class Resource
    # A Chef custom resource for the OpenVPN Okta plugin.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class OpenvpnOkta < Resource
      default_action %i(install enable)

      property :url, String
      property :token, String
      property :username_suffix, String
      property :allow_untrusted_users, [TrueClass, FalseClass]

      property :user, String, default: lazy { node['openvpn']['user'] }
      property :group, String, default: lazy { node['openvpn']['group'] }

      #
      # Install the OpenVPN Okta plugin.
      #
      action :install do
        package 'okta-openvpn'
      end

      #
      # Enable the Okta plugin by inserting it into OpenVPN's server config.
      #
      action :enable do
        %i(url token).each do |p|
          if new_resource.send(p).nil?
            raise(Chef::Exceptions::ValidationFailed,
                  "A '#{p}' property is required for the :enable action")
          end
        end

        include_recipe 'openvpn'

        directory '/etc/openvpn/tmp' do
          owner new_resource.user
          group new_resource.group
        end

        file '/etc/openvpn/okta_openvpn.ini' do
          lines = ['# This file is managed by Chef.',
                   '# Any manual changes will be overwritten.',
                   '[OktaAPI]',
                   "Url: #{new_resource.url}",
                   "Token: #{new_resource.token}"]
          if new_resource.username_suffix
            lines << "UsernameSuffix: #{new_resource.username_suffix}"
          end
          if new_resource.allow_untrusted_users
            lines << 'AllowUntrustedUsers: True'
          end
          content lines.join("\n")
        end

        p = '/usr/lib/openvpn/plugins/okta/defer_simple.so ' \
          "/usr/lib/openvpn/plugins/okta/okta_openvpn.py\n" \
          'tmp-dir "/etc/openvpn/tmp"'
        with_run_context :root do
          edit_resource :openvpn_conf, 'server' do
            plugins.include?(p) || plugins << p
            action :nothing
          end
        end
        log 'Generate the OpenVPN config with Okta enabled' do
          notifies :create, 'openvpn_conf[server]'
        end
      end

      #
      # Ensure the plugin is removed from the plugins array for the OpenVPN
      # config.
      #
      action :disable do
        p = '/usr/lib/openvpn/plugins/okta/defer_simple.so ' \
          "/usr/lib/openvpn/plugins/okta/okta_openvpn.py\n" \
          'tmp-dir "/etc/openvpn/tmp"'
        with_run_context :root do
          edit_resource :openvpn_conf, 'server' do
            plugins.delete(p)
            action :nothing
          end
        end
        log 'Generate the OpenVPN config with Okta disabled' do
          notifies :create, 'openvpn_conf[server]'
        end

        file('/etc/openvpn/okta_openvpn.ini') { action :delete }
        directory('/etc/openvpn/tmp') do
          recursive true
          action :delete
        end
      end
    end
  end
end
