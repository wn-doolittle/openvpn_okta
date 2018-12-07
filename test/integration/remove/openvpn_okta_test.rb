# frozen_string_literal: true

control 'openvpn_okta_app' do
  impact 1.0
  title 'OpenVPN Okta: Plugin is uninstalled'
  desc 'The OpenVPN Okta plugin is uninstalled'

  case os[:family]
  when 'debian'
    describe apt('https://packagecloud.io/socrata-platform/duo-openvpn/' \
                 'ubuntu') do
      it { should_not exist }
    end
  when 'rhel'
    describe yum.repo('socrata-platform_okta-openvpn') do
      it { should_not exist }
    end
  end

  describe package('okta-openvpn') do
    it { should_not be_installed }
  end

  describe file('/etc/openvpn/server.conf') do
    [
      Regexp.new('^plugin /usr/lib/openvpn/plugins/okta/' \
                 'defer_simple\\.so ' \
                 '/usr/lib/openvpn/plugins/okta/okta_openvpn\.py$'),
      Regexp.new('^tmp-dir "/etc/openvpn/tmp"$')
    ].each do |r|
      its(:content) { should_not match(r) }
    end
  end

  describe file('/etc/openvpn/okta_openvpn.ini') do
    it { should_not exist }
  end
end
