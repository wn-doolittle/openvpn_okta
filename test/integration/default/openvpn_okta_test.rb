# frozen_string_literal: true

control 'openvpn_okta' do
  impact 1.0
  title 'OpenVPN Okta: Plugin is installed and configured'
  desc 'The OpenVPN Okta plugin is installed and configured'

  case os[:family]
  when 'debian'
    describe apt('https://packagecloud.io/socrata-platform/okta-openvpn/' \
                 'ubuntu') do
      it { should exist }
      it { should be_enabled }
    end
  when 'rhel'
    describe yum.repo('socrata-platform_okta-openvpn') do
      it { should exist }
      it { should be_enabled }
    end
  end

  describe package('okta-openvpn') do
    it { should be_installed }
  end

  describe file('/etc/openvpn/server.conf') do
    [
      Regexp.new('^plugin /usr/lib/openvpn/plugins/okta/' \
                 'defer_simple\\.so ' \
                 '/usr/lib/openvpn/plugins/okta/okta_openvpn\.py$'),
      Regexp.new('^tmp-dir "/etc/openvpn/tmp"$')
    ].each do |r|
      its(:content) { should match(r) }
    end
  end

  describe file('/etc/openvpn/okta_openvpn.ini') do
    [/^Url: example\.com$/, /^Token: abc123$/].each do |r|
      its(:content) { should match(r) }
    end
  end
end
