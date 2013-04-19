funnies cookbook
================

An application cookbook to deploy the [funnies](https://github.com/martinisoft/funnies) web application

### Requirements

* ubuntu 12.04
* chef 11.4.0

### Usage

Include the funnies recipe in your node run list

### Getting Started

First get your bundle installed with ```bundle install```

### Testing

After you complete your ```bundle install```

Make sure you have [Vagrant](http://www.vagrantup.com/) 1.2 or newer installed on your system

Then just run ```kitchen test``` and watch your CPU burn

### Attributes

None

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
