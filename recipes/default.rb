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
include_recipe "build-essential::default"
include_recipe "rvm"

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

# Prerequisites for RVM
rvm_packages = [
  "sed",
  "grep",
  "gzip",
  "bzip2",
  "curl",
  "libcurl4-openssl-dev",
  "libreadline6",
  "libreadline6-dev",
  "zlib1g",
  "zlib1g-dev",
  "libssl-dev",
  "libyaml-dev",
  "libsqlite3-dev",
  "libxml2-dev",
  "libxslt-dev",
  "libc6-dev",
  "ncurses-dev",
  "automake",
  "libtool",
  "pkg-config"
]

rvm_packages.each do |pkg|
  package pkg do
    action :install
  end
end

rvmrc = {
  'rvm_install_on_use_flag'       => 1,
  'rvm_gemset_create_on_use_flag' => 1,
  'rvm_trust_rvmrcs_flag'         => 1
}

script_flags      = "-s stable"
installer_url     = node['rvm']['installer_url']
rvm_prefix        = "/srv/funnies"
rvm_gem_options   = "--no-rdoc --no-ri"

rvmrc_template  rvm_prefix: rvm_prefix,
                rvm_gem_options: rvm_gem_options,
                rvmrc: rvmrc,
                user: "funnies"

install_rvm     rvm_prefix: rvm_prefix,
                installer_url: installer_url,
                script_flags: script_flags,
                user: "funnies"

# Reset permissions on the rvmrc file
file "#{rvm_prefix}/.rvm/.rvmrc" do
  group "funnies"
end

application "funnies" do
  path "/srv/funnies"
  owner "funnies"
  group "funnies"

  repository "https://github.com/martinisoft/funnies.git"
  revision "master"

  environment env_vars
end
