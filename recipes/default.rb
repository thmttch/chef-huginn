include_recipe 'apt'
include_recipe 'build-essential'

package 'git'

user = 'huginn'
group = 'huginn'
install_dir = '/home/huginn/huginn'
#repo_url = 'git://github.com/thmttch/huginn.git'
repo_url = 'https://github.com/cantino/huginn.git'
repo_branch = 'master'

db_name = 'huginn_dev'
db_user = 'root'
db_pass = 'root'

mysql_service 'huginn' do
  #version '5.5'
  #port '3307'
  #data_dir '/var/lib/mysql'
  action [ :create, :start ]
end
mysql_database db_name do
  connection(
    :host     => 'localhost',
    :username => db_user,
    :password => db_pass,
  )
  action :create
end

user "huginn" do
  action :create
  system true
  home "/home/huginn"
  password "$6$ZwO6b.6tij$SMa8UIwtESGDxB37NwHsct.gJfXWmmflNbH.oypwJ9y0KkzMkCdw7D14iK7GX9C4CWSEcpGOFUow7p01rQFu5."
  supports :manage_home => true
  gid "sudo"
  shell "/bin/bash"
end

group "huginn" do
  members ["huginn"]
  action :create
end

%w("ruby1.9.1" "ruby1.9.1-dev" "libxslt-dev" "libxml2-dev" "curl" "libmysqlclient-dev" "libffi-dev" "libssl-dev" "libsqlite3-dev").each do |pkg|
  package pkg do
    action :install
  end
end

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

git install_dir do
  repository repo_url
  reference repo_branch
  action :sync
  user "huginn"
end

gem_package("rake")
gem_package("bundle")

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
