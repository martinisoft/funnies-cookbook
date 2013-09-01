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
include_recipe "nodejs::install_from_package"

env_vars = begin
             vars = Chef::EncryptedDataBagItem.load("funnies", "env").to_hash
             vars.delete('id')
             vars
           rescue => ex
             Chef::Log.warn("Cannot decrypt data bag! #{ex}")
             {}
           end

app_name          = "funnies"
app_home          = "/srv/#{app_name}"
deploy_user_home  = File.join('/', 'srv', app_name)
shared_home       = "#{deploy_user_home}/shared"
script_flags      = '-s stable'
installer_url     = node['rvm']['installer_url']
rvm_gem_options   = '--no-rdoc --no-ri'
ruby_version      = node['funnies']['ruby_version']

# Setup funnies user
user app_name do
  comment "#{app_name} application"
  shell "/bin/bash"
  home deploy_user_home
  manage_home true
end

# Setup some missing, but needed packages
dev_packages = %w[curl libpq-dev postgresql-client libxml2-dev libxslt1-dev]
dev_packages.each do |package|
  package package do
    action :install
  end
end

rvmrc = {
  'rvm_install_on_use_flag'       => 1,
  'rvm_gemset_create_on_use_flag' => 1
}

rvmrc_template  rvm_prefix: deploy_user_home,
                rvm_gem_options: rvm_gem_options,
                rvmrc: rvmrc,
                user: app_home


install_rvm     rvm_prefix: deploy_user_home,
                installer_url: installer_url,
                script_flags: script_flags,
                user: app_home

# Reset permissions on the rvmrc file
file "#{deploy_user_home}/.rvmrc" do
  group app_name
end

# Running this to resolve dependencies and install ruby at the same time
# This command is already idempotent because RVM will not reinstall an
# existing ruby unless explicitly told to reinstall
execute "install_rvm_ruby_#{ruby_version}" do
  user 'root'
  environment "HOME" => deploy_user_home
  command "#{deploy_user_home}/.rvm/bin/rvm install #{ruby_version} --autolibs=4"
end

# Does not use autolibs yet, WIP
# rvm_ruby ruby_version do
#   action :install
#   user "funnies"
#   # patch "falcon-gc"
# end

# Set default ruby version
rvm_default_ruby ruby_version do
  user app_name
end

# Setup application directories
app_dirs = [
  "#{shared_home}/config",
  "#{shared_home}/log",
  "#{shared_home}/sessions",
  "#{shared_home}/sockets",
  "#{shared_home}/comics",
  "#{shared_home}/pids"
]

app_dirs.each do |dir|
  directory dir do
    owner       app_name
    group       app_name
    mode        '2775'
    recursive   true
  end
end

# Defer to default database config if DATABASE_URL does not exist
env_vars['DATABASE_URL'] ||= node['funnies']['default_database_url']

# Touch an empty database file to symlink to trick Rails into using DATABASE_URL
file "#{shared_home}/database.yml" do
  owner app_name
  group app_name
  action :create
end

# Setup environment file loading in bashrc
ruby_block "update_bashrc" do
  block do
    source_env_line = '[ ! -f "$HOME/shared/.env" ] || . "$HOME/shared/.env"'
    bashrc = Chef::Util::FileEdit.new("#{deploy_user_home}/.bash_profile")
    bashrc.insert_line_if_no_match(/\$HOME\/shared\/\.env/, source_env_line)
    bashrc.write_file
  end
end

# Setup environment variables file
template "#{shared_home}/.env" do
  source  'env.erb'
  owner   app_name
  group   app_name
  mode    '0664'
  variables({ env_vars: env_vars })
end

# Setup funnies application, clone the repo
application app_name do
  path deploy_user_home
  owner app_name
  group app_name

  repository "https://github.com/martinisoft/funnies.git"
  revision node[app_name]["revision"]

  symlink_before_migrate({"database.yml" => "config/database.yml"})
  create_dirs_before_symlink %w{tmp}
  purge_before_symlink %w{log}
  symlinks({
    "comics" => "public/images/comics",
    "pids" => "tmp/pids",
    "sessions" => "tmp/sessions",
    "sockets" => "tmp/sockets",
    "log" => "log"
  })

  environment env_vars
  migrate false
  restart_command "touch #{deploy_user_home}/current/tmp/restart.txt"
  before_migrate do
    Chef::Log.info "Running bundle install"
    directory "#{new_resource.path}/shared/vendor_bundle" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end
    directory "#{new_resource.release_path}/vendor" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end
    link "#{new_resource.release_path}/vendor/bundle" do
      to "#{new_resource.path}/shared/vendor_bundle"
    end
    bundle_without = %w{development test}
    bundle_without = bundle_without.join(' ')
    # Check for a Gemfile.lock
    bundler_deployment = ::File.exists?(::File.join(new_resource.release_path, "Gemfile.lock"))
    bash "install_bundle" do
      cwd new_resource.release_path
      user new_resource.owner
      flags "-l"
      environment({"HOME" => deploy_user_home, "USER" => new_resource.owner})
      code "bundle install --path vendor/bundle #{bundler_deployment ? "--deployment " : ""}--without #{bundle_without}"
    end
  end
  before_symlink do
    if node['funnies']['migrate']
      Chef::Log.info "Migrating"
      bash "rake_db_migrate" do
        cwd new_resource.release_path
        user new_resource.owner
        flags "-l"
        environment({"HOME" => deploy_user_home, "USER" => new_resource.owner})
        code "bundle exec rake db:migrate"
      end
    end
    Chef::Log.info "Compiling Assets"
    bash "precompile_assets" do
      cwd new_resource.release_path
      user new_resource.owner
      flags "-l"
      environment({"HOME" => deploy_user_home, "USER" => new_resource.owner})
      code "bundle exec rake RAILS_GROUPS=assets assets:precompile"
    end
  end
  after_restart do
    Chef::Log.info "Wheneverizing"
    bash "precompile_assets" do
      cwd new_resource.release_path
      user new_resource.owner
      flags "-l"
      environment({"HOME" => deploy_user_home, "USER" => new_resource.owner})
      code "bundle exec whenever --update-crontab funnies --set environment=production"
    end
  end
end

# Setup nginx config
template "#{node['nginx']['dir']}/sites-available/#{app_name}" do
  source      "#{app_name}.conf.erb"
  owner       "root"
  group       "root"
  mode        "0644"
  variables({ passenger_ruby: "#{deploy_user_home}/.rvm/wrappers/default/ruby" })

  notifies    :reload, "service[nginx]"
end

# Enable funnies site
nginx_site app_name

