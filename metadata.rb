# encoding: utf-8
# frozen_string_literal: true

name 'openvpn_okta'
maintainer 'Jonathan Hartman'
maintainer_email 'jonathan.hartman@socrata.com'
license 'apachev2'
description 'Installs/configures the OpenVPN Okta plugin'
long_description 'Installs/configures the OpenVPN Okta plugin'
version '0.1.0'

source_url 'https://github.com/socrata-cookbooks/openvpn_okta'
issues_url 'https://github.com/socrata-cookbooks/openvpn_okta/issues'

chef_version '>= 12.1'

depends 'packagecloud', '~> 0.2'
depends 'openvpn', '~> 2.1'

supports 'ubuntu'
supports 'redhat'
supports 'centos'
supports 'scientific'
