# encoding: utf-8
# frozen_string_literal: true

name 'openvpn_okta'
maintainer 'Jonathan Hartman'
maintainer_email 'jonathan.hartman@socrata.com'
license 'apachev2'
description 'Installs/configures the OpenVPN Okta plugin'
long_description 'Installs/configures the OpenVPN Okta plugin'
version '0.0.1'

source_url 'https://github.com/socrata-cookbooks/openvpn_okta'
issues_url 'https://github.com/socrata-cookbooks/openvpn_okta/issues'

depends 'packagecloud', '~> 0.2'

supports 'ubuntu'
