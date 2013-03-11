#
# Cookbook Name:: funnies-cookbook
# Recipe:: default
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

include_recipe "git::default"

env_vars = begin
             Chef::EncryptedDataBagItem.load("funnies", "env")
           rescue => ex
             if ex.class == Errno::ENOENT
               Chef::Log.warn("Could not decrypt data bag! (#{ex})")
             else
               Chef::Log.warn("Data bag 'funnies' not found, please create it")
             end
             {}
           end

user "funnies" do
  comment "Funnies application"
  shell "/bin/bash"
  home "/srv/funnies"
  manage_home true
end

application "funnies" do
  path "/srv/funnies"
  owner "funnies"
  group "funnies"

  repository "https://github.com/martinisoft/funnies.git"
  revision "master"

  environment env_vars
end
