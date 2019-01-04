# frozen_string_literal: true

name 'openvpn_okta'
maintainer 'Socrata Engineering'
maintainer_email 'sysadmin@socrata.com'
license 'Apache-2.0'
description 'Installs/configures the OpenVPN Okta plugin'
long_description 'Installs/configures the OpenVPN Okta plugin'
version '1.0.0'
chef_version '>= 12.1'

source_url 'https://github.com/socrata-cookbooks/openvpn_okta'
issues_url 'https://github.com/socrata-cookbooks/openvpn_okta/issues'

depends 'packagecloud', '< 2.0'
depends 'openvpn', '~> 3.0'
depends 'yum-epel', '< 4.0'

supports 'ubuntu', '>= 14.04'
supports 'redhat', '>= 7.0'
supports 'centos', '>= 7.0'
supports 'scientific', '>= 7.0'
