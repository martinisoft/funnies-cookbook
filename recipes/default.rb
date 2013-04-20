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

# Setup funnies user
user "funnies" do
  comment "Funnies application"
  shell "/bin/bash"
  home "/srv/funnies"
  manage_home true
end

# Does not come with build-essential in Ubuntu
package 'curl' do
  action :install
end

rvmrc = {
  'rvm_install_on_use_flag'       => 1,
  'rvm_gemset_create_on_use_flag' => 1,
  'rvm_trust_rvmrcs_flag'         => 1
}

script_flags      = '-s stable'
installer_url     = node['rvm']['installer_url']
rvm_prefix        = '/srv/funnies'
rvm_gem_options   = '--no-rdoc --no-ri'
ruby_version      = '1.9.3-p327'
deploy_user_home  = File.join('/', 'srv', 'funnies')

rvmrc_template  rvm_prefix: rvm_prefix,
                rvm_gem_options: rvm_gem_options,
                rvmrc: rvmrc,
                user: 'funnies'


install_rvm     rvm_prefix: rvm_prefix,
                installer_url: installer_url,
                script_flags: script_flags,
                user: 'funnies'

# Reset permissions on the rvmrc file
file "#{rvm_prefix}/.rvmrc" do
  group "funnies"
end

# Running this to resolve dependencies and install ruby at the same time
# This command is already idempotent because RVM will not reinstall an
# existing ruby unless explicitly told to reinstall
execute "install_rvm_ruby_#{ruby_version}" do
  user 'root'
  environment "HOME" => deploy_user_home
  command "#{deploy_user_home}/.rvm/bin/rvm install #{ruby_version} --patch falcon-gc --autolibs=4"
end

# Does not use autolibs yet, WIP
# rvm_ruby ruby_version do
#   action :install
#   user "funnies"
#   # patch "falcon-gc"
# end

# Set default ruby version
rvm_default_ruby ruby_version do
  user "funnies"
end

# Setup application directories
app_dirs = [
  '/srv/funnies/shared/config',
  '/srv/funnies/shared/log',
  '/srv/funnies/shared/sessions',
  '/srv/funnies/shared/sockets',
  '/srv/funnies/shared/system',
  '/srv/funnies/shared/pids'
]

app_dirs.each do |dir|
  directory dir do
    owner       'funnies'
    group       'funnies'
    mode        '2775'
    recursive   true
  end
end

# Setup database config
env_vars['DATABASE_URL'] ||= node['funnies']['default_database_url']

# Setup funnies application, clone the repo
application "funnies" do
  path "/srv/funnies"
  owner "funnies"
  group "funnies"

  repository "https://github.com/martinisoft/funnies.git"
  revision "master"

  symlink_before_migrate.clear
  create_dirs_before_symlink %w{tmp}
  purge_before_symlink.clear
  symlinks({
    "system" => "public/system",
    "pids" => "tmp/pids",
    "sessions" => "tmp/sessions",
    "sockets" => "tmp/sockets",
    "log" => "log"
  })

  environment env_vars
end

