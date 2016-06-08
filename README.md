# kitchen-chef_zero_berks_env

[![Gem Version](https://badge.fury.io/rb/kitchen-chef_zero_berks_env.svg)](http://badge.fury.io/rb/kitchen-chef_zero_berks_env)
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/kitchen-chef_zero_berks_env?type=total&color=brightgreen)](https://rubygems.org/gems/kitchen-chef_zero_berks_env)
[![Build Status](https://travis-ci.org/ruizink/kitchen-chef_zero_berks_env.svg?branch=master)](https://travis-ci.org/ruizink/kitchen-chef_zero_berks_env)

Chef Zero provider for Test Kitchen that enables Berkshelf to vendor the cookbook versions specified by a given chef environment.

## Use Case

If you adopted the pattern of pinning cookbooks per chef environment, and still want to use Berkshelf and Test Kitchen on your workflow,
this provider extension enables Berkshelf to build a lock file based on a given chef environment, respecting the cookbook version dependencies.
The default behaviour of the Chef providers is to first gather the cookbook dependencies using Berkshelf vendor and then run Chef on the box.
Well, if you don't pin the cookbook version dependencies within the cookbooks, Berkshelf will end up vendoring always the latest versions.
That might conflict with cookbook restrictions that you have defined within the chef environment, and the converge will fail.
Hopefuly this provider will do the trick!

## Installation

In order to install this provider, run the following alternative commands:

1. If you use the test-kitchen bundled with ChefDK (I strongly recommend you to do it):
```
chef gem install kitchen-chef_zero_berks_env
```
Click [here](https://downloads.chef.io/chef-dk/) to know more about ChefDK

2. Otherwise simply run:
```
gem install kitchen-chef_zero_berks_env
```

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

## License & Authors

- Author:: Mário Santos (<mario.rf.santos@gmail.com>)

```text
The MIT License (MIT)

Copyright (c) 2015 Mário Santos

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
