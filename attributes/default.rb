#
# Cookbook Name:: funnies-cookbook
# Attributes:: default
#
# Copyright (C) 2013 Aaron Kalin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['funnies']['default_database_url'] = 'postgres://funnies@localhost/funnies_production?pool=5&encoding=unicode&min_messages=warning'
default['funnies']['revision'] = 'master'
default['funnies']['migrate'] = false
default['funnies']['ruby_version'] = 'ruby-2.0.0-p353'
