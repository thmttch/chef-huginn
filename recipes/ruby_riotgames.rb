=begin
%w("ruby1.9.1" "ruby1.9.1-dev" "libxslt-dev" "libxml2-dev" "curl" "libmysqlclient-dev" "libffi-dev" "libssl-dev" "libsqlite3-dev").each do |pkg|
  package pkg do
    action :install
  end
end
=end

user = node.huginn.user
group = node.huginn.group

install_dir = node.huginn.install_dir

node.force_default.rbenv.group_users = [ 'root', 'vagrant', user ]

include_recipe 'rbenv::default'
include_recipe 'ruby_build::default'
include_recipe 'rbenv::rbenv_vars'

ruby_version = '2.1.5'
rbenv_ruby ruby_version do
  global true
end

=begin
rbenv_gem 'rake' do
  ruby_version ruby_version
  version '10.3.2'
  #action :upgrade
  action :nothing
end
=end
rbenv_gem 'bundle' do
  ruby_version ruby_version
end

rbenv_execute 'bundle install' do
  command <<-EOS
    bundle install
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
  EOS
  cwd install_dir
  ruby_version ruby_version
  user user
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

=begin
file "#{install_dir}/.ruby-version" do
  content ruby_version
end

rbenv_execute 'bundle install' do
  command 'bundle install'
  cwd '/home/huginn/huginn'
  ruby_version ruby_version
  user user
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
=end
