#
# Cookbook Name:: protocol-hub-api
# Recipe:: default
#
# Copyright (C) 2017 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

secrets = Chef::EncryptedDataBagItem.load("secrets", node['protocol-hub-api']['secrets_file'])
application_root = '/opt/sana.protocol_hub.api'
environment = {
  'PH_API_DB_HOST' => node['protocol-hub-api']['db']['host'],
  'PH_API_DB_USER' => secrets['ph_api_db_user'],
  'PH_API_DB_PASSWORD' => secrets['ph_api_db_password'],
  'PH_API_DB_DATABASE' => secrets['ph_api_db_database'],
  'PATH' => "#{application_root}/.venv/bin",
}

git application_root do
  repository node['protocol-hub-api']['repository']
  revision node['protocol-hub-api']['revision']
end

package 'build-essential' do
  action 'install'
end

package 'libpq-dev' do
  action 'install'
end

package 'python-dev' do
  action 'install'
end

python_runtime 'python2' do
  version '2'
end

python_runtime 'python3' do
  version '3'
end

python_package 'supervisor' do
  python 'python2'
  user 'root'
  group 'root'
end

python_virtualenv "#{application_root}/.venv" do
  python 'python3'
  user 'root'
  group 'root'
end

pip_requirements "#{application_root}/requirements.txt" do
  python 'python3'
  user 'root'
  group 'root'
  virtualenv "#{application_root}/.venv"
end

execute 'create_db' do
  command 'invoke create_db'
  cwd application_root
  environment(environment)
end

supervisor_service 'gunicorn' do
  autostart true
  autorestart true

  command "#{application_root}/.venv/bin/gunicorn app.app:app --bind #{node['protocol-hub-api']['bind_address']} -w #{node['protocol-hub-api']['workers']}"
  directory application_root
  environment(environment)

  redirect_stderr true
end
