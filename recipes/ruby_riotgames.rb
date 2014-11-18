user = node.huginn.user
group = node.huginn.group

install_dir = node.huginn.install_dir
ruby_version = node.huginn.ruby_version

node.force_default.rbenv.group_users = [ 'root', 'vagrant', user ]

include_recipe 'rbenv::default'
include_recipe 'ruby_build::default'
include_recipe 'rbenv::rbenv_vars'

rbenv_ruby ruby_version do
  global true
end
rbenv_gem 'bundle' do
  ruby_version ruby_version
end
file "#{install_dir}/.ruby-version" do
  content ruby_version
end

rbenv_execute 'bundle install and exec' do
  command <<-EOS
    bundle install
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed

    bundle binstubs foreman
  EOS
  cwd install_dir
  ruby_version ruby_version
  user user
end
