# kitchen-chef_zero_berks_env

[![Gem Version](https://badge.fury.io/rb/kitchen-chef_zero_berks_env.svg)](http://badge.fury.io/rb/kitchen-chef_zero_berks_env)
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/kitchen-chef_zero_berks_env?type=total&color=brightgreen)](https://rubygems.org/gems/kitchen-chef_zero_berks_env)
[![Build Status](https://travis-ci.org/ruizink/kitchen-chef_zero_berks_env.svg?branch=master)](https://travis-ci.org/ruizink/kitchen-chef_zero_berks_env)

Chef Zero provider for Test Kitchen that enables Berkshelf to vendor the cookbook versions specified by a given chef environment.

## Use Case

If you adopted the pattern of pinning cookbooks per chef environment, and still want to use Berkshelf and Test Kitchen on your workflow,
this provider extension enables Berkshelf to build a lock file based on a given chef environment, respecting the cookbook version dependencies.
The default behaviour of the Chef providers is to first gather the cookbook dependencies using Berkshelf vendor and then run Chef on the box.
Well, if you don't pin the cookbook version dependencies within the cookbooks, Berkshelf will end up vendoring allways the latest versions.
That might conflict with cookbook restrictions that you have defined within the chef environment, and the converge will fail.
Hopefuly this provider will do the trick!

## Usage

Simply replace the provider from `chef_zero` to `chef_zero_berks_env`.
The provider will look for the `environments_path` and `environment` configs from the provider.

You can specify the `environments_repo` config, that overrides the `environments_path`. That allows you to fetch the chef environments
from a remote repository.

## Example

```yaml
provisioner:
  name: chef_zero_berks_env
  environments_path: 'environments'

suites:
  - name: default
    provisioner:
      client_rb:
        environment: 'my_chef_environment'
```
or

```yaml
provisioner:
  name: chef_zero_berks_env
  environments_repo: 'git@github.com:ruizink/my_awesome_chef_environments.git'

suites:
  - name: default
    provisioner:
      client_rb:
        environment: 'my_chef_environment'
```
