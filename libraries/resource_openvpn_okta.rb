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

require 'chef/dsl/include_recipe'
require 'chef/resource'

class Chef
  class Resource
    # A Chef custom resource for the OpenVPN Okta plugin.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class OpenvpnOkta < Resource
      include Chef::DSL::IncludeRecipe

      default_action %i(install enable)

      property :url, String
      property :token, String
      property :username_suffix, String
      property :allow_untrusted_users, [TrueClass, FalseClass]

      property :user, String, default: lazy { node['openvpn']['user'] }
      property :group, String, default: lazy { node['openvpn']['group'] }

      #
      # If the resource is to be enabled, shove the plugin into the root run
      # context's config resource at compile time so it only gets rendered once
      # and service notifications don't happen in an impossible order.
      #
      def after_created
        Array(action).each do |act|
          case act
          when :enable
            enable_plugin_shim!
          when :disable
            disable_plugin_shim!
          end
        end
      end

      #
      # Include the OpenVPN cookbook and immediatelyh add the Okta plugin to
      # its openvpn_conf resource.
      #
      def enable_plugin_shim!
        disable_plugin_shim!
        resources(openvpn_conf: 'server').plugins << plugin_str
      end

      #
      # Include the OpenVPN cookbook and immediately remove the Okta plugin
      # from its openvpn_conf resource.
      #
      def disable_plugin_shim!
        include_recipe 'openvpn'
        resources(openvpn_conf: 'server').plugins.delete(plugin_str)
      end

      #
      # Return the plugin string that gets added to or removed from the
      # openvpn_conf resource to enable or disable the plugin.
      #
      # @return [String] the plugin string
      #
      def plugin_str
        '/usr/lib/openvpn/plugins/okta/defer_simple.so ' \
          "/usr/lib/openvpn/plugins/okta/okta_openvpn.py\n" \
          'tmp-dir "/etc/openvpn/tmp"'
      end

      #
      # Install the OpenVPN Okta plugin.
      #
      action :install do
        package 'okta-openvpn'
      end

      #
      # Enable the Okta plugin by inserting it into OpenVPN's server config.
      # The enable action works on combination with the openvpn_conf resource
      # shim in the after_created method.
      #
      action :enable do
        %i(url token).each do |p|
          if new_resource.send(p).nil?
            raise(Chef::Exceptions::ValidationFailed,
                  "A '#{p}' property is required for the :enable action")
          end
        end

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
      end

      #
      # Ensure the plugin is removed from the plugins array for the OpenVPN
      # config. This action doesn't actually need to do anything to clean up
      # the OpenVPN config, since after_created will not add the plugin line to
      # it except for in the case of an :enable action.
      #
      action :disable do
        file('/etc/openvpn/okta_openvpn.ini') { action :delete }
        directory('/etc/openvpn/tmp') do
          recursive true
          action :delete
        end
      end
    end
  end
end
