funnies cookbook
================

An application cookbook to deploy the [funnies](https://github.com/martinisoft/funnies) web application

### Requirements

* ubuntu 12.04
* chef 11.4.0
* encrypted data bag

### Usage & Setup

Include the funnies recipe in your node run list

Then setup an encrypted data bag called 'funnies' with the 'env' item. The
database is setup via the DATABASE\_URL key in your 'env' data bag. For
example:

```
postgres://funnies@localhost/production_db?pool=5
```

Will setup the funnies user with localhost and point to production\_db
with a pool of 5 connections.

### Getting Started

First get your bundle installed with ```bundle install```

### Testing

After you complete your ```bundle install```

Make sure you have [Vagrant](http://www.vagrantup.com/) 1.2 or newer installed on your system

Then just run ```kitchen test``` and watch your CPU burn

### Attributes

* ```default['funnies']['default_database_url']``` - The default database URL if one is not provided
* ```default['funnies']['revision']``` - Revision to deploy (default is 'master')
* ```default['funnies']['migrate']``` - Wether to run migrations (default is 'false')
* ```default['funnies']['ruby_version']``` - Ruby version to install for the app (default is '2.0.0-p247')

### Recipes

* default - Installs dependcies and deploys funnies

### License and Author

Author:: Aaron Kalin (<akalin@martinisoftware.com>)

Copyright:: 2013, Aaron Kalin

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.
