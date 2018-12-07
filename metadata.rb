# frozen_string_literal: true

name 'openvpn_okta'
maintainer 'Socrata Engineering'
maintainer_email 'sysadmin@socrata.com'
license 'Apache-2.0'
description 'Installs/configures the OpenVPN Okta plugin'
long_description 'Installs/configures the OpenVPN Okta plugin'
version '0.1.1'

source_url 'https://github.com/socrata-cookbooks/openvpn_okta'
issues_url 'https://github.com/socrata-cookbooks/openvpn_okta/issues'

chef_version '>= 12.1'

depends 'packagecloud', '< 2.0'
depends 'openvpn', '~> 2.1'

supports 'ubuntu'
supports 'redhat'
supports 'centos'
supports 'scientific'
