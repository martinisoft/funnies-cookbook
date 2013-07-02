chef_api :config
site :opscode

metadata

cookbook 'rvm', github: 'fnichol/chef-rvm', ref: 'master'

group :integration do
  cookbook 'martinisoft-nginx', '~> 0.3'
  cookbook 'martinisoft-database_server'
end
