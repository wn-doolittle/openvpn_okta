# frozen_string_literal: true

#
# Cookbook:: openvpn_okta
# Library:: resource/openvpn_okta_ubuntu
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

require_relative 'openvpn_okta'

class Chef
  class Resource
    # A Chef custom resource for the OpenVPN Okta plugin for Ubuntu.
    #
    # @author Jonathan Hartman <jonathan.hartman@tylertech.com>
    class OpenvpnOktaUbuntu < OpenvpnOkta
      provides :openvpn_okta, platform: 'ubuntu'

      #
      # Install the OpenVPN Okta plugin.
      #
      action :install do
        install_type = node['openvpn_okta']['install_type'] || 'deb'

        if install_type == 'deb'
          apt_update 'default'
          package 'gnupg'
          package 'ca-certificates'

          # Some platforms that have updated to OpenSSL 1.1 have started making
          # calls to `openssl rehash` in ca-certificates's postinst script. For
          # an example, see `/usr/sbin/update-ca-certificates` on Ubuntu 18.04.
          # Because Chef's package resource (as of 2019-01-04) prepends
          # `/opt/chef/embedded/bin` to the PATH, its OpenSSL 1.0 takes over and
          # the postinst script exits without enabling any certs.
          execute 'update-ca-certificates --fresh' do
            action :nothing
            subscribes :run, 'package[ca-certificates]', :immediately
          end
          packagecloud_repo('socrata-platform/okta-openvpn') { type 'deb' }
          super()
        else
          include_recipe 'build-essential::default'

          git_repo = node['openvpn_okta']['git_repo']
          build_dir = '/tmp/openvpn_okta'

          git build_dir do
            repository git_repo
            notifies :run, 'bash[make_openvpn_okta]', :immediately
          end

          bash 'make_openvpn_okta' do
            action :nothing
            cwd build_dir
            code 'make install'

            notifies :upgrade, "pip_requirements[#{build_dir}/requirements.txt]", :immediately
          end

          pip_requirements "#{build_dir}/requirements.txt"
        end
      end

      #
      # Remove the OpenVPN Okta plugin.
      #
      action :remove do
        package('okta-openvpn') { action :purge }
        apt_repository('socrata-platform_okta-openvpn') { action :remove }
      end
    end
  end
end
