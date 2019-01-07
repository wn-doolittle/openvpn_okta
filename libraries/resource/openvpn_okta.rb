# frozen_string_literal: true

#
# Cookbook:: openvpn_okta
# Library:: resource/openvpn_okta
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

require 'chef/dsl/declare_resource'
require 'chef/resource'

class Chef
  class Resource
    # A Chef custom resource for the OpenVPN Okta plugin.
    #
    # @author Jonathan Hartman <jonathan.hartman@tylertech.com>
    class OpenvpnOkta < Resource
      include Chef::DSL::DeclareResource

      provides :openvpn_okta do |_node|
        false
      end

      default_action %i[install enable]

      property :url, String
      property :token, String
      property :username_suffix, String
      property :allow_untrusted_users, [TrueClass, FalseClass]

      property :user,
               String,
               default: lazy { node['openvpn']['config']['user'] }
      property :group,
               String,
               default: lazy { node['openvpn']['config']['group'] }

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
      # Declare an openvpn_conf resource if one hasn't already been defined and
      # add the Okta plugin to its config.
      #
      def enable_plugin_shim!
        create_conf_dir!
        srvr = declare_resource(:openvpn_conf, 'server')
        srvr.sensitive(true)
        conf = srvr.config.to_h.dup
        conf['plugin'] ||= []
        conf['plugin'] << plugin_str
        srvr.config(conf)
      end

      #
      # If an openvpn_conf resource exists, ensure the Okta plugin is removed
      # from its config. Otherwise, do nothing.
      #
      def disable_plugin_shim!
        srvr = find_resource(:openvpn_conf, 'server')
        return unless srvr && srvr.config && srvr.config['plugin']

        create_conf_dir!
        conf = srvr.config.to_h.dup
        conf['plugin'].delete(plugin_str)
        srvr.config(conf)
      end

      #
      # Declare a resource to create the OpenVPN config directory. This is
      # needed because the openvpn cookbook's version lives in a recipe; the
      # openvpn_conf resource doesn't check first that its directory exists.
      #
      def create_conf_dir!
        dir = ::File.join(node['openvpn']['fs_prefix'], '/etc/openvpn')
        declare_resource(:directory, dir).recursive(true)
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
        %i[url token].each do |p|
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