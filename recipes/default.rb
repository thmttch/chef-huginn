include_recipe 'apt::default'
include_recipe 'build-essential::default'

package 'git'

user = 'huginn'
group = 'huginn'
install_dir = '/home/huginn/huginn'
#repo_url = 'git://github.com/thmttch/huginn.git'
repo_url = 'https://github.com/cantino/huginn.git'
repo_branch = 'master'

db_name = 'huginn_dev'
db_user = 'root'
db_pass = node.mysql.server_root_password

include_recipe 'mysql::server'
include_recipe 'database::mysql'
mysql_service 'huginn' do
  #version '5.5'
  #port '3307'
  #data_dir '/var/lib/mysql'
  #action [ :create, :start ]
  action :create
end
mysql_database db_name do
  connection(
    :host     => 'localhost',
    :username => db_user,
    :password => db_pass,
  )
  action :create
end

user user do
  action :create
  system true
  home "/home/huginn"
  password "$6$ZwO6b.6tij$SMa8UIwtESGDxB37NwHsct.gJfXWmmflNbH.oypwJ9y0KkzMkCdw7D14iK7GX9C4CWSEcpGOFUow7p01rQFu5."
  supports :manage_home => true
  gid "sudo"
  shell "/bin/bash"
end

group group do
  members [ user ]
  action :create
end

=begin
%w("ruby1.9.1" "ruby1.9.1-dev" "libxslt-dev" "libxml2-dev" "curl" "libmysqlclient-dev" "libffi-dev" "libssl-dev" "libsqlite3-dev").each do |pkg|
  package pkg do
    action :install
  end
end
=end

node.force_default.rbenv.group_users = [ 'root', 'vagrant', user ]

include_recipe 'rbenv::default'
include_recipe 'rbenv::ruby_build'
include_recipe 'rbenv::rbenv_vars'

ruby_version = '2.1.5'
rbenv_ruby ruby_version do
  #global true
end

rbenv_gem 'rake' do
  ruby_version ruby_version
  version '10.3.2'
  #action :upgrade
  action :nothing
end
rbenv_gem 'bundle' do
  ruby_version ruby_version
end

=begin
bash "Setting default ruby and gem versions to 1.9" do
  code <<-EOH
    if [ $(readlink /usr/bin/ruby) != "ruby1.9.1" ]
    then
      update-alternatives --set ruby /usr/bin/ruby1.9.1
    fi

    if [ $(readlink /usr/bin/gem) != "gem1.9.1" ]
    then
      update-alternatives --set gem /usr/bin/gem1.9.1
    fi
  EOH
end

gem_package("rake")
gem_package("bundle")
=end

git install_dir do
  repository repo_url
  reference repo_branch
  action :sync
  user user
end

bash "Setting huginn user with NOPASSWD option" do
  cwd "/etc/sudoers.d"
  code <<-EOH
    touch huginn
    chmod 0440 huginn
    echo "huginn ALL=(ALL) NOPASSWD:ALL" >> huginn
  EOH
end

template "#{install_dir}/.env" do
  source 'env.erb'
  owner user
  group group
  variables({
    :db_name => db_name,
    :db_user => db_user,
    :db_pass => db_pass,
  })
end

file "#{install_dir}/.ruby-version" do
  content ruby_version
end

bash "huginn dependencies" do
  user "huginn"
  cwd "/home/huginn/huginn"
  code <<-EOH
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    sudo bundle install
    #sed s/REPLACE_ME_NOW\!/$(sudo bundle exec rake secret)/ .env.example > .env
    sudo bundle exec rake db:create
    sudo bundle exec rake db:migrate
    sudo bundle exec rake db:seed
  EOH
  action :nothing
end

bash "huginn has been installed and will start in a minute" do
  user "huginn"
  cwd "/home/huginn/huginn"
  code <<-EOH
    sudo nohup foreman start &
  EOH
  action :nothing
end

include_recipe 'runit::default'
runit_service 'huginn' do
  default_logger true
  action :nothing
end
