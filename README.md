# Openvpn Okta Cookbook README

[![Cookbook Version](https://img.shields.io/cookbook/v/openvpn_okta.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/socrata-cookbooks/openvpn_okta.svg)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/openvpn_okta
[travis]: https://travis-ci.org/socrata-cookbooks/openvpn_okta

A Chef cookbook for the OpenVPN Okta plugin.

_Note_: This cookbook installs a version of the Okta plugin built from a custom branch that includes currently unreleased patches that add support for Okta Verify.

## Requirements

This cookbook depends on the openvpn and packagecloud community cookbooks, for the OpenVPN server itself and for the packaged version of the plugin that we build in PackageCloud.io.

It primarily supports Ubuntu. There is support for RHEL platforms as well, but the openvpn cookbook as currently released has some issues related to Systemd that RHEL users will need to work around on their own.

It requires Chef 12.10.24+ or Chef 12 and the compat_resource cookbook.

## Usage

Either add the default recipe to your node's run list or use the included custom resource in a recipe of your own.

## Recipes

***default***

Ensure the OpenVPN server is installed, patch it to delay writing in the config file and starting the service until the end of the Chef run, then install and configure the plugin based on Chef attribbutes (below).

## Attributes

***default***

The Okta plugin has four possible attributes that can be set, two of which are required for it to function.

```ruby
node['openvpn_okta']['url'] (required)
node['openvpn_okta']['token'] (required)
node['openvpn_okta']['username_suffix'] (optional)
node['openvpn_okta']['allow_untrusted_users'] (optional)
```

## Resources

***openvpn_okta***

The main resource for managing the plugin.

Syntax:

```ruby
openvpn_okta 'default' do
  url 'https://example.okta.com'
  token 'abc123'
  username_suffix 'example.com'
  allow_untrusted_users false
  action %i(install enable)
end
```

Actions:

| Action     | Description                                      |
|------------|--------------------------------------------------|
| `:install` | Install the plugin package                       |
| `:enable`  | Patch the plugin into the OpenVPN server config  |
| `:remove`  | Uninstall the plugin package                     |
| `:disable` | Remove the plugin from the OpenVPN server config |

Properties:

| Property              | Default              | Description                      |
|-----------------------|----------------------|----------------------------------|
| url                   | `nil`                | The Okta URL                     |
| token                 | `nil`                | The Okta API token               |
| username_suffix       | `nil`                | A base @domain Okta user suffix  |
| allow_untrusted_users | `nil`                | Whether to allow untrusted users |
| action                | `%i(install enable)` | Action(s) to perform             |

***openvpn_okta_rhel***

The RHEL implementation of the `openvpn_okta` resource.

***openvpn_okta_ubuntu***

The Ubuntu implementation of the `openvpn_okta` resource.

## Maintainers

- Jonathan Hartman <jonathan.hartman@tylertech.com>
