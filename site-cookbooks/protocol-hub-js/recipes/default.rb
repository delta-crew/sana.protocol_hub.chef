#
# Cookbook Name:: protocol-hub-js
# Recipe:: default
#
# Copyright (C) 2017 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nginx'
include_recipe 'nodejs::nodejs_from_binary'

application_root = '/opt/sana.protocol_hub.js'

git application_root do
  repository node['protocol-hub-js']['repository']
  revision node['protocol-hub-js']['revision']
end

nodejs_npm 'protocol-hub-npm' do
  path application_root
  json true
end

execute 'build' do
  cwd application_root
  command 'npm run webpack'
end

template '/etc/nginx/sites-available/protocol-hub-js.conf' do
  source  'protocol-hub-js.conf.erb'
end

link '/etc/nginx/sites-enabled/protocol-hub-js.conf' do
  to '/etc/nginx/sites-available/protocol-hub-js.conf'
end

service 'nginx' do
  action ['enable', 'restart']
end
