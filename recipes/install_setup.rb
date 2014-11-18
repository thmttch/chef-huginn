user = node.huginn.user
group = node.huginn.group

db_name = node.huginn.db_name
db_user = node.huginn.db_user
db_pass = node.huginn.db_pass

include_recipe 'apt::default'
include_recipe 'build-essential::default'

package 'git'

# setup: users and permissions

user user do
  system true
  home "/home/huginn"
  password "$6$ZwO6b.6tij$SMa8UIwtESGDxB37NwHsct.gJfXWmmflNbH.oypwJ9y0KkzMkCdw7D14iK7GX9C4CWSEcpGOFUow7p01rQFu5."
  supports :manage_home => true
  #gid "sudo"
  #shell "/bin/bash"
  action :create
end

group group do
  members [ user ]
  action :create
end

=begin
bash "Setting huginn user with NOPASSWD option" do
  cwd "/etc/sudoers.d"
  code <<-EOH
    touch huginn
    chmod 0440 huginn
    echo "huginn ALL=(ALL) NOPASSWD:ALL" >> huginn
  EOH
end
=end

node.force_default.authorization.sudo.users = [ user ]
node.force_default.authorization.sudo.groups = [ group ]
node.force_default.authorization.sudo.passwordless = true
node.force_default.authorization.sudo.sudoers_defaults = [
  'env_reset',
  'env_keep = ""',
  'env_keep += "RBENV_ROOT"',
  'secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"',
]

# setup: db

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
