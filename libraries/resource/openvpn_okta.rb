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
      property :allowed_groups, String

      property :user,
               String,
               default: lazy { node['openvpn']['config']['user'] }
      property :group,
               String,
               default: lazy { node['openvpn']['config']['group'] }
      property :config,
               Hash,
               default: lazy { node['openvpn']['config'] }

      #
      # If the resource is to be enabled, shove the plugin into the root run
      # context's config resource at compile time so it only gets rendered once
      # and service notifications don't happen in an impossible order.
      #
      def after_created
        Array(action).each do |act|
          case act
          when :enable
            enable_shim!
            # After we enable the shim, we want to ensure that the attributes
            # remain so that as other `openvpn` recipes run, they continue to
            # include the plugin values.
            node.override['openvpn']['config']['plugin'] = plugin_str
            node.override['openvpn']['config']['tmp-dir'] = tmp_dir_str
          when :disable
            disable_shim!
          end
        end
      end

      #
      # Edit an openvpn_conf resource and if one hasn't already been defined
      # create it and add the Okta plugin and the tmp-dir to its config.
      #
      def enable_shim!
        create_supporting_dirs!
        conf = config.to_h.dup
        conf['plugin'] = plugin_str
        conf['tmp-dir'] = tmp_dir_str

        declare_resource(:openvpn_conf, 'server') do
          config conf
        end
      end

      #
      # If an openvpn_conf resource exists, ensure the Okta plugin is removed
      # from its config. Otherwise, do nothing.
      #
      def disable_shim!
        srvr = find_resource(:openvpn_conf, 'server')
        return unless srvr &.config && srvr.config['plugin']

        conf = config.to_h.dup
        conf.delete('plugin')
        conf.delete('tmp-dir')
        srvr.config(conf)
      end

      #
      # Declare a resource to create the OpenVPN config directory. This is
      # needed because the openvpn cookbook's version lives in a recipe; the
      # openvpn_conf resource doesn't check first that its directory exists.
      # After the config dir has been created, ensure the creation of the
      # tmp dir which is required for the plugin to function properly
      #
      def create_supporting_dirs!
        %w[openvpn openvpn/tmp].each do |dir_str|
          dir = ::File.join(node['openvpn']['fs_prefix'], "/etc/#{dir_str}")
          declare_resource(:directory, dir)
        end
      end

      #
      # Return the plugin string that gets added to or removed from the
      # openvpn_conf resource to enable or disable the plugin.
      #
      # @return [String] the plugin string
      #
      def plugin_str
        '/usr/lib/openvpn/plugins/okta/defer_simple.so ' \
          '/usr/lib/openvpn/plugins/okta/okta_openvpn.py'
      end

      #
      # Return the tmp-dir string that gets added to or removed from the
      # openvpn_conf resource to when enabling or disabling the Okta plugin.
      #
      # @return [String] the tmp-dir string
      #
      def tmp_dir_str
        '/etc/openvpn/tmp'
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
          lines << "UsernameSuffix: #{new_resource.username_suffix}" if new_resource.username_suffix
          lines << 'AllowUntrustedUsers: True' if new_resource.allow_untrusted_users
          lines << "AllowedGroups: #{new_resource.allowed_groups}" if new_resource.allowed_groups
          content lines.join("\n")
          sensitive true
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
