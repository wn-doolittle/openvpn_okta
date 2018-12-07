# frozen_string_literal: true

#
# Cookbook:: openvpn_okta
# Library:: resource/openvpn_okta_rhel
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
    # A Chef custom resource for the OpenVPN Okta plugin for RHEL.
    #
    # @author Jonathan Hartman <jonathan.hartman@tylertech.com>
    class OpenvpnOktaRhel < OpenvpnOkta
      provides :openvpn_okta, platform_family: 'rhel'

      #
      # Install the OpenVPN Okta plugin.
      #
      action :install do
        packagecloud_repo('socrata-platform/okta-openvpn') { type 'rpm' }
        super()
      end

      #
      # Remove the OpenVPN Okta plugin.
      #
      action :remove do
        package('okta-openvpn') { action :remove }
        yum_repository('socrata-platform_okta-openvpn') { action :remove }
      end
    end
  end
end
